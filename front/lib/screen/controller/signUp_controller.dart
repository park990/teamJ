import "dart:convert";

import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;








// 낙네임 중복 체크
Future<bool> requestNickname(String nickName) async {

  String baseUrl = "${dotenv.env["API_URL"]}/api/signUp/check_nickName";
        String andUrl = "http://10.0.2.2:8080/api/signUp/check_nickName";
  try {
    final response = await http.post(
      Uri.parse(andUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
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
