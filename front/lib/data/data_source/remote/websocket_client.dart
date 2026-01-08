// front/lib/data/data_source/remote/web_socket_client.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/local/wazzup_token_storage.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:http/http.dart' as http;

final webSocketClientProvider = Provider<WebSocketClient>((ref) {
  return WebSocketClient(ref);
});

/**
 * WebSocketClient
 * 
 * 【 HTTP vs WebSocket 차이 】
 * HTTP: 요청→응답→끝 (1회성), await로 대기
 * WebSocket: 연결→계속 대기→여러 번 메시지 주고받기 (지속성), 콜백으로 처리
 * 
 * 【 SockJS와 http:// 프로토콜 】
 * useSockJS: true이면 반드시 http:// 사용 (ws:// 불가)
 * - SockJS가 초기 HTTP 요청(/ws/info)을 보낸 후 WebSocket으로 업그레이드
 * - ws://는 HTTP 요청을 보낼 수 없어서 오류 발생
 * 
 * 【 핵심 객체 】
 * StompClient: 연결 관리, StompConfig: 설정, StompFrame: 서버 메시지
 */
class WebSocketClient {
  Ref ref;
  WebSocketClient(this.ref);

  final WazzupTokenStorage _storage = WazzupTokenStorage();
  final String baseApiUrl = "${dotenv.env["API_URL"]}";
  final String baseWSUrl = "${dotenv.env["WEBSOCKET_URL"]}";

  // StompClient: WebSocket 연결을 관리하는 객체
  StompClient? _stompClient;
  bool _isConnected = false;

  // 연결 상태 확인
  bool get isConnected => _isConnected;

  /**
   * connect() - WebSocket 연결 시작
   * 
   * HTTP와 다르게 connect()는 연결 준비만 하고 즉시 리턴함
   * 실제 연결 완료는 onConnect 콜백에서 알림!
   * 
   * 이벤트 핸들러:
   * - onConnect: 서버가 "CONNECTED" 메시지 보내면 실행
   * - onError: 네트워크/STOMP 에러 발생 시 실행
   * - onDisconnect: 연결 종료 시 실행
   */
  Future<void> connect({
    Function(StompFrame)? onConnect,
    Function(StompFrame)? onError,
    Function(StompFrame)? onDisconnect,
  }) async {
    // 1. 중복 연결 방지
    if (_isConnected) {
      debugPrint("[WebSocketClient] 이미 연결되어 있습니다.");
      return;
    }

    // 2. 스토리지에서 액세스 토큰 가져오기 (api_client와 동일)
    String? accessToken = await _storage.getAccessToken();

    if (accessToken == null) {
      debugPrint("[WebSocketClient] 토큰이 없습니다.");
      throw Exception("토큰이 없습니다.");
    }

    // 3. WebSocket URL 구성
    String endpoint = '$baseWSUrl/ws';

    // 4. StompClient 생성 및 이벤트 핸들러 등록
    _stompClient = StompClient(
      config: StompConfig(
        url: endpoint,
        stompConnectHeaders: {'Authorization': 'Bearer $accessToken'},

        // onConnect: 서버가 "CONNECTED" 메시지 보내면 실행 (HTTP의 200과 같음)
        onConnect: (frame) {
          _isConnected = true;
          debugPrint("[WebSocketClient] 연결 성공");
          onConnect?.call(frame);
        },

        // onWebSocketError: 네트워크 끊김, 타임아웃, DNS 에러 등 (STOMP 이전 단계)
        onWebSocketError: (dynamic error) {
          debugPrint("[WebSocketClient] 연결 오류: $error");
          _isConnected = false;
          onError?.call(StompFrame(command: 'ERROR', body: error.toString()));
        },

        // onStompError: 서버가 "ERROR" 메시지 보내면 실행 (HTTP의 401, 403과 같음)
        // frame.body에 "401" 또는 "403" 있으면 자동으로 토큰 재발급 시도
        onStompError: (frame) {
          debugPrint("[WebSocketClient] STOMP 오류: ${frame.body}");
          _handleStompError(frame);
          onError?.call(frame);
        },

        // onDisconnect: disconnect() 호출, 서버 종료, 네트워크 끊김 시 실행
        onDisconnect: (frame) {
          _isConnected = false;
          debugPrint("[WebSocketClient] 연결 끊김");
          onDisconnect?.call(frame);
        },

        useSockJS: true,
        reconnectDelay: const Duration(seconds: 5),
        heartbeatIncoming: const Duration(seconds: 0),
        heartbeatOutgoing: const Duration(seconds: 20),
      ),
    );

    // 연결 활성화 (백그라운드 연결 시작, 완료는 onConnect에서 알림)
    _stompClient?.activate();
  }

