
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repository/post_repository.dart';
import 'package:front/screen/bom_screen/controller/post_list_controller.dart';

final postRepositoryProvider = Provider((ref) => PostRepository());

class PostWriteState {
  final int imageCount;
  final bool isSubmitting;
  final bool isSuccess;

  PostWriteState({
    this.imageCount = 0,
    this.isSubmitting = false,
    this.isSuccess=false,
  });

  PostWriteState copyWith({
    int? imageCount,
    bool? isSubmitting,
    bool? isSuccess,
  }) {
    return PostWriteState(
      imageCount: imageCount ?? this.imageCount,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

final postWriteControllerProvider =NotifierProvider.autoDispose<PostWriteController, PostWriteState>(() {
      return PostWriteController();
    });

class PostWriteController extends AutoDisposeNotifier<PostWriteState> {
  PostRepository get _repository => ref.read(postRepositoryProvider);

  final formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController contentController;

  @override
  PostWriteState build() {
    titleController = TextEditingController();
    contentController = TextEditingController();

    ref.onDispose((){
      titleController.dispose();
      contentController.dispose();
    });
    return PostWriteState();
  }

  // 게시글 작성하기 버튼
  Future<void> submitPost() async {
    if(!formKey.currentState!.validate()) return;

    // 누른순간 submitting = true로 설정.
    state = state.copyWith(isSubmitting: true);
    try{
      final title = titleController.text;
      final content= contentController.text;


      final result = await _repository.submitPost(title, content);
      print(result);

      await Future.delayed(const Duration(seconds: 1));
      if(result){
      print('글 등록 완료${title}');

      // 글쓰기 성공시 목록 프로바이더 무효화 즉 BomMain으로 돌아왓을 때 리스트가 서버에서 최신글을 불러옴
      ref.invalidate(postListControllerPorvider);

      // 등록후 pop을 실행하는데 그전에 isSubmitting = false로 두고 isSuccess: ture로
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      }else{
        print('${result} 글 등록 실패');
        state = state.copyWith(isSubmitting: false);
      }
      
    }catch(e){
      print('글 등록중 에러 발생${e}');
      state = state.copyWith(isSubmitting: false);
    }
  }

  void setImageCount(int count){
    state = state.copyWith(imageCount: count);
  }
}
