import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/screen/bom_screen/widget/comment_card.dart';
import 'package:front/screen/bom_screen/widget/comment_input_bar.dart';
import 'package:front/theme/app_colors.dart';

class CommentBottomSheet extends ConsumerStatefulWidget {
  final int bbsIdx;
  const CommentBottomSheet({super.key, required this.bbsIdx});

  static void show(BuildContext context, int bbsIdx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(bbsIdx: bbsIdx),
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

    if (keyboardHeight > 0) {
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
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 10),
                  itemCount: 20,
                  itemBuilder: (context, index) => CommentCard(
                    index: index,
                    isExpanded: _expandedComments.contains(index),
                    onReplyTap: () => _toggleReplies(index),
                  ),
                ),
              ),
              const CommentInputBar(),
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