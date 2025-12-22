import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repository/post_repository.dart';
import 'package:front/screen/bom_screen/controller/post_write_controller.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';

final postListControllerPorvider = AsyncNotifierProvider.autoDispose<PostListController,List<Post>>((){
  return PostListController();
});

class PostListController extends AutoDisposeAsyncNotifier<List<Post>>{
  PostRepository get _repository => ref.read(postRepositoryProvider);

  @override
  FutureOr<List<Post>> build()  async {
    return await _repository.getList();
  }

  // 나중에 리스트를 수동으로 새로고침하고 싶을 때 부르는 함수
  Future<void> refresh() async {
    state = const AsyncLoading(); // 로딩 상태로 전환
    state = await AsyncValue.guard(() => _repository.getList());
  }
}

