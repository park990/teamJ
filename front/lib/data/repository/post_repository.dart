import 'dart:convert';

import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/dto/bbs/post_list_dto.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';

class PostRepository {
  final ApiClient _apiClient = ApiClient();


  

  // 글 목록 불러오기
  Future<List<Post>> getList() async {
    try{
      final response = await _apiClient.get(
        '/api/post/getList',
        //  나중에 바디에 게시판 타입 넣고 보내주면 게시판 나눌 수 있음
      );
      if(response.statusCode==200){
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        print('게시판 리스트 가져오기 성공${jsonResponse['message']}');
        final List<PostListDto> dtoList = (jsonResponse['data'] as List)
          .map((e) => PostListDto.fromJson(e))
          .toList();
        
        
          return dtoList.map((dto) => Post.fromListDto(dto)).toList();
        

      }else {
        print('게시판 리스트 가져오기 실패: ${response.statusCode}');
        return [];
      }

    }catch(e){
      print('글 갖고오기 에러: ${e}');
      return [];
    }
  }


  // 글 작성
  Future<bool> submitPost(String content) async{
    try{
      final response = await _apiClient.post(
        '/api/post/submit',
      body: {'content':content}
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