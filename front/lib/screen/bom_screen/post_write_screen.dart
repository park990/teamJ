import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/screen/bom_screen/controller/post_write_controller.dart';
import 'package:front/screen/bom_screen/widget/post_header.dart';
import 'package:front/screen/myPage_screen/login/controller/auth_controller.dart';
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
                padding: const EdgeInsets.fromLTRB(45, 38, 21, 20),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    PostHeader(customName: user.nickName), // 프로필 헤더

                    _buildWritingCard(state, notifier), // 카드 본체
                  ],
                ),
              ),
            ),
            _bottomBar(state.imageCount, notifier), // 하단 바
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) => (v == null || v.isEmpty) ? "내용을 입력해주세요" : null,
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
                      child: const Icon(Icons.close, size: 18, color: Colors.white),
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