// screen/bom_screen/widgets/post_card.dart
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
    // 테스트 이미지 (나중엔 post.imageUrls 사용)
    final List<String> testImages = ['asset/img/image.png', 'asset/img/image.png'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(45, 38, 21, 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 프로필과 닉네임
          PostHeader(post: post),

          // 컨테이너 
          Container(
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
              
                  const SizedBox(height: 15),

                  // 실제로 글쓸때의 줄바꿈을 맞추기 위해 letterspacing 필요.
                  Text(post.content, style: postContentStyle),
              
                  // if (testImages.isNotEmpty) PostImages(post: post, images: testImages),
                  PostFooter(post: post),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}