import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/config/global_keys.dart';
import 'package:front/screen/myPage_screen/myPage_main.dart';
import 'package:front/data/data_source/local/wazzup_token_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // dotenv.env의 api url = 10.0.2.2:8080 으로 고정
  final String baseUrl = "${dotenv.env["API_URL"]}";
  final WazzupTokenStorage _storage = WazzupTokenStorage();

  Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<http.Response> post(String path, {Object? body}) async {
    String url = '$baseUrl$path';
    String? accessToken = await _storage.getAccessToken();

    var response = await http.post(
      Uri.parse(url),
      headers: {
        ..._baseHeaders,
        if (accessToken != null)
          'Authorization': 'Bearer $accessToken',
      },
      body: body != null ? jsonEncode(body) : null,
    );

    // 401이나 403 에러를 뱉는다면
    if (response.statusCode == 401 || response.statusCode == 403) {
      if (path.contains('/logout')) {
        print("[ApiClient] 로그아웃 중 토큰 만료 감지. 바로 로컬 로그아웃 처리.");
        _forceLogOut();
        return response;
      }

      print("[ApiClient] 401 감지! 토큰 재발급 시도...");
      bool refreshed = await _refreshAccessToken();

      if (refreshed) {
        String? newAccessToken = await _storage.getAccessToken();
        print("[ApiClient] 재발급 성공. 원래 요청 재시도: $url");

        return await http.post(
          Uri.parse(url),
          headers: {
            ..._baseHeaders,
            if (newAccessToken != null)
              'Authorization': 'Bearer $newAccessToken',
          },
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }
    return response;
  }

  Future<bool> _refreshAccessToken() async {
    try {
      // 1. 스토리지에서 리프레시 토큰 꺼내기
      String? refreshToken = await _storage.getRefreshToken();

      if (refreshToken == null) {
        print("[ApiClient] 리프레시 토큰이 없습니다.");
        return false;
      }

      // 2. 서버에 재발급 요청
      // 보통 Access Token은 헤더에, Refresh Token은 바디,
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/reissue'),
        headers: _baseHeaders,
        body: jsonEncode({'refreshToken': refreshToken}),
      );
    print('서버 응답: ${response.body}');
      if (response.statusCode == 200) {
        // 3. 재발급 성공 -> 새 토큰 저장
        final jsonResponse = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        // 서버 응답 구조가 기존 AuthResponse와 같다면
        final data = jsonResponse['data'];
        

        String newAt = data['wazzupToken'] ?? '';
        String newRt = data['refreshToken'] ?? '';

        await _storage.saveTokensOnly(
          accessToken: newAt,
          refreshToken: newRt
        );
        return true;
      } else {
        print("[ApiClient] 토큰 재발급 실패: ${response.statusCode}");
        // 실패 시 토큰 삭제 (로그아웃 처리)
        _forceLogOut();
        return false;
      }
    } catch (e) {
      print("[ApiClient] 토큰 재발급 중 에러: $e");
      return false;
    }
  }

  void _forceLogOut() async {
    await _storage.deleteAll();
    WazzupToast.showError('로그아웃 되었습니다.\n 다시 로그인 해주세요');

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MypageMain()),
      (route) => false,
    ); // 로그아웃 후  뒤로가기 누르면 로그인 안되어있어야하니까
  }






  // 겟 은 거의 안쓰니 까 내려둠 거의 안봐도 된다.

  Future<http.Response> get(String path) async {
    String url = '$baseUrl$path';
    String? token = await _storage.getAccessToken();

    var response = await http.get(
      Uri.parse(url),
      headers: {
        ..._baseHeaders,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      print("[ApiClient] 401 감지! 토큰 재발급 시도...");
      bool refreshed = await _refreshAccessToken();

      if (refreshed) {
        String? newToken = await _storage.getAccessToken();
        print("[ApiClient] 재발급 성공. 원래 요청 재시도: $url");

        return await http.get(
          Uri.parse(url),
          headers: {
            ..._baseHeaders,
            if (newToken != null)
              'Authorization': 'Bearer $newToken',
          },
        );
      } else {
        // 재발급 실패 (리프레시 토큰도 만료됨) -> 로그아웃 처리 필요
        print("[ApiClient] 리프레시 토큰도 만료됨. 재로그인 필요.");
      }
    }
    return response;
  }

  
}
