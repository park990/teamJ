import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/screen/bom_screen/const/full_image_viewer.dart';
import 'package:front/screen/bom_screen/controller/post_list_controller.dart';
import 'package:front/screen/bom_screen/const/spinning_flower.dart';
import 'package:front/screen/bom_screen/post_write_screen.dart';
import 'package:front/screen/myPage_screen/login/controller/auth_controller.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:front/screen/myPage_screen/login/widgets/login_handler.dart';
import 'package:front/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class BomMain extends ConsumerStatefulWidget {
  const BomMain({super.key});
  @override
  ConsumerState<BomMain> createState() => _BomMainState();
}

class _BomMainState extends ConsumerState<BomMain> with LoginHandlerMixin {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authControllerProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool _isLoggedIn = ref.watch(authControllerProvider).isLoggedIn;
    final postListAsync = ref.watch(postListControllerPorvider);

    return Scaffold(
      backgroundColor: wazzupBackGround,
      body: _buildBody(postListAsync),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!_isLoggedIn) {
            WazzupToast.showError('로그인이 필요합니다');
            bool isSuccess = await showLoginBottomSheet(context);
            if (isSuccess && mounted) {
              _navigateToPostWrite();
            }
          } else {
            _navigateToPostWrite();
          }
        },
        backgroundColor: wazzupButton.withValues(alpha: 0.75),
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _navigateToPostWrite() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PostWriteScreen()),
    );
  }

  Widget _buildBody(AsyncValue<List<Post>> postListAsync) {
    if (postListAsync.hasValue) {
      return SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: CustomHeader(
          refreshStyle: RefreshStyle.Follow,
          builder: (context, mode) => SizedBox(
            height: 80,
            child: Center(child: SpinningFlower(mode: mode)),
          ),
        ),
        onRefresh: () async {
          await Future.wait([
            ref.read(postListControllerPorvider.notifier).refresh(),
            Future.delayed(const Duration(milliseconds: 1500)),
          ]);
          _refreshController.refreshCompleted();
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: postListAsync.value!.length,
          itemBuilder: (context, index) => _PostCard(post: postListAsync.value![index]),
        ),
      );
    }
    return postListAsync.isLoading 
        ? const SizedBox.shrink() 
        : Center(child: Text('에러발생: ${postListAsync.error}'));
  }
}

class _PostCard extends StatelessWidget {

  final List<String> testImages = const [
    'asset/img/image.png', // 첫 번째 이미지 경로 (실제 파일 있어야 함)
    'asset/img/image.png', // 두 번째 이미지 경로 (실제 파일 있어야 함)
    'asset/img/sakura2.png', // 세 번째 이미지 경로 (실제 파일 있어야 함)
  ];


  final Post post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    bool hasImages = testImages.isNotEmpty;


    return Padding(
      // 전체 레이아웃 밀림 방지 패딩
      padding: const EdgeInsets.fromLTRB(48, 38, 16, 12), 
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. 본문 박스 (캔디 박스)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F3F5), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더가 박스 위로 떠 있으므로 본문 시작 지점에 여백을 줌
                const SizedBox(height: 15), 

                // 본문 텍스트
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    post.content,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF212529),
                    ),
                  ),
                ),
                
                // 이미지
                // if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                  if (hasImages)
                  _buildImages(),

                // 푸터 (좋아요/댓글 등)
                _buildFooter(),
              ],
            ),
          ),

          // (사진 + 닉네임 세트)
          Positioned(
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
          ),
        ],
      ),
    );
  }


  // 이미지 처리 
  Widget _buildImages() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 220, // 이미지 영역 높이 설정
        child: ListView.separated(
          // 2. 스크롤 방향을 가로로 설정
          scrollDirection: Axis.horizontal,
          // 3. 리스트 양 옆에 여백을 주어 본문 텍스트와 라인을 맞춤
          padding: const EdgeInsets.symmetric(horizontal: 16),
          // 테스트용 리스트 길이 사용
          itemCount: testImages.length,
          // 나중엔: itemCount: post.imageUrls!.length,
      
          // 아이템 사이 간격 설정
          separatorBuilder: (context, index) => const SizedBox(width: 10),
      
          // 실제 이미지 아이템 빌드
          itemBuilder: (context, index) {
            // 현재 이미지 경로 (테스트용)
            final String currentImagePath = testImages[index];
            // (나중엔 실제 데이터 사용: final String currentImagePath = post.imageUrls![index];)
      
            // Hero 애니메이션을 위한 고유 태그 생성
            // (중요: 나중에는 게시글 ID와 이미지 인덱스를 조합해서 유니크하게 만들어야 합니다. 예: 'post_${post.id}_img_$index')
            final String uniqueHeroTag =
                'temp_hero_tag_${post.id}_$index';
      
            // 클릭 이벤트를 위해 GestureDetector로 감쌈
            return GestureDetector(
              onTap: () {
                // 이미지를 눌렀을 때 전체화면 뷰어로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullImageViewerScreen(
                      imagePaths: testImages,
                      initialIndex: index,
                    ),
                    fullscreenDialog:
                        true, // 아래에서 위로 열리는 모달 느낌을 주고 싶으면 true
                  ),
                );
              },
              // Hero 위젯으로 감싸서 화면 전환 시 이미지가 날아가는 효과를 줌
              child: Hero(
                tag: uniqueHeroTag, // 뷰어 화면과 동일한 태그 사용
                // 기존의 둥근 모서리 이미지 위젯
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    currentImagePath,
                    width: 280,
                    height: 220,
                    fit: BoxFit.cover, // 리스트에서는 꽉 차게 (잘림 발생)
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          width: 280,
                          height: 220,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          _buildInteractionButton(
            icon: LucideIcons.heart,
            count: post.likeCount,
            color: Colors.redAccent,
            onTap: () {},
          ),
          const SizedBox(width: 18),
          _buildInteractionButton(
            icon: LucideIcons.messageCircle,
            count: post.commentCount,
            color: Colors.blueAccent,
            onTap: () {},
          ),
          const Spacer(),
          Text(
            post.displayDate,
            style: const TextStyle(fontSize: 11, color: Color(0xFFADB5BD)),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isZero = count == 0;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 20, color: isZero ? const Color(0xFFDEE2E6) : color.withValues(alpha: 0.8)),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isZero ? const Color(0xFFDEE2E6) : const Color(0xFF495057),
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