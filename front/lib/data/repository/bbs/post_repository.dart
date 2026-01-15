import 'dart:convert';

import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/dto/api_response.dart';
import 'package:front/dto/bbs/Slice_response.dart';
import 'package:front/dto/bbs/post_list_dto.dart';
import 'package:front/screen/bom_screen/model/like_toggle_response.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:image_picker/image_picker.dart';

class PostRepository {
  final ApiClient apiClient;
  PostRepository(this.apiClient);

  // 글 목록 불러오기
  Future<SliceResponse<Post>> getList(int page, int size) async {
    try {
      final response = await apiClient.get(
        '/api/post/getList?page=$page&size=$size',
        //  나중에 바디에 게시판 타입 넣고 보내주면 게시판 나눌 수 있음
      );
      if (response.statusCode != 200) {
        print('게시판 리스트 가져오기 실패: ${response.statusCode}');
        return SliceResponse(content: [], isLast: false);
      }
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));


      return SliceResponse<Post>.fromJson(jsonResponse['data'], (item) {
      // 여기서 아이템 하나하나의 JSON 구조를 출력해봅니다.
      print('리스트 BbsIdx: ${item['bbsIdx']}'); 
      return Post.fromListDto(PostListDto.fromJson(item));
    });
      
    } catch (e) {
      print('글 갖고오기 에러: ${e}');
      return SliceResponse(content: [], isLast: false);
    }
  }

  // 글 작성
  Future<bool> submitPost(
    String content,
    List<XFile> images,
  ) async {
    try {
      final response = await apiClient.postMultipart(
        '/api/post/submit',
        fields: {'content': content},
        images: images,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        String message = jsonResponse['message'];
        print('서버응답: ${message}');
        return true;
      } else {
        print('서버에러 ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('연결실패 ${e}');
      return false;
    }
  }

  // 좋아요 토글 기능
  Future<LikeToggleResponse?> toggleLike(int postIdx) async {
    try {
      final response = await apiClient.post(
        '/api/post/likeToggle',
        body: {'bbsIdx': postIdx},
      );

      if (response.statusCode != 200) {
        print('토글 기능 불가: ${response.statusCode}');
        return null;
      }
      final jsonResponse = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      print('서버 토글 응답: ${jsonResponse['message']}');
      print('서버 전체 응답: $jsonResponse'); // 
      print('데이터 부분: ${jsonResponse['data']}');

      return LikeToggleResponse.fromJson(jsonResponse['data']);
    } catch (e) {
      print('서버 토글 응답 오류: ${e}');
      return null;
    }
  }
  // 게시글 삭제
  Future<bool>deletePost(int postIdx) async{
    try{
      final response = await apiClient.post(
        '/api/post/delete',
        body: {'postIdx': postIdx},
      );
      if(response.statusCode != 200){
        print('삭제 실패: ${response.statusCode}');
        return false;
      }
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      final apiRes = ApiResponse.fromJson(jsonResponse, null);
      if(apiRes.result=="success"){
        print("글 삭제 성공 메시지: ${apiRes.message}");
        return true;
      }else{
        print(("글 삭제 실패 메시지: ${apiRes.message} 그리고 ${response.statusCode}"));
        return false;
      }

    }catch(e){
      print('게시글 삭제 에러: ${e}');
      return false;
    }
  }
}
