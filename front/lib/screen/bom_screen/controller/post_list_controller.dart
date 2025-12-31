import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repository/post_repository.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:front/screen/bom_screen/provider/post_provider.dart';

class PostListController
    extends AutoDisposeAsyncNotifier<List<Post>> {
  PostRepository get _repository =>
      ref.read(postRepositoryProvider);

  @override
  FutureOr<List<Post>> build() async {
    return await _repository.getList();
  }

  // 수동으로 새로고침하고 싶을 때
  Future<void> refresh() async {
    state = const AsyncLoading(); // 로딩 상태로 전환
    state = await AsyncValue.guard(() => _repository.getList());
  }

  // 좋아요 토글 기능
  // screen/bom_screen/controller/post_list_controller.dart
  Future<void> toggleLike(int postIdx) async {
    final currentState = state.value;
    if (currentState == null) return;

    // 1. 내 폰에서 먼저 찾아서 바꾸기 (빠른 반응)
    final targetIndex = currentState.indexWhere(
      (post) => post.bbsIdx == postIdx,
    );
    if (targetIndex == -1) return;

    final targetPost = currentState[targetIndex];

    // 그냥 반대로 뒤집기 (Toggle)
    final changedPost = targetPost.copyWith(
      isLiked: !targetPost.isLiked,
      likeCount: targetPost.isLiked
          ? targetPost.likeCount - 1
          : targetPost.likeCount + 1,
    );

    // 리스트 갈아끼우기 (화면 갱신)
    final newList = List<Post>.from(currentState);
    newList[targetIndex] = changedPost;
    state = AsyncData(newList);

    // 2. 서버에 진짜 보내기
    final serverResult = await _repository.toggleLike(postIdx);

    // 3. 만약 서버 결과가 내 폰이랑 다르면? 서버 기준으로 다시 맞춤 (동기화)
    if (serverResult != null && serverResult != changedPost.isLiked) {
      newList[targetIndex] = changedPost.copyWith(
        isLiked: serverResult,
        
        likeCount: serverResult
            ? changedPost.likeCount + 1
            : changedPost.likeCount - 1,
      );
      state = AsyncData(newList);
    }
  }
}
