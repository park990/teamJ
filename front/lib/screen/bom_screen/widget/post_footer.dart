// screen/bom_screen/widgets/post_footer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:front/screen/bom_screen/provider/post_provider.dart';
import 'package:front/screen/bom_screen/widget/comment_bottom_sheet.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PostFooter extends ConsumerWidget {
  final Post post;
  const PostFooter({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 7, 0, 3),
      child: Row(
        children: [
          _buildBtn(
            icon: LucideIcons.heart,
            count: post.likeCount,
            color: Colors.redAccent,
            isActive: post.isLiked,
            
            onTap: () {             
              // 여기 컨트롤러 안에 로그인 되어잇지않으면 로그인 해달라는 toast알림 있음
              ref.read(postListControllerProvider.notifier).toggleLike(post.bbsIdx);
            },
          ),
          const SizedBox(width: 15),
          _buildBtn(
            icon: LucideIcons.messageCircle,
            count: post.commentCount,
            color: Colors.blueAccent,
            isActive:  false,
            onTap: () {
              CommentBottomSheet.show(context,post.bbsIdx);
              print("클릭");
            },
          ),
          const Spacer(),
          Text(post.displayDate, style: const TextStyle(fontSize: 11, color: Color(0xFFADB5BD))),
        ],
      ),
    );
  }

  Widget _buildBtn({required IconData icon, required int count, required Color color, required VoidCallback onTap, required bool isActive}) {
    final bool isZero = count == 0;
    final IconData targetIcon = isActive ? Icons.favorite : icon;

    return Stack(
    clipBehavior: Clip.none,
    children: [
      // 실제 보이는 UI (기존과 완전히 동일)
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            targetIcon,
            size: 20,
            color: isZero
                ? const Color(0xFFDEE2E6)
                : color.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isZero
                  ? const Color(0xFFDEE2E6)
                  : const Color(0xFF495057),
            ),
          ),
        ],
      ),

      // 터치 영역만 확장 (레이아웃 계산에 전혀 관여 안 함)
      Positioned.fill(
        left: -14,
        right: -14,
        top: -12,
        bottom: -12,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
        ),
      ),
    ],
  );
}

  
}