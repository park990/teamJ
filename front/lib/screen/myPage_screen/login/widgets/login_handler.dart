import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/dto/social_user_dto.dart';
import 'package:front/screen/myPage_screen/login/controller/auth_controller.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';
import 'package:front/screen/myPage_screen/login/widgets/login_bottom_sheet.dart';
import 'package:front/screen/myPage_screen/login/signup/signUp_screen.dart';

// ConsumerState에서만 사용할 수 있는 로그인 창
mixin LoginHandlerMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _isLoginSheetOpen = false;

  // 반환 타입을 Future<bool>로 변경
  Future<bool> showLoginBottomSheet(BuildContext context) async {
    if (_isLoginSheetOpen) return false;
    _isLoginSheetOpen = true;

    try {
      final result = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => const LoginBottomSheet(),
      );

      if (result != null && mounted) {
        final controller = ref.read(authControllerProvider.notifier);
        final processedResult = await controller.handleSocialLogin(result);

        if (!mounted) return false;

        // 1. 신규 유저 회원가입 진행
        // 돌아 온 값이 유저 디티오 객체라면
        print('받아온 소셜 회원 정보를 socialDTO객체에 넣어줬는지? : ${processedResult}');
        if (processedResult is SocialUserDto) {
          final signUpResult = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SignupScreen(user: processedResult)),
          );

          if (signUpResult != null && mounted) {
            await controller.completeSignUp(signUpResult);
            return true; // 회원가입 후 로그인 성공
          }
        } 
        // 2. 기존 유저 로그인 성공
        else if (processedResult == "success") {
        print('기존 유저: ${processedResult}');
          return true; 
        }
      }
      return false; // 취소했거나 실패한 경우
    } finally {
      _isLoginSheetOpen = false;
    }
  }
}