import 'package:flutter/material.dart';
import 'package:front/screen/bom_screen/model/comments_model.dart';
import 'package:front/screen/bom_screen/widget/post_header.dart';
import 'package:front/screen/bom_screen/widget/comment_footer.dart';
import 'package:front/theme/app_colors.dart';

class CommentCard extends StatelessWidget {
  final Comments comment;
  final bool isExpanded;
  final VoidCallback onReplyTap;

  const CommentCard({
    super.key,
    required this.comment,
    required this.isExpanded,
    required this.onReplyTap,
  });

  @override
Widget build(BuildContext context) {
  return Padding(
    

    padding: const EdgeInsets.fromLTRB(12, 5, 21, 12),
    child: Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. 헤더: 이제 PostHeader 내부가 0,0 이므로 Stack의 시작점에 딱 붙습니다.
            // 결과적으로 화면 전체 기준으로는 (12, 5) 위치에 그려집니다.
            PostHeader(
              customName: comment.nickName, 
              authorIdx: comment.usersIdx,
              showMore: true
            ),


            Padding(
              padding: const EdgeInsets.only(left: 33, top: 33), 
              child: Container(
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
                      Text("${comment.content}", style: postContentStyle),
                      CommentFooter(
                        likeCount: 0,
                        isLiked: false,
                        displayDate: "3분 전",
                        onLikeTap: () => print("좋아요"),
                        onReplyTap: onReplyTap,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}