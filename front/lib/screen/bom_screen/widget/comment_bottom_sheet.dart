import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/screen/bom_screen/provider/comment_provider.dart';
import 'package:front/screen/bom_screen/widget/comment_card.dart';
import 'package:front/screen/bom_screen/widget/comment_input_bar.dart';
import 'package:front/theme/app_colors.dart';

class CommentBottomSheet extends ConsumerStatefulWidget {
  final int postIdx;
  const CommentBottomSheet({super.key, required this.postIdx});

  static void show(BuildContext context, int postIdx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(postIdx: postIdx),
    );
  }

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final Set<int> _expandedComments = {};
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final Color softSkyBlue = const Color(0xFFEBF5FF);

  void _toggleReplies(int index) {
    setState(() {
      if (_expandedComments.contains(index)) {
        _expandedComments.remove(index);
      } else {
        _expandedComments.add(index);
      }
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final commentsAsync = ref.watch(commentListProvider(widget.postIdx));

    if (keyboardHeight > 0 && _sheetController.isAttached) {
      _sheetController.animateTo(
        0.95,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.7],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: softSkyBlue,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(context),
              Expanded(
                child: commentsAsync.when(
                  data: (comments){
                    if(comments.isEmpty) return const Center(child: Text('첫 댓글을 남겨주세요!'));

                  // 댓글들 ...
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: 10),
                    
                    itemCount: comments.length,
                    itemBuilder: (context, index){
                      final comment= comments[index];
                      return CommentCard(comment: comment, isExpanded: _expandedComments.contains(index), onReplyTap: ()=>_toggleReplies(index));
                    },
                  );
                  },
                  // 데이터 로딩 중일 때
                loading: () => const Center(child: CircularProgressIndicator()),
                // 서버 에러 났을 때
                error: (err, stack) => Center(child: Text("에러 발생: $err")),
                ),
              ),
              CommentInputBar(postIdx: widget.postIdx),
              SizedBox(height: keyboardHeight),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("댓글", style: wazzupBarFont),
        ],
      ),
    );
  }
}