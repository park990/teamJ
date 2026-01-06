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
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 🔥 HTTP vs WebSocket: 핵심 차이
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 
 * 【 HTTP (api_client.dart) - 우편 시스템 】
 * 1. 요청 보내기: http.post(url, body: data)
 * 2. 대기: await
 * 3. 응답 받기: Response response (1번만!)
 * 4. 상태 확인: response.statusCode == 200
 * 5. 끝: 연결 종료
 * 
 * 【 WebSocket (websocket_client.dart) - 전화 통화 】
 * 1. 연결 시작: _stompClient.activate()
 * 2. 이벤트 대기: 백그라운드에서 계속 감시
 * 3. 응답 받기: 콜백 함수들 (여러 번!)
 *    - onConnect: 연결 성공 (1번)
 *    - onMessage: 메시지 수신 (여러 번)
 *    - onStompError: 에러 발생 (필요시)
 *    - onDisconnect: 연결 종료 (1번)
 * 4. 상태 확인: STOMP 명령어 (CONNECTED, ERROR 등)
 * 5. 유지: 연결 끊을 때까지 계속
 * 
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 🔥 라이브러리가 하는 일 (우리가 안 보는 부분!)
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 
 * stomp_dart_client 라이브러리는 내부에서:
 * 1. WebSocket 연결 관리
 * 2. 서버 메시지 감시 (24시간 대기 중)
 * 3. 메시지 도착 시 첫 줄 읽기:
 *    - "CONNECTED" → onConnect 콜백 호출
 *    - "ERROR" → onStompError 콜백 호출
 *    - "MESSAGE" → subscribe 콜백 호출
 * 4. 우리는 콜백만 등록, 실행은 라이브러리가!
 * 
 * HTTP의 statusCode(200, 401)처럼,
 * STOMP도 명령어(CONNECTED, ERROR)로 상태를 구분함!
 * 
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 🔥 STOMP 객체들
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 
 * StompClient: WebSocket 연결을 관리하는 객체
 * StompConfig: 연결 설정 (URL, 토큰, 콜백 함수들)
 * StompFrame: 서버가 보내는 메시지 (command, headers, body)
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
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 🔥 HTTP와의 차이점
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 
   * HTTP:
   * Response res = await http.post(...);  // ← 응답 받을 때까지 대기!
   * print(res.statusCode);                // ← 응답 받은 후 실행
   * 
   * WebSocket:
   * await connect();                      // ← 연결 준비만 완료!
   * print("다른 작업 가능");               // ← 연결 완료 전에도 실행
   * // 실제 연결 완료는 onConnect에서 알림!
   * 
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 🔥 이벤트 핸들러 (콜백) 등록
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 
   * 이벤트 핸들러는 "이럴 때 이거 실행해줘"를 등록하는 것!
   * 실제 실행은 stomp_dart_client 라이브러리가 자동으로!
   * 
   * onConnect: 서버가 "CONNECTED" 메시지 보내면 실행
   * onError: 네트워크 끊김, 타임아웃 등 발생 시 실행
   * onDisconnect: 연결 종료되면 실행
   * 
   * HTTP처럼 우리가 직접 if문으로 체크하는 게 아니라,
   * 라이브러리가 서버 메시지 보고 자동으로 판단해서 호출!
   * 
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 🔥 실행 순서 (타임라인)
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 
   * [0ms]   connect() 시작
   * [5ms]   토큰 가져오기 (await)
   * [10ms]  StompClient 생성 (콜백 등록만!)
   * [15ms]  activate() 호출 (백그라운드 연결 시작)
   * [16ms]  connect() 함수 종료 ← 여기까지만!
   * [17ms]  "다른 작업 가능" 출력 가능
   * ...
   * [100ms] 서버 응답 도착
   * [101ms] onConnect 콜백 실행! ← 이제야 실제 연결 완료!
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

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 🔥 onConnect: 연결 성공 이벤트
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //
        // 언제 실행? 서버가 "CONNECTED" 메시지 보내면!
        // 누가 실행? stomp_dart_client 라이브러리가 자동으로!
        //
        // 서버 메시지 예시:
        // CONNECTED
        // version:1.2
        // ^@
        //
        // HTTP 비유: response.statusCode == 200
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        onConnect: (frame) {
          _isConnected = true;
          debugPrint("[WebSocketClient] 연결 성공");
          onConnect?.call(frame);
        },

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 🔥 onWebSocketError: WebSocket 레벨 에러
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //
        // 언제 실행?
        // - 네트워크 끊김
        // - 서버 응답 없음 (타임아웃)
        // - DNS 에러
        //
        // STOMP 프로토콜 이전 단계의 에러!
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        onWebSocketError: (dynamic error) {
          debugPrint("[WebSocketClient] 연결 오류: $error");
          _isConnected = false;
          onError?.call(StompFrame(command: 'ERROR', body: error.toString()));
        },

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 🔥 onStompError: STOMP 레벨 에러
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //
        // 언제 실행? 서버가 "ERROR" 메시지 보내면!
        //
        // 서버 메시지 예시:
        // ERROR
        // message:Unauthorized
        //
        // 401: Token expired
        // ^@
        //
        // HTTP 비유: response.statusCode == 401 또는 403
        //
        // 백엔드가 frame.body에 "401" 또는 "403" 포함해서
        // 보내주면 _handleStompError가 자동으로 토큰 재발급!
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        onStompError: (frame) {
          debugPrint("[WebSocketClient] STOMP 오류: ${frame.body}");
          _handleStompError(frame);
          onError?.call(frame);
        },

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 🔥 onDisconnect: 연결 종료 이벤트
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //
        // 언제 실행?
        // - disconnect() 호출
        // - 서버가 연결 종료
        // - 네트워크 끊김
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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

    // 5. 연결 활성화 (백그라운드에서 연결 시작)
    // 이 함수는 여기서 종료! 연결 완료는 onConnect에서 알림!
    _stompClient?.activate();
  }

  /**
   * send() - 서버에 메시지 전송
   * 
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 🔥 HTTP와의 차이점
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 
   * HTTP:
   * Response res = await http.post(url, body: data);
   * // 보내고 응답 받을 때까지 대기
   * 
   * WebSocket:
   * send('/app/match/enter', {'genderOption': 'female'});
   * // 보내고 즉시 리턴! 응답은 subscribe 콜백으로!
   * 
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 🔥 destination 경로 규칙
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 
   * '/app'으로 시작: 서버의 @MessageMapping으로 전달
   * 예: '/app/match/enter' → @MessageMapping("/match/enter")
   * 
   * 백엔드에서 WebSocketConfig에 설정한 prefix!
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
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 🔥 "구독"의 의미
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 
   * "이 주소로 메시지 오면 알려줘!"라고 미리 등록하는 것!
   * 
   * 예시:
   * subscribe('/queue/match/123', (message) {
   *   print("매칭 결과: ${message.body}");
   * });
   * 
   * → 서버가 '/queue/match/123'로 메시지 보내면
   * → 라이브러리가 자동으로 callback 실행!
   * 
   * HTTP에는 없는 개념!
   * HTTP는 한 번 요청하면 한 번 응답 오지만,
   * WebSocket은 미리 구독해놓으면 여러 번 받을 수 있음!
   * 
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 🔥 destination 경로 규칙
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 
   * '/queue'로 시작: 개인 메시지 (1:1)
   * 예: '/queue/match/123' → 특정 유저에게만
   * 
   * '/topic'으로 시작: 브로드캐스트 (1:N)
   * 예: '/topic/room/456' → 채팅방 전체에게
   * 
   * 백엔드에서 messagingTemplate.convertAndSend()로 보냄!
   * 
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 🔥 서버 메시지가 오는 흐름
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 
   * 1. 프론트: subscribe('/queue/match/123', callback)
   * 2. 서버: messagingTemplate.convertAndSend('/queue/match/123', data)
   * 3. 라이브러리: "MESSAGE" 명령어 감지!
   * 4. 라이브러리: destination이 '/queue/match/123'인지 확인
   * 5. 라이브러리: 맞으면 callback 자동 실행!
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
   * disconnect() - 연결 종료
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
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 🔥 HTTP vs WebSocket 에러 처리
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 
   * HTTP (api_client.dart):
   * if (response.statusCode == 401) {
   *   await refreshToken();
   *   // 재시도
   * }
   * 
   * WebSocket (websocket_client.dart):
   * if (frame.body.contains('401')) {
   *   await refreshToken();
   *   await reconnect();
   * }
   * 
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 🔥 백엔드와의 약속
   * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   * 
   * 백엔드 인터셉터가 이렇게 ERROR 프레임을 보낼 것을 기대:
   * 
   * ERROR
   * message:Unauthorized
   * 
   * 401: Token expired  ← body에 "401" 포함!
   * ^@
   * 
   * 또는:
   * 
   * ERROR
   * message:Forbidden
   * 
   * 403: Invalid token  ← body에 "403" 포함!
   * ^@
   * 
   * HTTP의 response.statusCode == 401처럼,
   * WebSocket은 frame.body.contains('401')로 체크!
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
   * api_client.dart의 자동 토큰 재발급과 동일한 패턴!
   * HTTP 요청 실패 시 자동 재발급하듯,
   * WebSocket 에러 시 자동 재발급 후 재연결!
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
   * WebSocket이지만 토큰 재발급은 HTTP로!
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
   * api_client.dart의 _forceLogOut과 동일!
   */
  void _forceLogOut(Ref ref) async {
    await _storage.deleteAll();
    disconnect();
    // TODO: 로그아웃 UI 처리
  }
}
