import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repository/post_repository.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:front/screen/bom_screen/provider/post_provider.dart';



class PostListController extends AutoDisposeAsyncNotifier<List<Post>>{
  PostRepository get _repository => ref.read(postRepositoryProvider);

  @override
  FutureOr<List<Post>> build()  async {
    return await _repository.getList();
  }

  // 수동으로 새로고침하고 싶을 때 
  Future<void> refresh() async {
    state = const AsyncLoading(); // 로딩 상태로 전환
    state = await AsyncValue.guard(() => _repository.getList());
  }


  
}

