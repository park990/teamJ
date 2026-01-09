import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CommentFooter extends StatelessWidget {
  final int likeCount;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onReplyTap;
  final String displayDate;

  const CommentFooter({
    super.key,
    required this.likeCount,
    required this.isLiked,
    required this.onLikeTap,
    required this.onReplyTap,
    required this.displayDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          _buildBtn(icon: LucideIcons.heart, count: likeCount, color: Colors.redAccent, isActive: isLiked, onTap: onLikeTap),
          const SizedBox(width: 15),
          _buildBtn(icon: LucideIcons.messageCircle, count: 0, label: "답글", color: Colors.blueAccent, isActive: false, onTap: onReplyTap),
          const Spacer(),
          Text(displayDate, style: const TextStyle(fontSize: 11, color: Color(0xFFADB5BD))),
        ],
      ),
    );
  }

  Widget _buildBtn({required IconData icon, required int count, String? label, required Color color, required bool isActive, required VoidCallback onTap}) {
    final IconData targetIcon = isActive ? Icons.favorite : icon;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(targetIcon, size: 16, color: (count == 0 && !isActive && label == null) ? const Color(0xFFDEE2E6) : color.withValues(alpha: 0.8)),
            const SizedBox(width: 4),
            Text(label ?? '$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: (count == 0 && label == null) ? const Color(0xFFDEE2E6) : const Color(0xFF495057))),
          ],
        ),
        Positioned.fill(
          left: -12, right: -12, top: -10, bottom: -10,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () { HapticFeedback.lightImpact(); onTap(); }, //
          ),
        ),
      ],
    );
  }
}