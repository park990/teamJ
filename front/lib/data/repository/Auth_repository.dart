import 'dart:convert';

import 'package:front/dto/social_token_and_provider_dto.dart';
import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/dto/user_dto.dart';

class AuthRepository {
  ApiClient _apiClient = ApiClient();


  // 자동로그인 때 스토리지 토큰으로 유저 정보 갖고와서 상태에 저장.
  Future<UserDto?> getUserInfo() async {
    try{
      final response = await _apiClient.get('/api/auth/me');

      if(response.statusCode==200){
        final Map<String, dynamic> decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        
        // ApiResponse의 'data' 부분을 DTO로 바로 변환!
        if (decodedResponse['data'] != null) {
          return UserDto.fromJson(decodedResponse['data']);
        }
        return null;
      }else{
        print('유저 정보 불러오기 실패: ${response.statusCode}');
        return null;
      }
    }catch(e){
      print('유저 정보 통신 오류: ${e}');
      return null;
    }
  }


  // 로그아웃 wazzupToken 삭제
  Future<bool> wazzupLogout() async {
    try {
      final response = await _apiClient.post(
        '/api/auth/logout',
      );
      if (response.statusCode == 200) {
        print('로그아웃 성공(wazzupToken Deleted)');
        return true;
      } else {
        print('로그아웃 실패 ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('서버에러 발생 ${e}');
      return false;
    }
  }

  Future<Map<String, dynamic>?> sendSocialLogin(SocialTokenAndProviderDto dto) async {
    try {
      String endPoint = "";
      // dto 안에 있는 provider를 꺼내서 확인 (null 체크)
      if (dto.provider == null || dto.socialToken == null) {
        print("토큰이나 플랫폼 정보가 없슴.");
        return null;
      }

      switch (dto.provider) {
        case 'KAKAO':
          endPoint = '/api/auth/kakao';
          break;
        case 'NAVER':
          endPoint = '/api/auth/naver';
          break;
        case 'APPLE':
          endPoint = '/api/auth/apple';
          break;
        case 'GOOGLE':
          endPoint = '/api/auth/google';
          break;
        default:
          print("알 수 없는 플랫폼입니다.");
          return null;
      }

      final response = await _apiClient.post(
        endPoint,
        body: dto,
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
