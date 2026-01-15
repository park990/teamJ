import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/data/repository/bbs/exception/post_delete_exception.dart';
import 'package:front/screen/bom_screen/provider/comment_provider.dart';
import 'package:front/screen/bom_screen/provider/post_provider.dart';

class CommentInputBar extends ConsumerStatefulWidget {
  final int postIdx;
  const CommentInputBar({super.key, required this.postIdx});

  @override
  ConsumerState<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends ConsumerState<CommentInputBar> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (mounted) {
        setState(() {
          _isComposing = _textController.text.trim().isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
          ]),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                  hintText: '댓글을 남겨주세요.', border: InputBorder.none),
            ),
          ),
          TextButton(
            onPressed: _isComposing ? _handleSubmitted : null,
            child: const Text("등록",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),     
    );
  }

  Future<void> _handleSubmitted() async {
    final text = _textController.text.trim();
    
    try {
      // 1. 컨트롤러 호출 (이제 bool을 리턴하지 않습니다)
      // 만약 "삭제된 게시글"이라면 여기서 에러(Exception)가 터져서 -> catch로 넘어갑니다.
      await ref.read(commentListProvider(widget.postIdx).notifier).createComment(
        content: text,
      );

      // 2. 여기까지 코드가 내려왔다는 건 "성공"했다는 뜻입니다!
      if (mounted) {
        WazzupToast.showSuccess("댓글 등록 성공");
        _textController.clear(); // 입력창 초기화
        FocusScope.of(context).unfocus(); // 키보드 닫기
      }

    } catch (e) {
      // 3. 에러 발생! (삭제된 게시글, 서버 오류 등)
      if (mounted) {

        if(e is PostDeletedException){
          WazzupToast.showError(e.toString());
          Navigator.of(context).pop(); 
          ref.invalidate(postListControllerProvider);
        }
        else {
          // 일반 에러(와이파이, 서버오류 등) -> 메시지만 띄움 (창 닫지 않음!)
          // e.toString()에서 "Exception: " 글자 제거
          String msg = e.toString().replaceAll('Exception: ', '');
          WazzupToast.showError(msg);
        }
      }
    }
  }
}