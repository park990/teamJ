import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repository/post_repository.dart';
import 'package:front/screen/bom_screen/provider/post_provider.dart';
import 'package:image_picker/image_picker.dart';

class PostWriteState {
  final List<XFile> selectedImages;
  final int imageCount;
  final bool isSubmitting;
  final bool isSuccess;

  PostWriteState({
    this.selectedImages= const [],
    this.imageCount = 0,
    this.isSubmitting = false,
    this.isSuccess=false,
  });

  PostWriteState copyWith({
    List<XFile>? selectedImages,
    int? imageCount,
    bool? isSubmitting,
    bool? isSuccess,
  }) {
    return PostWriteState(
      selectedImages: selectedImages ?? this.selectedImages,
      imageCount: imageCount ?? this.imageCount,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}



class PostWriteController extends AutoDisposeNotifier<PostWriteState> {
  PostRepository get _repository => ref.read(postRepositoryProvider);

  final formKey = GlobalKey<FormState>();

  final imagePicker = ImagePicker();

  late final TextEditingController contentController;

  @override
  PostWriteState build() {
    contentController = TextEditingController();
    ref.onDispose((){
      contentController.dispose();
    });
    return PostWriteState();
  }

  // 사진선택
  Future<void> pickImages() async{
    try{
      final List<XFile> pickedImages = await imagePicker.pickMultiImage(
        maxWidth: 1024,
        imageQuality: 60,
      );
        if(pickedImages.isNotEmpty){
          final updatedList = [...state.selectedImages, ...pickedImages].take(10).toList();

          state= state.copyWith(
            selectedImages: updatedList,
            imageCount: updatedList.length,
          );
        }
    }catch(e){
      print('이미지 선택 에러: ${e}');
    }

  }
    void removeImage(int index){
      final newList = List<XFile>.from(state.selectedImages)..removeAt(index);
      state = state.copyWith(
        selectedImages: newList,
        imageCount: newList.length,
      );
    }

  // 게시글 작성하기 버튼
  Future<void> submitPost() async {
      final content = contentController.text.trim();
      final images = state.selectedImages;

    if(images.isEmpty){ 
      if(!formKey.currentState!.validate()) return;
    }else{
      formKey.currentState?.save();
    }
    // 누른순간 submitting = true로 설정.
    state = state.copyWith(isSubmitting: true);
    try{

      final result = await _repository.submitPost(content, images);
      
      print(result);

      if(result){
      print('글 등록 완료${content}');

      // 글쓰기 성공시 목록 프로바이더 무효화 즉 BomMain으로 돌아왓을 때 리스트가 서버에서 최신글을 불러옴
      ref.invalidate(postListControllerProvider);

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
