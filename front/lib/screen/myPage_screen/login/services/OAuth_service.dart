import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OauthService {
  String baseUrl = "${dotenv.env["API_URL"]}";
  String androidUrl = 'http://10.0.2.2:8080';
  Map<String,String> headers ={"Content-Type": "application/json"}; 

  Future<Map<String,dynamic>?> sendSocialLogin(String accessToken,String platform) async {
    try{
      String endPoint="";

      switch (platform) {
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
      final url =Uri.parse('${androidUrl}${endPoint}');

      print('백으로 전송 주소는: ${androidUrl}${endPoint}');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          "token": accessToken,
        }),
      );
      if(response.statusCode == 200){
        return jsonDecode(utf8.decode(response.bodyBytes));
      }else{
        print('서버오류: ${response.statusCode}');
        return null;
      }
    }catch(e){
      print('통신 오류 발생: ${e}');
      return null;
    }
  }
}