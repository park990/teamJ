import "dart:convert";

import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:front/dto/social_user_dto.dart";
import "package:http/http.dart" as http;

class SignupController {
  String baseUrl = "${dotenv.env["API_URL"]}";
  String andUrl = "http://10.0.2.2:8080";
  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // 낙네임 중복 체크
  Future<bool> requestNickname(String nickName) async {
    try {
      final response = await http.post(
        Uri.parse("${andUrl}/api/signUp/check_nickName"),
        headers: _headers,
        body: jsonEncode(<String, String>{'nickName': nickName}),
      );

      if (response.statusCode == 200) {
        
        // 한글 깨짐 방지를 위해 utf8.decode 사용
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

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
  Future<bool> requestSignUp(SocialUserDto signUpDto) async {
    try {
      final response = await http.post(
        Uri.parse('${andUrl}/api/signUp/submit'),
        headers: _headers,
        body: jsonEncode(signUpDto.toJson()),
      );
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        print('회원가입 성공: ${jsonResponse['message']}'); 
        return true;
      
      // 이 아래는 정확히 왜 해야하는지 모르겟음 일단 적어두지만 나중에 다시 체크 필요
      }else if (response.statusCode == 409) {
        // 중복 등으로 인한 에러 (409 Conflict)
        print('회원가입 실패(중복): ${jsonResponse['message']}');
        return false;
      } else {
        print('서버 통신 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('회원가입 연결 실패: ${e} nullable false에 값을 넣었는지??');
      return false;
    }
  }
}