  /**
   * send() - 서버에 메시지 전송
   * 
   * HTTP와 다르게 await 없이 즉시 리턴, 응답은 subscribe 콜백으로 받음
   * '/app'으로 시작: 서버의 @MessageMapping으로 전달
   * 예: '/app/match/enter' → @MessageMapping("/match/enter")
   */
  void send(String destination, Map<String, dynamic> body) {
    if (!_isConnected || _stompClient == null) {
      debugPrint("[WebSocketClient] 연결되지 않았습니다.");
      throw Exception("WebSocket이 연결되지 않았습니다.");
    }

    _stompClient!.send(destination: destination, body: jsonEncode(body));
  }

  /**
   * subscribe() - 서버 메시지 구독 (받기 등록)
   * 
   * "이 주소로 메시지 오면 알려줘!"라고 미리 등록
   * HTTP와 다르게 한 번 구독하면 여러 번 메시지 받을 수 있음
   * 
   * 경로 규칙:
   * - '/queue': 개인 메시지 (1:1), 예: '/queue/match/123'
   * - '/topic': 브로드캐스트 (1:N), 예: '/topic/room/456'
   */
  void subscribe({
    required String destination,
    required Function(StompFrame) callback,
  }) {
    if (!_isConnected || _stompClient == null) {
      throw Exception("WebSocket이 연결되지 않았습니다.");
    }

    _stompClient!.subscribe(destination: destination, callback: callback);
  }

  /**
   * disconnect() - WebSocket 연결 종료
   */
  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
    _isConnected = false;
    debugPrint("[WebSocketClient] 연결 해제");
  }

  /**
   * _handleStompError() - STOMP 에러 자동 처리
   * 
   * HTTP의 statusCode == 401처럼, WebSocket은 frame.body.contains('401')로 체크
   * 백엔드가 ERROR 프레임 body에 "401" 또는 "403" 포함해서 보내면 자동으로 토큰 재발급 후 재연결
   */
  Future<void> _handleStompError(StompFrame frame) async {
    String? body = frame.body;
    if (body != null && (body.contains('401') || body.contains('403'))) {
      debugPrint("[WebSocketClient] 토큰 만료 감지. 재발급 시도...");
      await reconnectWithRefresh();
    }
  }

  /**
   * reconnectWithRefresh() - 토큰 재발급 후 재연결
   * 
   * api_client.dart와 동일한 패턴: 토큰 재발급 → 재연결
   */
  Future<void> reconnectWithRefresh() async {
    try {
      disconnect();
      bool refreshed = await _refreshAccessToken();

      if (refreshed) {
        debugPrint("[WebSocketClient] 토큰 재발급 성공. 재연결 시도...");
        await connect();
      } else {
        debugPrint("[WebSocketClient] 토큰 재발급 실패");
        _forceLogOut(ref);
      }
    } catch (e) {
      debugPrint("[WebSocketClient] 재연결 중 에러: $e");
    }
  }

  /**
   * _refreshAccessToken() - 토큰 재발급 (HTTP 요청)
   * 
   * api_client.dart와 동일한 로직
   */
  Future<bool> _refreshAccessToken() async {
    try {
      String? refreshToken = await _storage.getRefreshToken();

      if (refreshToken == null) {
        debugPrint("[WebSocketClient] 리프레시 토큰이 없습니다.");
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseApiUrl/api/auth/reissue'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final data = jsonResponse['data'];

        String newAt = data['wazzupToken'] ?? '';
        String newRt = data['refreshToken'] ?? '';

        await _storage.saveTokensOnly(accessToken: newAt, refreshToken: newRt);
        return true;
      } else {
        debugPrint("[WebSocketClient] 토큰 재발급 실패: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("[WebSocketClient] 토큰 재발급 중 에러: $e");
      return false;
    }
  }

  /**
   * _forceLogOut() - 강제 로그아웃
   * 
   * api_client.dart와 동일
   */
  void _forceLogOut(Ref ref) async {
    await _storage.deleteAll();
    disconnect();
    // TODO: 로그아웃 UI 처리
  }
}
