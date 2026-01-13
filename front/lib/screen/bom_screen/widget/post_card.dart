import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:front/screen/bom_screen/widget/post_footer.dart';
import 'package:front/screen/bom_screen/widget/post_header.dart';
import 'package:front/screen/bom_screen/widget/post_images.dart';
import 'package:front/theme/app_colors.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
Widget build(BuildContext context, WidgetRef ref) {
  return Padding(

    padding: const EdgeInsets.fromLTRB(12, 5, 21, 12), 
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. 헤더를 (0, 0)으로 배치하여 클릭 영역 확보
        PostHeader(post: post),

        // 2. 본문 컨테이너를 기존 위치만큼 안쪽으로 밀어줌
        Padding(
          padding: const EdgeInsets.only(left: 33, top: 33),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFF1F3F5), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.content.trim().isNotEmpty)
                    Text(post.content, style: postContentStyle),
                  PostImages(post: post, images: post.imageUrls),
                  if (post.imageUrls.isNotEmpty) const SizedBox(height: 5),
                  PostFooter(post: post),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}