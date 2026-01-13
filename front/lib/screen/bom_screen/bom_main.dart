import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/screen/bom_screen/const/spinning_flower.dart';
import 'package:front/screen/bom_screen/post_write_screen.dart';
import 'package:front/screen/bom_screen/provider/post_provider.dart';
import 'package:front/screen/bom_screen/widget/post_card.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';
import 'package:front/screen/myPage_screen/login/widgets/login_handler.dart';
import 'package:front/theme/app_colors.dart';
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
    final _isLoading = ref.watch(authControllerProvider.select((s) => s.isLoading));
    final _isLoggedIn = ref.watch(authControllerProvider.select((s) => s.isLoggedIn));
    final postListAsync = ref.watch(postListControllerProvider);

    // authState의 isLoading중일 때는 봄 메인스크린을 잠시 기다리자 
    if (_isLoading) {
    return const Scaffold(
      backgroundColor: wazzupBackGround,
      body: SizedBox.shrink(), 
    );
  }

    return Scaffold(
      backgroundColor: wazzupBackGround,
      body: _buildBody(postListAsync),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 로그인 해야지 글쓸 수 있음.
          if (!_isLoggedIn) {
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

  void _navigateToPostWrite()async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PostWriteScreen()),
    );

      // 글쓰기 성공시 or 뒤로가기 눌렀을때 목록 프로바이더 무효화 즉 BomMain으로 돌아왓을 때 리스트가 서버에서 최신글을 불러옴
      ref.invalidate(postListControllerProvider);
  }





  // WIDGET폴더를 갖고 만든 POST_CARD를 리스트로 생성 
  Widget _buildBody(AsyncValue<List<Post>> postListAsync) {
    if (postListAsync.hasValue) {
      return SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true,
        footer: ClassicFooter(
          loadStyle: LoadStyle.ShowAlways,
          completeDuration: Duration(milliseconds: 500),
          loadingText: "데이터를 가져오고 있어요...",
          noDataText: "마지막 게시글입니다 👏", // loadNoData() 호출 시 표시됨
          idleText: "위로 당겨서 더 보기",
          canLoadingText: "놓으면 더 불러와요!",
          failedText: "로딩 실패! 다시 시도해주세요",
        ),
        header: CustomHeader(
          refreshStyle: RefreshStyle.Follow,
          builder: (context, mode) => SizedBox(
            height: 80,
            child: Center(child: SpinningFlower(mode: mode)),
          ),
        ),
        onRefresh: () async {
          await Future.wait([
            ref.read(postListControllerProvider.notifier).refresh(),
            Future.delayed(const Duration(milliseconds: 1500)),
          ]);
          _refreshController.refreshCompleted();
          _refreshController.resetNoData();
        },
        onLoading:() async{
           final notifier = ref.read(postListControllerProvider.notifier);
  
          // 1. 다음 페이지 데이터 요청
          await notifier.fetchNextPage();

          // 2. 컨트롤러의 상태 확인 후 SmartRefresher 상태 업데이트
          if (notifier.isLastPage) {
            // 더 이상 데이터가 없으면 'NoData' 상태로 변경 (더 이상 안 당겨짐)
            _refreshController.loadNoData();
          } else {
            // 데이터가 더 있으면 로딩 완료 처리
            _refreshController.loadComplete();
          }
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: postListAsync.value!.length,
          itemBuilder: (context, index) => 
          PostCard(post: postListAsync.value![index]),
        ),
      );
    }
    return postListAsync.isLoading 
        ? const SizedBox.shrink() 
        : Center(child: Text('에러발생: ${postListAsync.error}'));
  }
}




