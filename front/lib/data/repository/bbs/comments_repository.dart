
import 'dart:convert';

import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/dto/api_response.dart';
import 'package:front/dto/bbs/Slice_response.dart';
import 'package:front/screen/bom_screen/model/comments_model.dart';

class CommentsRepository {
  final ApiClient apiClient;
  CommentsRepository(this.apiClient);

  Future<SliceResponse<Comments>> getComments({
  required int postIdx,
  required int page,
  int size = 15,
}) async {
  try {
    final response = await apiClient.get(
      '/api/comments/$postIdx?page=$page&size=$size',
    );

    if (response.statusCode != 200) {
      throw Exception('댓글 불러오기 실패 (상태코드: ${response.statusCode})');
    }

    final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
    final data = jsonResponse['data'];
    print('${data}댓글들이 도착하였다');

    if(data==null){
      return SliceResponse<Comments>(content: [], isLast: true);
    }

    final List<Comments> comments = (data['content'] as List? ?? [])
        .map((e) => Comments.fromJson(e))
        .toList();

    return SliceResponse<Comments>(
      content: comments,
      isLast: data['hasNext'],
    );
  } catch (e) {
    throw Exception('getComments error: $e');
  }
}
  Future<bool> saveComments(Comments dto) async{
    try{
      final response = await apiClient.post(
        '/api/comments/submit',
        body: dto.toJson(),
      );
      if(response.statusCode != 200){
        print('댓글 등록 실패: ${response.statusCode}');
        return false;
      }

      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      final apiRes = ApiResponse.fromJson(jsonResponse, null);

      if (apiRes.result == "success") {
        print("성공 메시지: ${apiRes.message}");
        return true;
      } else {
        print("실패 사유: ${apiRes.message} 그리고 ${response.statusCode}");
        return false;
      }

    }catch(e){
      print('댓글 등록 에러: ${e}');
      return false;
    }
  }
  
}