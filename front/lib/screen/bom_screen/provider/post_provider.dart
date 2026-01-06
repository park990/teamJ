import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/data/repository/post_repository.dart';
import 'package:front/screen/bom_screen/controller/post_list_controller.dart';
import 'package:front/screen/bom_screen/controller/post_write_controller.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';


// PostWriteController와 PostListController에서 PostRepository를 사용하기 위함.
final postRepositoryProvider = Provider<PostRepository>((ref) {

  // 포스트레포지토리는 apiClientProvider를 사용중.
  return PostRepository(ref.watch(apiClientProvider)); 
});

// bomMainScreen에서 PostListController를 사용하기 위함.
final postListControllerProvider = AsyncNotifierProvider.autoDispose<PostListController,List<Post>>((){


  return PostListController();
});

// PostWriteScreen에서 PostWriteController를 사용하기 위함.
final postWriteControllerProvider =NotifierProvider.autoDispose<PostWriteController, PostWriteState>(() {
      return PostWriteController();
});