import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/screen/bom_screen/controller/post_list_controller.dart';
import 'package:front/screen/bom_screen/model/spinning_flower.dart';
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

class _BomMainState extends ConsumerState<BomMain> with LoginHandlerMixin{

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    // 자동로그인 
    Future.microtask((){
      ref.read(authControllerProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 로그인 상태관리
    bool _isLoggedIn = ref.watch(authControllerProvider).isLoggedIn;

    // 게시글 불러오기 상태관리
    final postListAsync = ref.watch(postListControllerPorvider);

    return Scaffold(
      backgroundColor: wazzupBackGround, // 배경

      body: _buildBody(postListAsync),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('글쓰기 클릭');
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

        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // 글쓰기로 이동
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
          refreshStyle: RefreshStyle.Behind,
          builder: (context, mode) => Container(
            height: 80,
            child: Center(child: SpinningFlower(mode: mode)),
          ),
        ),
        onRefresh: () async {
          await Future.wait([
            ref.read(postListControllerPorvider.notifier).refresh(),
            Future.delayed(const Duration(milliseconds: 2000)),
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

// ****게시글들*****
class _PostCard extends StatelessWidget {
  final Post post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 카드들 사이 간격
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F3F5), width: 1), // 카드 테두리
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),

        // 여기서 클릭하면 상세 글 화면으로 넘어가야함
        onTap: () {
          
          
        // Navigator.of(context).push(
        //   MaterialPageRoute(builder: (_)=>
        //     PostDetailScreen(postId:post.id)
        //   )
        // );
        
        
        },
        child: Padding(
          // 카드안에 든 내용물과 카드의 패딩
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          child: Column(
            children: [
              // --- 상단 영역: 제목 + 이미지 플레이스홀더 ---
              _CardUpper(),

              const SizedBox(height: 15),

              // --- 하단 영역: [작성자 · 시간] | [하트 댓글 조회] ---
              CardBottom()
            ],
          ),
        ),
      ),
    );
  }

// --- 상단 영역: 제목 + 이미지 플레이스홀더 ---
  Widget _CardUpper() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //날짜
              Text(
                post.displayDate,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFADB5BD), // 연한 쿨그레이
                ),
              ),

              // 제목
              Text(
                post.title,
                style: wazzupFont.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212529),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              Text(
                post.content,
                style: wazzupFont.copyWith(
                  fontSize: 13,
                  color: Color(0xFF495057),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // --- 🖼️ 업그레이드된 이미지 플레이스홀더 ---
        Padding(
          // 사진만 살짝 아래로
          padding: const EdgeInsets.only(top: 15),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE9ECEF),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.image_outlined,
              color: Color(0xFFDEE2E6),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }


// --- 하단 영역: [작성자 · 시간] | [하트 댓글 조회] ---
  Widget CardBottom() {
    return 
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. 왼쪽: 작성자 정보 (Slate Grey 적용)
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  post.author,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF495057), // 세련된 진회색
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // 2. 오른쪽: 통계 (구분선 제거 및 간격 최적화)
        Row(
          children: [
            _buildSeparator(),
            _buildStat(
              LucideIcons.heart,
              post.likeCount,
              Colors.redAccent,
            ),
            const SizedBox(width: 10),
            _buildStat(
              LucideIcons.messageCircle,
              post.commentCount,
              Colors.blueAccent,
            ),
            const SizedBox(width: 10),
            _buildStat(
              LucideIcons.trendingUp,
              post.viewCount,
              Colors.yellow[900]!,
            ),
          ],
        ),
      ],
    );
  }

  // 통계 아이콘 위젯
  Widget _buildStat(IconData icon, int count, Color color) {
    final bool isZero = count == 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon, 
          size: 14, 
          color: isZero ? const Color(0xFFDEE2E6) : color.withValues(alpha: 0.5)
        ),
        const SizedBox(width: 4),
        Text(
          count > 999 ? '999+' : '$count',
          style: TextStyle(
            fontSize: 11,
            color: isZero ? const Color(0xFFDEE2E6) : const Color(0xFF868E96),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

    Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text('|', style: TextStyle(fontSize: 10, color: Colors.grey[50])),
    );
    }

}