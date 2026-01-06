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
    bool _isLoggedIn = ref.watch(authControllerProvider).isLoggedIn;
    final postListAsync = ref.watch(postListControllerProvider);

    // ref로 관찰할 데이터가 Bool(isloggedin)
    ref.listen<bool>(
    authControllerProvider.select((s) => s.isLoggedIn),
    (previous, next) {
      // 1. 이전에는 false(비로그인)였는데, 
      // 2. 현재 next가 true(로그인 완료)가 되었다면?
      // (토큰 재발급 성공 시점도 포함됨)
      if (previous == false && next == true) {
        print('로그인 상태 변경 감지됨');
        // 리스트 데이터를 '무효화' 시켜서 서버에서 다시
        // 이때는 이미 토큰이 갱신된 상태라 '내 하트'가 채워진 리스트가 옵니다.
        ref.invalidate(postListControllerProvider);
      }
    },
  );
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




