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
    // 1. Auth 전체 상태를 지켜봅니다.
  final authResolved = ref.watch(authControllerProvider.select((s) => s.authResolved)
  );

  if (!authResolved) {
    return [];
  }

    print('🚩 PostListController build() 실행됨');

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
   bool isLoggedIn = ref.read(authControllerProvider).isLoggedIn;
   if(!isLoggedIn){
    WazzupToast.showError("로그인 해주세요");
    return;
   }

  final prev = state.value!;
  
  // 1. UI 즉시 반영
  state = AsyncData(
    prev.map((p) {
      if (p.bbsIdx == postIdx) {
        return p.copyWith(
          isLiked: !p.isLiked,
          likeCount: p.isLiked ? p.likeCount - 1 : p.likeCount + 1,
        );
      }
      return p;
    }).toList(),
  );

  // 2. 서버 반영
  final result = await _repository.toggleLike(postIdx);

  // 3. 실패 시 롤백
  if (result == null) {
    state = AsyncData(prev);
    WazzupToast.showError("좋아요 처리 실패");
  }
}
}
