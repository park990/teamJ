import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/data/data_source/remote/social/kakao_oauth_data_source.dart';
import 'package:front/data/repository/Auth_repository.dart';
import 'package:front/screen/myPage_screen/login/controller/auth_controller.dart';
import 'package:front/screen/myPage_screen/login/controller/social_login_controller.dart';


final authRepositoryProvider = Provider((ref){
  final apiclinet = ref.watch(apiClientProvider);

  return AuthRepository(apiclinet);
});


final authControllerProvider =NotifierProvider<AuthController, AuthState>(() {
      return AuthController();
});


final kakaoLoginProvider = Provider((ref){
  return KakaoOauthDataSource();
});


final socialLoginControllerProvider = NotifierProvider<SocialLoginController, void>(() {
    return SocialLoginController();
});