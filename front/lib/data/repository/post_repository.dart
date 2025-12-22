import 'dart:convert';

import 'package:front/data/data_source/remote/api_client.dart';

class PostRepository {
  final ApiClient _apiClient = ApiClient();

  Future<bool> submitPost(String title, String content) async{
    try{
      final response = await _apiClient.post(
        '/api/post/submit',
      body: {'title':title, 'content':content}
      );

      if(response.statusCode==200){
        final jsonResponse = jsonDecode(
          utf8.decode(response.bodyBytes)
        );

      String message = jsonResponse['message'];
      print('서버응답: ${message}');
      return true;
      }
      else{
        print('서버에러 ${response.statusCode}');
        return false;
      }
    }catch(e){
      print('연결실패 ${e}');
      return false;
    }
  }

}