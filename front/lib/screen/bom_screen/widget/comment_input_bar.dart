import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/screen/bom_screen/provider/comment_provider.dart';

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
    
   
    final success = await ref.read(commentListProvider(widget.postIdx).notifier).createComment(
      content: text,
    );

    if (success && mounted) {
      WazzupToast.showSuccess("댓글 등록 성공");
      _textController.clear(); // 전송 성공 시 입력창 초기화
      FocusScope.of(context).unfocus(); // 키보드 닫기 (선택 사항)
      
    }
  }
}