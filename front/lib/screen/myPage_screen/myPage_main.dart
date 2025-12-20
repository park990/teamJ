import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/alert/dialog.dart';
import 'package:front/dto/auth_response.dart';
import 'package:front/dto/social_user_dto.dart';
import 'package:front/dto/social_token_and_provider_dto.dart';
import 'package:front/screen/myPage_screen/login/controller/auth_controller.dart';
import 'package:front/screen/myPage_screen/login/widgets/login_bottom_sheet.dart';
import 'package:front/screen/myPage_screen/login/signup/signUp_screen.dart';
class MypageMain extends ConsumerStatefulWidget {
  const MypageMain({super.key,});

  @override
  ConsumerState<MypageMain> createState() => _MypageMainState();
}

class _MypageMainState extends ConsumerState<MypageMain> {
  
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
          _showLoginBottomSheet(context);
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

  // sns 로그인을 위한 바텀 컨테이너들 sheet 보여주기
  void _showLoginBottomSheet(BuildContext context) async {
    final SocialTokenAndProviderDto? result = await showModalBottomSheet(
      builder: (BuildContext context) {
        return LoginBottomSheet();
      },
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
    );

    // 위에서 로그인을 실행해서 소셜 토큰을 받아 왔다면
    if (result != null && mounted) {

      final controller = ref.read(authControllerProvider.notifier);

      final processedResult = await controller. handleSocialLogin(result);

      if(!mounted) return;

      // 반환 받은 객체가 유저 정보가 담겨 있는 객체라면?(신규가입)
      // 회원가입 창과 소셜 토큰으로 얻어온 정보를 함께 전달해줌 
      if(processedResult is SocialUserDto){
        print('신규유저임 소셜 토큰으로 받아온 정보는: $processedResult \n 이제 회원가입창으로');
        final AuthResponse? signUpResult = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SignupScreen(user: processedResult),
          )
        );
      
        // 회원 가입 마치면 로그인이 성공해서 돌아오는데 토큰 들고옴 
        if(signUpResult !=null){
          await controller.completeSignUp(signUpResult);
        }
      }
    }
  }


}
