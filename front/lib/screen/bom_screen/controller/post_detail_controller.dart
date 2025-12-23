// import 'dart:async';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:front/data/repository/post_repository.dart';
// import 'package:front/screen/bom_screen/controller/post_write_controller.dart';
// import 'package:front/screen/bom_screen/model/post_model.dart';

// final postDeatilControllerProvider = AsyncNotifierProvider.family
//     .autoDispose<PostDetailController, Post, int>(() {
//       return PostDetailController();
//     });

// class PostDetailController
//     extends AutoDisposeFamilyAsyncNotifier<Post, int> {
//   PostRepository get _repository => ref.read(postRepositoryProvider);

//   @override
//   FutureOr<Post> build(int arg) async {
//     return await _repository.getPostDetail(arg);
//   }
// }
