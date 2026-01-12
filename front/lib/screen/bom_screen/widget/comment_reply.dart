import 'package:flutter/material.dart';
import 'package:front/screen/bom_screen/model/comments_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CommentReply extends StatelessWidget {
  final Comments comment;
  const CommentReply({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTinyProfile(),
          const SizedBox(width: 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    "유저 닉네임으로 변경해야함: ${comment.usersIdx}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF495057),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(color: const Color(0xFFF1F3F5)),
                  ),
                  child: const Text(
                    "답글의 답글은 없앴고, 좋아요 위치를 조정했습니다!",
                    style: TextStyle(fontSize: 13, color: Color(0xFF212529)),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () => print("답글 좋아요 클릭"),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.heart,
                            size: 14,
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "2",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "방금 전",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTinyProfile() {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF1F3F5),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.person, size: 16, color: Color(0xFFADB5BD)),
    );
  }
}