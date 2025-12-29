import "dart:convert";

import "package:front/dto/auth_response.dart";
import "package:front/dto/social_user_dto.dart";
import "package:front/data/data_source/remote/api_client.dart";

class SignUpRepository {
  final ApiClient apiClient;
  SignUpRepository(this.apiClient);

  // 낙네임 중복 체크
  Future<bool> requestNickname(String nickName) async {
    try {
      final response = await apiClient.post(
        '/api/signUp/check_nickName',
        body: {'nickName':nickName}
      );

      if (response.statusCode == 200) {
        // 한글 깨짐 방지를 위해 utf8.decode 사용
        final jsonResponse = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        bool isDup = jsonResponse['data'];
        String message = jsonResponse['message'];
        print('서버응답: ${message}');

        if (isDup) {
          print('이미 사용중인 닉네임');
          return true;
        } else {
          print('사용 가능한 닉네임');
          return false;
        }
      } else {
        print('서버 에러 ${response.statusCode}');
        return true;
      }
    } catch (e) {
      print('-----------------------');
      print('${e} 연결실패');
      return true;
    }
  }

  // 회원가입 요청
  Future<AuthResult> requestSignUp(SocialUserDto signUpDto,) async {

    try {
      // 요청
      final response = await apiClient.post(
        '/api/signUp/submit',
        body: signUpDto.toJson(),
      );

      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        print('회원가입 성공: ${jsonResponse['message']}');
        AuthResponse tokenData = AuthResponse.fromJson(jsonResponse['data']);

        return AuthResult(success: true, data: tokenData);

        // 중복 등으로 인한 에러 (409 Conflict)
      } else if (response.statusCode == 409) {
        print('회원가입 실패(중복): ${jsonResponse['message']}');

        return AuthResult(success: false, message: "닉네임 중복");
      } else {
        print('서버 통신 실패: ${response.statusCode}');

        return AuthResult(success: false, message: "서버 통신 오류");
      }
    } catch (e) {
      print('회원가입 연결 실패: ${e} nullable false에 값을 넣었는지??');

      return AuthResult(success: false, message: "연결 실패");
    }
  }
}
