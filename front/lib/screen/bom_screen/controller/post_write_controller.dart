
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repository/post_repository.dart';

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
  late final PostRepository _repository;
  final formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController contentController;

  @override
  PostWriteState build() {
    _repository = ref.read(postRepositoryProvider);

    titleController = TextEditingController();
    contentController = TextEditingController();

    ref.onDispose((){
      titleController.dispose();
      contentController.dispose();
    });
    return PostWriteState();
  }

  Future<void> submitPost() async {
    if(!formKey.currentState!.validate()) return;
    state = state.copyWith(isSubmitting: true);
    try{
      final title = titleController.text;
      final content= contentController.text;

      final result = await _repository.submitPost(title, content);
      print(result);

      await Future.delayed(const Duration(seconds: 1));

      print('글 등록 완료${title}');
      
      state = state.copyWith(isSubmitting: false, isSuccess:true);
    }catch(e){
      print('글 등록중 에러 발생${e}');
    }
  }

  void setImageCount(int count){
    state = state.copyWith(imageCount: count);
  }
}
