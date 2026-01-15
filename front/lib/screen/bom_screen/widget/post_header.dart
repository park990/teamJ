// lib/screen/bom_screen/widget/post_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:front/screen/bom_screen/provider/post_provider.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';
import 'package:front/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PostHeader extends ConsumerWidget {
  final Post? post;          // 게시글 데이터 (카드에서 쓸 때)
  final String? customName; // 글쓰기 화면처럼 데이터가 없을 때 쓸 이름
  final bool showMore;      // 더보기 버튼을 보여줄지 여부
  final int? authorIdx;
  

  const PostHeader({
    super.key,
    this.post,
    this.customName,
    this.authorIdx,
    this.showMore = true, // 기본값은 보여줌
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int postIdx = post?.postIdx ?? 0 ;
    final authState = ref.watch(authControllerProvider);
    final myIdx = authState.userIdx;
    final writerIdx = post?.userIdx ?? authorIdx;

    final bool isMe = authState.isLoggedIn && (myIdx==writerIdx);

    
    final String authorName = post?.author ?? customName ?? "익명";

    return Positioned(
    left: 0,
    top: 0,
    right: 0, 
    child: Row(
      children: [
        _buildProfileImage(),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                Text(authorName, style: postNicknameStyle),
                const Spacer(),
                if (showMore)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showModernActionSheet(context,isMe,authorName,ref, postIdx),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0), // 클릭 영역을 더 넉넉히
                      child: Icon(
                        LucideIcons.moreHorizontal,
                        size: 20,
                        color: Color(0xFFADB5BD),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  // 프로필 사진 위젯
  Widget _buildProfileImage() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF1F3F5),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: const Icon(Icons.person, size: 24, color: Color(0xFFADB5BD)),
    );
  }

  // 모던 액션 시트 (신고하기, 차단하기)
  void _showModernActionSheet(BuildContext context, bool isMe, String authorName,WidgetRef ref,int postIdx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            if (isMe) ...[
            // 🚩 내 글일 때 보여줄 메뉴
            _actionItem(
              title: '수정하기',
              color: const Color(0xFF495057),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF1F3F5)),
            _actionItem(
              title: '삭제하기',
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmDialog(context, ref ,postIdx);
              },
            ),
          ] else ...[
            // 🚩 남의 글일 때 보여줄 메뉴
            _actionItem(
              title: '신고하기',
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(context);
                WazzupToast.showError('$authorName님을 신고했습니다.');
              },
            ),
            const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF1F3F5)),
            _actionItem(
              title: '이 사용자의 글 보지 않기 (차단)',
              color: const Color(0xFF495057),
              onTap: () {
                Navigator.pop(context);
                WazzupToast.showError('사용자를 차단했습니다.');
              },
            ),
          ],
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

  Widget _actionItem({required String title, required Color color, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      title: Center(
        child: Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }


  Future<void> _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, int postIdx) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // 바깥 터치해도 안 닫히게 (선택사항)
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("게시글 삭제", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("정말로 이 게시글을 삭제하시겠습니까?\n삭제된 글은 복구할 수 없습니다."),
          actions: [
            // 취소 버튼
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소", style: TextStyle(color: Colors.grey)),
            ),
            // 진짜 삭제 버튼
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // 팝업 닫기
                
                bool success = await ref
                    .read(postListControllerProvider.notifier)
                    .deletePost(postIdx);

                if (success) {
                  WazzupToast.showSuccess("게시글이 삭제되었습니다.");
                } else {
                  WazzupToast.showError("삭제 실패. 다시 시도해주세요.");
                }
              },
              child: const Text("삭제", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}