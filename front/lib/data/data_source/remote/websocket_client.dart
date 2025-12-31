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
 * 【 역할 】
 * - HTTP의 api_client.dart처럼, WebSocket 연결에 토큰을 자동으로 넣어주는 역할
 * - 매칭, 채팅 등 실시간 통신이 필요한 곳에서 사용
 * 
 * 【 STOMP 객체들 】
 * 1. StompClient: WebSocket 연결을 관리하는 객체 (전화기 같은 거)
 * 2. StompConfig: 연결 설정을 담는 객체 (전화기 설정)
 * 3. StompFrame: 서버가 보내는 메시지 덩어리 (편지봉투)
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
   * connect() - WebSocket 서버 연결
   * 
   * 【 역할 】
   * - 서버와 WebSocket 연결을 시작하는 메서드
   * - 연결할 때 토큰을 헤더에 넣어서 인증 처리
   * 
   * 【 파라미터 】
   * - onConnect: 연결 성공 시 실행할 콜백 함수
   * - onError: 에러 발생 시 실행할 콜백 함수
   * - onDisconnect: 연결 끊김 시 실행할 콜백 함수
   * 
   * 【 로직 흐름 】
   * 1. 이미 연결되어 있으면 종료
   * 2. 토큰 가져오기
   * 3. WebSocket URL 구성
   * 4. StompClient 생성 및 설정
   * 5. 연결 활성화
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
    String endpoint = '$baseWSUrl/ws/matching';

    // 4. StompClient 생성 및 설정
    // StompClient: WebSocket 연결을 관리하는 객체
    _stompClient = StompClient(
      // StompConfig: 연결 설정을 담는 객체
      config: StompConfig(
        // 서버 주소
        url: endpoint,

        // 연결 시 헤더에 토큰 포함 (api_client와 동일한 패턴)
        stompConnectHeaders: {'Authorization': 'Bearer $accessToken'},

        // 연결 성공 시 콜백
        // StompFrame: 서버가 보내는 메시지 덩어리
        onConnect: (frame) {
          _isConnected = true;
          debugPrint("[WebSocketClient] 연결 성공");
          onConnect?.call(frame);
        },

        // WebSocket 레벨 에러 발생 시 콜백
        onWebSocketError: (dynamic error) {
          debugPrint("[WebSocketClient] 연결 오류: $error");
          _isConnected = false;
          onError?.call(StompFrame(command: 'ERROR', body: error.toString()));
        },

        // STOMP 레벨 에러 발생 시 콜백
        onStompError: (frame) {
          debugPrint("[WebSocketClient] STOMP 오류: ${frame.body}");
          // 토큰 만료(401, 403) 체크
          _handleStompError(frame);
          onError?.call(frame);
        },

        // 연결 끊김 시 콜백
        onDisconnect: (frame) {
          _isConnected = false;
          debugPrint("[WebSocketClient] 연결 끊김");
          onDisconnect?.call(frame);
        },

        // 백엔드에서 SockJS 사용하므로 true로 설정
        useSockJS: true,

        // 연결 실패 시 재연결 대기 시간
        reconnectDelay: const Duration(seconds: 5),

        // 하트비트 설정 (연결 유지 확인용)
        heartbeatIncoming: const Duration(seconds: 0),
        heartbeatOutgoing: const Duration(seconds: 20),
      ),
    );

    // 5. 연결 활성화 (실제 서버에 연결 시작)
    _stompClient?.activate();
  }

  /**
   * send() - 서버에 메시지 전송
   * 
   * 【 역할 】
   * - 연결된 WebSocket을 통해 서버에 메시지를 보내는 메서드
   * - 매칭 요청, 채팅 메시지 전송 등에 사용
   * 
   * 【 파라미터 】
   * - destination: 메시지를 보낼 목적지 (예: '/app/match/enter')
   * - body: 전송할 데이터 (Map 형태)
   * 
   * 【 로직 흐름 】
   * 1. 연결 상태 확인
   * 2. 데이터를 JSON으로 변환하여 전송
   */
  void send(String destination, Map<String, dynamic> body) {
    // 1. 연결 상태 확인
    if (!_isConnected || _stompClient == null) {
      debugPrint("[WebSocketClient] 연결되지 않았습니다.");
      throw Exception("WebSocket이 연결되지 않았습니다.");
    }

    // 2. 서버에 메시지 전송
    // destination: 메시지를 받을 서버의 주소 (예: /app/match/enter)
    // body: JSON으로 변환한 데이터
    _stompClient!.send(destination: destination, body: jsonEncode(body));
  }

  /**
   * subscribe() - 서버에서 오는 메시지 구독
   * 
   * 【 역할 】
   * - 특정 주소로 오는 메시지를 받겠다고 등록하는 메서드
   * - 매칭 결과, 채팅 메시지 수신 등에 사용
   * 
   * 【 파라미터 】
   * - destination: 구독할 주소 (예: '/queue/match/123')
   * - callback: 메시지 받으면 실행할 함수
   * 
   * 【 로직 흐름 】
   * 1. 연결 상태 확인
   * 2. 해당 주소 구독 등록
   * 3. 메시지 오면 callback 실행
   */
  void subscribe({
    required String destination,
    required Function(StompFrame) callback,
  }) {
    // 1. 연결 상태 확인
    if (!_isConnected || _stompClient == null) {
      throw Exception("WebSocket이 연결되지 않았습니다.");
    }

    // 2. 특정 주소의 메시지 구독
    // destination: 메시지를 받을 주소 (예: /queue/match/123)
    // callback: 메시지가 오면 실행할 함수
    _stompClient!.subscribe(destination: destination, callback: callback);
  }

  /**
   * disconnect() - WebSocket 연결 끊기
   * 
   * 【 역할 】
   * - 서버와의 WebSocket 연결을 종료하는 메서드
   * 
   * 【 로직 흐름 】
   * 1. StompClient 비활성화
   * 2. 연결 상태 초기화
   */
  void disconnect() {
    // 1. StompClient 비활성화 (연결 종료)
    _stompClient?.deactivate();

    // 2. 연결 상태 초기화
    _stompClient = null;
    _isConnected = false;
    debugPrint("[WebSocketClient] 연결 해제");
  }

  /**
   * _handleStompError() - STOMP 에러 처리
   * 
   * 【 역할 】
   * - STOMP 에러를 처리하는 내부 메서드
   * - 토큰 만료(401, 403) 감지 시 자동 재발급 시도
   * 
   * 【 파라미터 】
   * - frame: 에러 정보가 담긴 StompFrame
   * 
   * 【 로직 흐름 】
   * 1. 에러 메시지 확인
   * 2. 401 또는 403이면 토큰 재발급 시도
   */
  Future<void> _handleStompError(StompFrame frame) async {
    // 1. 에러 메시지에서 401, 403 확인
    String? body = frame.body;
    if (body != null && (body.contains('401') || body.contains('403'))) {
      debugPrint("[WebSocketClient] 토큰 만료 감지. 재발급 시도...");
      // 2. 토큰 재발급 후 재연결
      await reconnectWithRefresh();
    }
  }

  /**
   * reconnectWithRefresh() - 토큰 재발급 후 재연결
   * 
   * 【 역할 】
   * - 토큰을 재발급받고 WebSocket을 재연결하는 메서드
   * - api_client의 자동 재발급과 동일한 역할
   * 
   * 【 로직 흐름 】
   * 1. 기존 연결 해제
   * 2. HTTP로 토큰 재발급 요청
   * 3. 성공 시 새 토큰으로 재연결
   * 4. 실패 시 로그아웃 처리
   */
  Future<void> reconnectWithRefresh() async {
    try {
      // 1. 기존 연결 해제
      disconnect();

      // 2. HTTP로 토큰 재발급 (api_client와 동일한 로직)
      bool refreshed = await _refreshAccessToken();

      if (refreshed) {
        // 3. 재발급 성공 → 새 토큰으로 재연결
        debugPrint("[WebSocketClient] 토큰 재발급 성공. 재연결 시도...");
        await connect();
      } else {
        // 4. 재발급 실패 → 로그아웃 처리
        debugPrint("[WebSocketClient] 토큰 재발급 실패");
        _forceLogOut(ref);
      }
    } catch (e) {
      debugPrint("[WebSocketClient] 재연결 중 에러: $e");
    }
  }

  /**
   * _refreshAccessToken() - 토큰 재발급 요청
   * 
   * 【 역할 】
   * - HTTP 요청으로 서버에 토큰 재발급을 요청하는 메서드
   * - api_client의 _refreshAccessToken과 동일한 로직
   * 
   * 【 로직 흐름 】
   * 1. 리프레시 토큰 가져오기
   * 2. HTTP POST로 재발급 요청
   * 3. 새 토큰 저장
   */
  Future<bool> _refreshAccessToken() async {
    try {
      // 1. 스토리지에서 리프레시 토큰 가져오기
      String? refreshToken = await _storage.getRefreshToken();

      if (refreshToken == null) {
        debugPrint("[WebSocketClient] 리프레시 토큰이 없습니다.");
        return false;
      }

      // 2. HTTP POST로 서버에 재발급 요청
      final response = await http.post(
        Uri.parse('$baseApiUrl/api/auth/reissue'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      // 3. 재발급 성공 시 새 토큰 저장
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
   * _forceLogOut() - 강제 로그아웃 처리
   * 
   * 【 역할 】
   * - 토큰 재발급 실패 시 로그아웃 처리하는 메서드
   * - api_client의 _forceLogOut과 동일한 역할
   * 
   * 【 로직 흐름 】
   * 1. 저장된 토큰 삭제
   * 2. WebSocket 연결 해제
   */
  void _forceLogOut(Ref ref) async {
    // 1. 저장된 토큰 삭제
    await _storage.deleteAll();

    // 2. WebSocket 연결 해제
    disconnect();

    // TODO: 필요시 로그아웃 UI 처리 (WazzupToast, authControllerProvider 등)
  }
}
