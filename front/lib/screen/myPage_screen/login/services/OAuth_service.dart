import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/dto/social_token_and_provider_dto.dart';
import 'package:front/service/wazzup_token_storage.dart';
import 'package:http/http.dart' as http;

class OauthService {
  String baseUrl = "${dotenv.env["API_URL"]}";
  String androidUrl = 'http://10.0.2.2:8080';
  Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  // 로그아웃 wazzupToken 삭제
  Future<bool> wazzupLogout() async {
    try {
      final storage = WazzupTokenStorage();
      String? wazzupToken = await storage.getToken();

      if (wazzupToken != null) {
        final url = Uri.parse('${androidUrl}/api/oauth/logout');
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer ${wazzupToken}',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          print('로그아웃 성공(wazzupToken Deleted)');
          return true;
        } else {
          print('로그아웃 실패 ${response.statusCode}');
          return false;
        }
      } else {
        // 존재하지 않는다면 이미 로그아웃 된 상태
        print('토큰이 존재하지 않음');
        return true;
      }
    } catch (e) {
      print('서버에러 발생 ${e}');
      return false;
    }
  }

  Future<Map<String, dynamic>?> sendSocialLogin(
    SocialTokenAndProviderDto dto,
  ) async {
    try {
      String endPoint = "";
      // dto 안에 있는 provider를 꺼내서 확인 (null 체크)
      if (dto.provider == null || dto.socialToken == null) {
        print("토큰이나 플랫폼 정보가 없슴.");
        return null;
      }

      switch (dto.provider) {
        case 'KAKAO':
          endPoint = '/api/oauth/kakao';
          break;
        case 'NAVER':
          endPoint = '/api/oauth/naver';
          break;
        case 'APPLE':
          endPoint = '/api/oauth/apple';
          break;
        case 'GOOGLE':
          endPoint = '/api/oauth/google';
          break;
        default:
          print("알 수 없는 플랫폼입니다.");
          return null;
      }
      final url = Uri.parse('${androidUrl}${endPoint}');

      print('백으로 전송 주소는: ${androidUrl}${endPoint}');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(dto.toJson()),
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        print('서버오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('통신 오류 발생: ${e}');
      return null;
    }
  }
}
