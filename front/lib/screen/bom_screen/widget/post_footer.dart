// screen/bom_screen/widgets/post_footer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PostFooter extends ConsumerWidget {
  final Post post;
  const PostFooter({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          _buildBtn(
            icon: LucideIcons.heart,
            count: post.likeCount,
            color: Colors.redAccent,
            onTap: () {
              // 여기에 ref.read(controller).likePost(post.id) 로직 추가 가능
            },
          ),
          const SizedBox(width: 18),
          _buildBtn(
            icon: LucideIcons.messageCircle,
            count: post.commentCount,
            color: Colors.blueAccent,
            onTap: () {},
          ),
          const Spacer(),
          Text(post.displayDate, style: const TextStyle(fontSize: 11, color: Color(0xFFADB5BD))),
        ],
      ),
    );
  }

  Widget _buildBtn({required IconData icon, required int count, required Color color, required VoidCallback onTap}) {
    final bool isZero = count == 0;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 20, color: isZero ? const Color(0xFFDEE2E6) : color.withValues(alpha: 0.8)),
          const SizedBox(width: 5),
          Text('$count', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isZero ? const Color(0xFFDEE2E6) : const Color(0xFF495057))),
        ],
      ),
    );
  }
}