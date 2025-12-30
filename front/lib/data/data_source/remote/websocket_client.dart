// front/lib/data/data_source/remote/web_socket_client.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/data/data_source/local/wazzup_token_storage.dart';
// WebSocket 라이브러리 import (예: stomp, web_socket_channel 등)

class WebSocketClient {
  final WazzupTokenStorage _storage = WazzupTokenStorage();
  final String baseUrl = "${dotenv.env["API_URL"]}";
  
  // WebSocket 클라이언트 인스턴스
  // StompClient? _stompClient;
  
  // 1. 연결 시 토큰 가져와서 헤더에 넣기
  Future<void> connect() async {
    String? accessToken = await _storage.getAccessToken();
    
    // WebSocket 연결 (헤더에 토큰 포함)
    // _stompClient = StompClient(
    //   config: StompConfig(
    //     url: 'ws://$baseUrl/ws/matching',
    //     headers: {
    //       if (accessToken != null)
    //         'Authorization': 'Bearer $accessToken',  // ← api_client와 같은 패턴!
    //     },
    //     // ...
    //   ),
    // );
  }
  
  // 2. 메시지 보내기
  void send(String destination, Map<String, dynamic> body) {
    // _stompClient?.send(destination, body: jsonEncode(body));
  }
  
  // 3. 토큰 재발급 후 재연결 (필요 시)
  Future<void> reconnectWithRefresh() async {
    // 토큰 재발급 로직 (api_client의 _refreshAccessToken 활용)
    // disconnect();
    // connect(); // 새 토큰으로 재연결
  }
}