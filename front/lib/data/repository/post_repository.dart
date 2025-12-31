import 'dart:convert';

import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/dto/bbs/post_list_dto.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:image_picker/image_picker.dart';

class PostRepository {
  final ApiClient apiClient;
  PostRepository(this.apiClient);

  // 글 목록 불러오기
  Future<List<Post>> getList() async {
    try{
      final response = await apiClient.get(
        '/api/post/getList',
        //  나중에 바디에 게시판 타입 넣고 보내주면 게시판 나눌 수 있음
      );
      if(response.statusCode==200){
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        print('게시판 리스트 가져오기 성공${jsonResponse['message']}');

        final List<PostListDto> dtoList =
         (jsonResponse['data'] as List).map((e) => PostListDto.fromJson(e)).toList();
        
        
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
  Future<bool> submitPost(String content, List<XFile> images) async{
    try{
      final response = await apiClient.postMultipart(
        '/api/post/submit',
        fields:{ 'content': content},
        images: images,
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

  // 좋아요 토글 기능
  Future<bool?> toggleLike(int postIdx) async{
    try{
      final response = await apiClient.post(
        '/api/post/likeToggle',
        body:{'bbsIdx': postIdx},
      );

      if(response.statusCode==200){
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final bool serverIsliked = jsonResponse['data'];

        print('서버 토글 응답: ${serverIsliked}');
        return serverIsliked;
      }
    }catch(e){
      print('서버 토글 응답 오류: ${e}');
      return null;
    }
  }



}