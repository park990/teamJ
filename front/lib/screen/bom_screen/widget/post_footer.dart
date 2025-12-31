// screen/bom_screen/widgets/post_footer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:front/screen/bom_screen/provider/post_provider.dart';
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
              bool isLoggedIn = ref.read(authControllerProvider).isLoggedIn;
              if(isLoggedIn){
              ref.read(postListControllerProvider.notifier).toggleLike(post.bbsIdx);
              }
              else{
                WazzupToast.showError("로그인이 필요합니다");
              }
            },
          ),
          const SizedBox(width: 15),
          _buildBtn(
            icon: LucideIcons.messageCircle,
            count: post.commentCount,
            color: Colors.blueAccent,
            isActive:  false,
            onTap: () {},
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

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(targetIcon, size: 20, color: isZero ? const Color(0xFFDEE2E6) : color.withValues(alpha: 0.8)),
          const SizedBox(width: 5),
          Text('$count', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isZero ? const Color(0xFFDEE2E6) : const Color(0xFF495057))),
        ],
      ),
    );
  }

  
}