// lib/screen/bom_screen/widget/comment_bottom_sheet.dart

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
      isScrollControlled: true, // 키보드 대응을 위해 필수
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
    // 🚩 dispose 시 안전하게 처리
    if (_sheetController.isAttached) {
      _sheetController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final commentsAsync = ref.watch(commentListProvider(widget.postIdx));

    // 🚩  무한 루프 방지 및 키보드 대응 애니메이션
    if (keyboardHeight > 0 && _sheetController.isAttached) {
      // 현재 사이즈가 목표치보다 작을 때만 딱 한 번 실행되도록 프레임 예약
      if (_sheetController.size < 0.9) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_sheetController.isAttached && _sheetController.size < 0.9) {
            _sheetController.animateTo(
              0.95,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
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
                  data: (comments) {
                    // 🚩 [핵심 2] 댓글이 없을 때도 scrollController를 반드시 연결!
                    if (comments.isEmpty) {
                      return SingleChildScrollView(
                        controller: scrollController, // 👈 이걸 연결해야 시트가 움직입니다
                        physics: const AlwaysScrollableScrollPhysics(), // 👈 드래그 가능하게
                        child: Container(
                          height: 300, // 최소한의 터치 영역 확보
                          alignment: Alignment.center,
                          child: const Text('첫 댓글을 남겨주세요!'),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController, // 👈 연결
                      padding: const EdgeInsets.only(bottom: 10),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return CommentCard(
                          comment: comment,
                          isExpanded: _expandedComments.contains(index),
                          onReplyTap: () => _toggleReplies(index),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text("에러 발생: $err")),
                ),
              ),
              // 입력바
              CommentInputBar(postIdx: widget.postIdx),
              // 키보드만큼 공간 확보
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
        width: 40, height: 4,
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
      child: Text("댓글", style: wazzupBarFont),
    );
  }
}