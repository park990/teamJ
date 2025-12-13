import "dart:convert";

import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:front/dto/sign_up_dto.dart";
import "package:http/http.dart" as http;

class SignupController {

  String baseUrl = "${dotenv.env["API_URL"]}";
  String andUrl = "http://10.0.2.2:8080";
  final Map<String,String> _headers= {'Content-Type': 'application/json; charset=UTF-8',};


// 낙네임 중복 체크
Future<bool> requestNickname(String nickName) async {

  try {
    final response = await http.post(
      Uri.parse("${andUrl}/api/signUp/check_nickName"),
      headers: _headers,
      body: jsonEncode(<String, String>{'nickName': nickName}),
    );

    if (response.statusCode == 200) {
      print('서버응답: ${response.body}');

      if (response.body == 'true') {
        print('이미 사용중인 닉네임');
        return true;
      } else {
        print('사용가능');
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
Future<bool> requestSignUp(SignUpDTO signUpDto) async {
  try{
    final response = await http.post(
      Uri.parse('${andUrl}/api/signUp/submit'),
      headers: _headers,
      body: jsonEncode(signUpDto.toJson()),
    );
    if(response.statusCode==200||response.statusCode==201){
      print('회원가입 성공: ${response.body}');
      return true;
    }else{
      print('회원가입 실패: ${response.statusCode}');
      return false;
    }
  }catch(e){
    print('회원가입 연결 실패: ${e}');
    return false;
  }
}

}