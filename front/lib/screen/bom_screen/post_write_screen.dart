import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/screen/bom_screen/controller/post_write_controller.dart';
import 'package:front/screen/bom_screen/provider/post_provider.dart';
import 'package:front/screen/bom_screen/widget/post_header.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';
import 'package:front/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class PostWriteScreen extends ConsumerStatefulWidget {
  const PostWriteScreen({super.key});

  @override
  ConsumerState<PostWriteScreen> createState() => _PostWriteState();
}

class _PostWriteState extends ConsumerState<PostWriteScreen> {
  
  // 게시글 카드와 동일한 텍스트 스타일
  final TextStyle postContentStyle = const TextStyle(
    fontSize: 14,
    height: 1.6,
    color: Color(0xFF212529),
  );

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider); // 닉네임을 위함.
    final state = ref.watch(postWriteControllerProvider); //
    final notifier = ref.read(postWriteControllerProvider.notifier);

    ref.listen(postWriteControllerProvider, (previous, next) {
      if (next.isSuccess) {
        WazzupToast.showSuccess('글 작성 완료');
        Navigator.pop(context);
      }
    });

    ref.listen(postWriteControllerProvider.select((s) => s.selectedImages), (previous, next) {
       // 폼 키가 현재 연결되어 있다면 다시 검사 수행
       notifier.formKey.currentState?.validate();
    });

    return Scaffold(
      backgroundColor: wazzupBackGround,
      appBar: AppBar(
        backgroundColor: wazzupBackGround,
        elevation: 0,
        centerTitle: true,
        title: Text('글쓰기', style: wazzupBarFont),
        actions: [
          TextButton(
            onPressed: state.isSubmitting ? null : () => notifier.submitPost(),
            child: state.isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('작성하기', style: surroundStyle.copyWith(color: wazzupButton)),
          ),
        ],
      ),
     body: Form(
      key: notifier.formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              // 🚩 1. 바깥 패딩을 (12, 5)로 수정 (45-33=12, 38-33=5)
              padding: const EdgeInsets.fromLTRB(12, 5, 21, 20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 🚩 2. 헤더는 (0,0) 위치에 먼저 배치
                  PostHeader(customName: user.nickName,
                  showMore: false,),

                  // 🚩 3. 카드 몸통을 (33, 33)만큼 밀어서 헤더가 보이게 함
                  Padding(
                    padding: const EdgeInsets.only(left: 33, top: 33),
                    child: _buildWritingCard(state, notifier),
                  ),
                ],
              ),
            ),
          ),
          _bottomBar(state.imageCount, notifier),
        ],
      ),
    ),
  );
}

  Widget _buildWritingCard(PostWriteState state, PostWriteController notifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F3F5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           const SizedBox(height: 3),
            
            TextFormField(
              controller: notifier.contentController,
              maxLines: null,
              minLines: 5,
              style: postContentStyle,
              
              decoration: InputDecoration(
                hintText: '봄밍에 공유하고싶은 이야기를 들려주세요.',
                hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.4)),
                border: InputBorder.none,
                
              ),

              // 내용 유효성 검사.
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value){
                bool isTextEmpty =  (value == null || value.trim().isEmpty);
                bool isImageEmpty = ref.read(postWriteControllerProvider).selectedImages.isEmpty;
                if(isTextEmpty && isImageEmpty){
                  return "내용을 입력해주세요";
                }
                  return null;
                }

            ),
            if (state.selectedImages.isNotEmpty) _imagePreview(state.selectedImages, notifier),
          ],
        ),
      ),
    );
  }

  

  Widget _imagePreview(List<XFile> images, PostWriteController notifier) {
    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(images[index].path), width: 100, height: 100, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4, right: 4,
                  child: GestureDetector(
                    onTap: () => notifier.removeImage(index),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _bottomBar(int count, PostWriteController notifier) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)))),
      child: Row(
        children: [
          IconButton(onPressed: () => notifier.pickImages(), icon: const Icon(Icons.photo_library_outlined)),
          const Spacer(),
          Text("$count / 10", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}