import 'package:flutter/material.dart';
import 'package:front/screen/bom_screen/widget/comment_reply.dart';
import 'package:front/screen/bom_screen/widget/post_header.dart';
import 'package:front/screen/bom_screen/widget/comment_footer.dart';
import 'package:front/theme/app_colors.dart';

class CommentCard extends StatelessWidget {
  final int index;
  final bool isExpanded;
  final VoidCallback onReplyTap;

  const CommentCard({
    super.key,
    required this.index,
    required this.isExpanded,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(45, 38, 21, 12),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              PostHeader(customName: "유저 $index", showMore: true),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFF1F3F5), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 15, 18, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("답글을 누르면 아래로 툭 열립니다!", style: postContentStyle),
                      CommentFooter(
                        likeCount: index,
                        isLiked: false,
                        displayDate: "3분 전",
                        onLikeTap: () => print("좋아요"),
                        onReplyTap: onReplyTap,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(left: 20, top: 12),
                    child: Column(
                      children: List.generate(2, (i) => CommentReply(index: i)),
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}