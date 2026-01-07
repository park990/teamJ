import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/data/repository/bbs/post_repository.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:front/screen/bom_screen/provider/post_provider.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';

class PostListController
    extends AutoDisposeAsyncNotifier<List<Post>> {
  PostRepository get _repository =>
      ref.read(postRepositoryProvider);

  @override
  FutureOr<List<Post>> build() async {

    //auth상태가 바뀌면 다시 실행
    ref.watch(authControllerProvider);

    return await _repository.getList();
  }

  // 수동으로 새로고침하고 싶을 때
  Future<void> refresh() async {
    state = const AsyncLoading(); // 로딩 상태로 전환
    state = await AsyncValue.guard(() => _repository.getList());
  }

  // 좋아요 토글 기능
  Future<void> toggleLike(int postIdx) async {
    final auth =ref.read(authControllerProvider);
    if (!auth.isLoggedIn) {
      WazzupToast.showError("로그인이 필요합니다.");
      return;
    }
    //state.value = List<post>
    final currentState = state.value;
    if (currentState == null) return;

    // 1. 내 폰에서 먼저 찾아서 바꾸기 (빠른 반응)
    final targetIndex = currentState.indexWhere(
      (post) => post.bbsIdx == postIdx,
    );
    if (targetIndex == -1) return;

    // 게시글 중에서 몇번째 게시글인지 index확인
    final targetPost = currentState[targetIndex];

    // 그냥 반대로 뒤집기 (Toggle)
    final changedPost = targetPost.copyWith(
      isLiked: ! targetPost.isLiked,
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

    if (serverResult == null) {
      // 1. 롤백: 아까 바꿨던 state를 다시 원래(currentState)로 되돌림
      state = AsyncData(currentState);
      
      // 2. 사용자에게 알림
      WazzupToast.showError("세션이 만료되었거나 오류가 발생했습니다.");
      
      return; // 여기서 함수 종료
    }
   

    // 3. 만약 서버 결과가 내 폰이랑 다르면? 서버 기준으로 다시 맞춤 (동기화)
    if (serverResult != changedPost.isLiked) {
      state = AsyncData([
        for (final post in state.value!)
          if (post.bbsIdx == postIdx)
            post.copyWith(
              isLiked: serverResult,
              // 카운트는 초기 '원본' 데이터(targetPost) 기준으로 다시 계산하는 게 안전
              likeCount: serverResult
                  ? targetPost.likeCount + 1
                  : targetPost.likeCount,
            )
          else
            post,
      ]);
    }
  }
}
