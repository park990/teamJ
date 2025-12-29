import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/dto/social_token_and_provider_dto.dart';
import 'package:front/screen/myPage_screen/login/controller/social_login_controller.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';
import 'package:front/screen/myPage_screen/login/widgets/social_login_buttons.dart';

class LoginBottomSheet extends ConsumerWidget {
  const LoginBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20.0),

      // 로그인 bottomn sheet을 감싸고 있는 컨테이너
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //상단 그레이 바
            _greyBar(),

            // 그 아래 로그인 텍스트
            _loginText(),
            SizedBox(height: 8),

            // 로그인 버튼들
            _SocialLoginButtons(context, ref),
          ],
        ),
      ),
    );
  }

  // 바텀 sheet 상단 회색 바
  Widget _greyBar() {
    return Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // 바텀 sheet 회색 바 아래 text
  Widget _loginText() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '간편 로그인',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            '뭐든 간편한게 좋잖아요',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 바텀 sheet 로그인 buttons
  Widget _SocialLoginButtons(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SocialLoginButtons(
          onPressed: () async{
            print('카카오클릭');
            
            final controller = ref.read(socialLoginControllerProvider.notifier);
            
            String? socialToken = await controller.loginKakao();

            if(socialToken!=null && context.mounted){
                Navigator.of(context).pop(
                  SocialTokenAndProviderDto(provider: "KAKAO", socialToken: socialToken)
                );
            }
          },
          text: '카카오 로그인',
          backColor: Color(0xFFFEE500),
          textColor: Colors.black,
        ),

        SocialLoginButtons(
          onPressed: () async {
            print('네이버 클릭');
            // String? token = await WithNaver().login();
          },
          text: '네이버 로그인',
          backColor: Color(0xFF03C75A),
          textColor: Colors.white,
        ),

        SocialLoginButtons(
          onPressed: () async{
            print('애플 클릭');
            // String? token = await WithApple().login();

          },
          text: '애플 로그인',
          backColor: Colors.black,
          textColor: Colors.white,
        ),
        
        SocialLoginButtons(
          onPressed: () async{
            print('구글 클릭');
            // String? token = await WithGoogle().login();
          },
          text: '구글 로그인',
          backColor: Colors.grey[300]!,
          textColor: Colors.black,
        ),
      ],
    );
  }
}
