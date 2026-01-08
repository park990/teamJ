import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/data/repository/bbs/post_repository.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:front/screen/bom_screen/provider/post_provider.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';

class PostListController extends AutoDisposeAsyncNotifier<List<Post>> {

  int _currentPage = 0;
  bool _isLast = false;      // 백엔드의 Slice.hasNext와 동기화
  bool _isFetching = false;  // 중복 요청 방지 (스크롤 중복 호출 방어)
  PostRepository get _repository =>ref.read(postRepositoryProvider);

  // notifier를 통해서 갖고오기 위해 _isLast를 갖고옴
  bool get isLastPage => _isLast;

  @override
  FutureOr<List<Post>> build() async {
  ref.watch(authControllerProvider.select((a) => a.sessionVersion));

    print('🚩 PostListController build() 실행됨!');
    _currentPage = 0;
    _isLast = false;
    _isFetching = false;

    final result = await _repository.getList(_currentPage,10);
    _isLast = result.isLast;

    return result.content;
  }

  Future<void> fetchNextPage() async{
    // 다음으로 불러올 것이 없고 진행중이라면 실행 금지
    if(_isLast||_isFetching) return;

    _isFetching = true;
    _currentPage++;

    final result = await _repository.getList(_currentPage, 10);
    _isLast = result.isLast;

    final previousState = state.value ?? [];
    state = AsyncData([...previousState, ...result.content]);

    _isFetching = false;
  }

  // 수동으로 새로고침하고 싶을 때
  Future<void> refresh() async {
    _currentPage = 0;
    _isLast = false;
    _isFetching = false;

    state = const AsyncLoading(); // 로딩 상태로 전환

    state = await AsyncValue.guard(() async {
      final result = await _repository.getList(0, 10);
      _isLast = result.isLast;
      return result.content;
    });
  }

  // 좋아요 토글 기능
  Future<void> toggleLike(int postIdx) async {
  final auth = ref.read(authControllerProvider);
  if (!auth.isLoggedIn) {
    WazzupToast.showError("로그인이 필요합니다.");
    return;
  }


  final currentState = state.value;
  if (currentState == null) return;

  final targetIndex = currentState.indexWhere((post) => post.bbsIdx == postIdx);
  if (targetIndex == -1) return;

  final targetPost = currentState[targetIndex];

  // 1. Optimistic update
  final optimisticPost = targetPost.copyWith(
    isLiked: !targetPost.isLiked,
    likeCount: targetPost.isLiked
        ? targetPost.likeCount - 1
        : targetPost.likeCount + 1,
  );

  final optimisticList = List<Post>.from(currentState);
  optimisticList[targetIndex] = optimisticPost;
  state = AsyncData(optimisticList);

  // 2. 서버 요청
  final serverResult = await _repository.toggleLike(postIdx);

  if (serverResult == null) {
    // 롤백
    state = AsyncData(currentState);
    WazzupToast.showError("세션이 만료되었거나 오류가 발생했습니다.");
    return;
  }

  // 3. 서버 기준으로 무조건 동기화
  state = AsyncData([
    for (final post in state.value!)
      if (post.bbsIdx == postIdx)
        post.copyWith(
          //서버에서 보내줘야함 이제 
          isLiked: serverResult.isLiked,
          likeCount: serverResult.likeCount,
        )
      else
        post,
  ]);
}
}
