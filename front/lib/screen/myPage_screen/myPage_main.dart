import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/screen/myPage_screen/login/controller/auth_controller.dart';
import 'package:front/screen/myPage_screen/login/widgets/login_handler.dart';

import 'package:front/theme/app_colors.dart';
class MypageMain extends ConsumerStatefulWidget {
  const MypageMain({super.key,});

  @override
  ConsumerState<MypageMain> createState() => _MypageMainState();
}

class _MypageMainState extends ConsumerState<MypageMain> with LoginHandlerMixin {
  
  @override
  void initState() {
    super.initState();

    // providerScope가 준비된 직후 가장 빠른 타이밍에 실행 (순서=microtask > event queue > frame)
    Future.microtask((){
      ref.read(authControllerProvider.notifier).init();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // 컨트롤러 상태를 구독( 값이 바뀌면 다시 그린다. )
    final authState = ref.watch(authControllerProvider);
    // if(authState.isLoading){
    //   return const Scaffold(
    //     body: Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }
    
    
    return Scaffold(
      backgroundColor: wazzupBackGround, // 배경

      body: Center(
        child: authState.isLoggedIn
            ? _buildMyInfoScreen()
            : _buildLoginScreen(),
      ),
    );
  }

  // 로그인이 안되어 있을 때
  Widget _buildLoginScreen() {
    return Column(
      children: [
        Text('로그인이 필요합니다'),
        
        // 로그인 하기 버튼
        ElevatedButton(
          onPressed: () {
          showLoginBottomSheet(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFeedaf2),
          ),
          child: Text('로그인하기'),
        ),

      ],
    );
  }
  
  // 로그인이 되어있을 때
  Widget _buildMyInfoScreen() {
    return Column(
      children: [
        Container(child: Text('로그인 되어있슴')),
          ElevatedButton(
            onPressed: () async {

              // 컨트롤러에 로그아웃 요청
              await ref.read(authControllerProvider.notifier).logout();

              WazzupToast.showSuccess('로그아웃 성공');     
              },

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[300],
            ),
            child: Text('로그아웃하기'),
          ),
      ],
    );
  }



}
