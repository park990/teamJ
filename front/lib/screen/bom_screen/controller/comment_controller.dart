// screen/bom_screen/controller/comment_controller.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/screen/bom_screen/model/comments_model.dart';
import 'package:front/screen/bom_screen/provider/comment_provider.dart';

class CommentController extends FamilyAsyncNotifier<List<Comments>, int> {
  
  @override
  FutureOr<List<Comments>> build(int arg) async {
    // 바텀시트 열릴 때 arg(postIdx)를 사용해 첫 데이터를 가져옵니다.
    return await _fetchComments(page: 0);
  }

  // 데이터 조회 로직 (조회는 내부적으로 사용)
  Future<List<Comments>> _fetchComments({required int page}) async {
    final repo = ref.read(commentsRepositoryProvider);
    final response = await repo.getComments(
      postIdx: arg, // arg가 곧 postIdx
      page: page,
    );
    return response.content;
  }

  // 댓글 등록 로직 (UI에서 호출)
  Future<bool> createComment({required String content, int? parentIdx}) async {
    if (content.trim().isEmpty) return false;

    final repo = ref.read(commentsRepositoryProvider);
    final commentModel = Comments(
      bbsIdx: arg,
      content: content,
      parentIdx: parentIdx,
    );

    final success = await repo.saveComments(commentModel);
    
    if (success) {
      // 성공 시 상태를 무효화하여 리스트를 새로고침
      ref.invalidateSelf(); 
    }
    return success;
  }
}