// front/lib/data/data_source/remote/web_socket_client.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/local/wazzup_token_storage.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:http/http.dart' as http;

final webSocketClientProvider = Provider<WebSocketClient>((ref) {
  return WebSocketClient(ref);
});

class WebSocketClient {
  Ref ref;
  WebSocketClient(this.ref);

  final WazzupTokenStorage _storage = WazzupTokenStorage();
  final String baseUrl = "${dotenv.env["API_URL"]}";
  
  StompClient? _stompClient;
  bool _isConnected = false;

  // 연결 상태 확인
  bool get isConnected => _isConnected;

  // 1. 연결 시 토큰 가져와서 헤더에 넣기 (api_client와 동일한 패턴)
  Future<void> connect({Function(StompFrame)? onConnect,
  Function(StompFrame)? onError,
  Function(StompFrame)? onDisconnect, }) async {
    if (_isConnected) {
      print("[WebSocketClient] 이미 연결되어 있습니다.");
      return;
    }

    String? accessToken = await _storage.getAccessToken();
    
    if (accessToken == null) {
      print("[WebSocketClient] 토큰이 없습니다.");
      throw Exception("토큰이 없습니다.");
    }

    // WebSocket URL 구성 (ws:// 또는 wss://)
    String wsUrl = baseUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
    String endpoint = '$wsUrl/ws/matching';

    _stompClient = StompClient(
      config: StompConfig(
        url: endpoint,
        stompConnectHeaders: {  // headers → stompConnectHeaders로 변경
          'Authorization': 'Bearer $accessToken',
        },
        onConnect: (frame) {
          _isConnected = true;
          print("[WebSocketClient] 연결 성공");
          onConnect?.call(frame);
        },
        onWebSocketError: (dynamic error) {
          print("[WebSocketClient] 연결 오류: $error");
          _isConnected = false;
          onError?.call(StompFrame(command: 'ERROR', body: error.toString()));  // 65행 수정: command 추가
        },
        onStompError: (frame) {
          print("[WebSocketClient] STOMP 오류: ${frame.body}");
          _handleStompError(frame);
          onError?.call(frame);
        },
        onDisconnect: (frame) {
          _isConnected = false;
          print("[WebSocketClient] 연결 끊김");
          onDisconnect?.call(frame);
        },
        useSockJS: true,
        reconnectDelay: const Duration(seconds: 5),
        heartbeatIncoming: const Duration(seconds: 0),
        heartbeatOutgoing: const Duration(seconds: 20),
      ),
    );

    _stompClient?.activate();
  }

  // 2. 메시지 보내기
  void send(String destination, Map<String, dynamic> body) {
    if (!_isConnected || _stompClient == null) {
      print("[WebSocketClient] 연결되지 않았습니다.");
      throw Exception("WebSocket이 연결되지 않았습니다.");
    }

    _stompClient!.send(
      destination: destination,
      body: jsonEncode(body),
    );
  }

  // 3. 메시지 구독
  void subscribe({  // StompSubscription → void로 변경
    required String destination,
    required Function(StompFrame) callback,
  }) {
    if (!_isConnected || _stompClient == null) {
      throw Exception("WebSocket이 연결되지 않았습니다.");
    }

    _stompClient!.subscribe(
      destination: destination,
      callback: callback,
    );
  }

  // 4. 연결 해제
  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
    _isConnected = false;
    print("[WebSocketClient] 연결 해제");
  }

  // 5. STOMP 에러 처리 (토큰 만료 등)
  Future<void> _handleStompError(StompFrame frame) async {
    String? body = frame.body;
    if (body != null && (body.contains('401') || body.contains('403'))) {
      print("[WebSocketClient] 토큰 만료 감지. 재발급 시도...");
      await reconnectWithRefresh();
    }
  }

  // 6. 토큰 재발급 후 재연결 (api_client의 _refreshAccessToken 활용)
  Future<void> reconnectWithRefresh() async {
    try {
      // 기존 연결 해제
      disconnect();

      // 토큰 재발급 (api_client와 동일한 로직)
      bool refreshed = await _refreshAccessToken();

      if (refreshed) {
        print("[WebSocketClient] 토큰 재발급 성공. 재연결 시도...");
        // 재연결
        await connect();
      } else {
        print("[WebSocketClient] 토큰 재발급 실패");
        _forceLogOut(ref);
      }
    } catch (e) {
      print("[WebSocketClient] 재연결 중 에러: $e");
    }
  }

  // 7. 토큰 재발급 로직 (api_client와 동일)
  Future<bool> _refreshAccessToken() async {
    try {
      String? refreshToken = await _storage.getRefreshToken();

      if (refreshToken == null) {
        print("[WebSocketClient] 리프레시 토큰이 없습니다.");
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/reissue'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final data = jsonResponse['data'];

        String newAt = data['wazzupToken'] ?? '';
        String newRt = data['refreshToken'] ?? '';

        await _storage.saveTokensOnly(
          accessToken: newAt,
          refreshToken: newRt,
        );
        return true;
      } else {
        print("[WebSocketClient] 토큰 재발급 실패: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("[WebSocketClient] 토큰 재발급 중 에러: $e");
      return false;
    }
  }

  // 8. 로그아웃 처리 (api_client와 동일)
  void _forceLogOut(Ref ref) async {
    await _storage.deleteAll();
    disconnect();
    // 필요시 로그아웃 UI 처리
  }
}