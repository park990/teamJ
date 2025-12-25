// screen/bom_screen/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:front/screen/bom_screen/widget/post_footer.dart';
import 'package:front/screen/bom_screen/widget/post_images.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
          _buildHeader(context),

          // 컨테이너 
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F3F5), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(post.content, style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF212529))),
                ),

                if (testImages.isNotEmpty) PostImages(post: post, images: testImages),
                PostFooter(post: post),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
   return Positioned(
            left: -33, // 사진의 오른쪽 아래가 카드 모서리에 걸치도록 조정
            top: -33,  // 위쪽으로도 튀어나오게 조정
            right: 10,   // 가로 영역 전체 확보 (더보기 버튼 정렬용)
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end, // 사진 하단 기준으로 닉네임 정렬
              children: [
                // 프로필 사진
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF1F3F5),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person, size: 24, color: Color(0xFFADB5BD)),
                ),
                const SizedBox(width: 8), // 사진과 닉네임 사이 간격
                
                // 닉네임 (사진 바로 옆)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom:15), // 사진 하단 라인과 시각적 균형 맞춤
                    child: Row(
                      children: [
                        Text(
                          post.author,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF495057),
                          ),
                        ),
                        Spacer(),
                        // 더보기 버튼
                        GestureDetector(
                          onTap: () => _showModernActionSheet(context),
                          child: Icon(LucideIcons.moreHorizontal, size: 20, color: Color(0xFFADB5BD)),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          );
  }


  void _showModernActionSheet(BuildContext context) {
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
            const SizedBox(height: 12),
            _actionItem(
              title: '신고하기',
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(context);
                WazzupToast.showError('신고가 접수되었습니다.');
              },
            ),
            const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF1F3F5)),
            _actionItem(
              title: '이 사용자의 글 보지 않기',
              color: const Color(0xFF495057),
              onTap: () {
                Navigator.pop(context);
                WazzupToast.showError('사용자를 차단했습니다.');
              },
            ),
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
}