
import 'dart:convert';

import 'package:front/data/data_source/remote/api_client.dart';
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
      throw Exception('댓글 불러오기 실패');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes));
    final data = json['data'];

    final List<Comments> comments =
        (data['content'] as List)
            .map((e) => Comments.fromJson(e))
            .toList();

    return SliceResponse<Comments>(
      content: comments,
      isLast: data['last'],
    );
  } catch (e) {
    throw Exception('getComments error: $e');
  }
}
}