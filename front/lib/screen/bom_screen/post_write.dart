import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/screen/bom_screen/controller/post_write_controller.dart';
import 'package:front/theme/app_colors.dart';

class PostWrite extends ConsumerStatefulWidget {
  const PostWrite({super.key});

  @override
  ConsumerState<PostWrite> createState() => _PostWriteState();
}

class _PostWriteState extends ConsumerState<PostWrite> {

  @override
  Widget build(BuildContext context) {
  final state = ref.watch(postWriteControllerProvider);
  final notifier = ref.read(postWriteControllerProvider.notifier);

  // 안에 정의해둔 isSuccess의 변화를 감지
  ref.listen(postWriteControllerProvider,(previous, next){
    if(next.isSuccess){
      WazzupToast.showSuccess('글 작성 완료');
      Navigator.pop(context);
    }
  });

    return Scaffold(
      backgroundColor: wazzupBackGround,
      appBar: AppBar(
        backgroundColor: wazzupBackGround,
        centerTitle: true,
        elevation: 0, // 상단 바 그림자 제거로 더 깔끔하게
        title: Text('글쓰기', style: wazzupBarFont),
        actions: [
          TextButton(
            // 로딩 중일 때는 버튼 비활성화
            onPressed: state.isSubmitting ? null : () => notifier.submitPost(),
            child: state.isSubmitting 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
                  '작성하기',
                  style: sectionTitleFont.copyWith(
                    color: wazzupButton,
                  ),
                ),
          ),
        ],
      ),
      body: Form(
        key: notifier.formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                              
                    // 1. 제목 입력란
                    _title(notifier.titleController),
                              
                    Divider(height: 1, thickness: 1, color: Colors.grey.withValues(alpha: 0.3)), // 얇은 구분선
                              
                    // 2. 내용 입력란 
                    _content(notifier.contentController),
                              
                  ],
                ),
              ),
              // 사진 넣기 등등  
              _bottom(state.imageCount)
            ],
          ),
        ),
      ),
    );
  }

  // 제목 들어가는 곳 
  TextFormField _title(TextEditingController titleController) {
    return TextFormField(
      controller: titleController,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: '제목',
        hintStyle: TextStyle(
          color: Colors.grey.withValues(alpha: 0.3),
        ),
        border: InputBorder.none, // 테두리 제거
        contentPadding: EdgeInsets.only(top: 15,bottom: 10),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {if(value==null||value.isEmpty) return "제목을 입력해 주세요";
      return null;}
    );
  }

  // 내용들어가는 곳
  TextFormField _content(TextEditingController contentController) {
    return TextFormField(
      controller: contentController,
      maxLines: null, // 줄바꿈 무제한
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: '봄밍에 공유하고싶은 이야기를 들려주세요.', // 워터마크 스타일 힌트
        hintStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.withValues(alpha: 0.3), // 아주 연하게 설정
        ),
        border: InputBorder.none,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {if(value==null||value.isEmpty) return "내용을 입력해 주세요";
      return null;}
    );
  }

  // 사진 넣기 등등
  Widget _bottom(int imageCount){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          IconButton(onPressed: (){}, icon: Icon(Icons.photo_camera_outlined,color: Colors.grey[700])),
          IconButton(onPressed: (){}, icon: Icon(Icons.photo_library_outlined, color: Colors.grey)),
          Spacer(),
          Text("${imageCount}/10",
          style: TextStyle(color: Colors.grey, fontSize: 12))
        ],
      ),
    );
  }
}
