
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/remote/social/kakao_oauth_data_source.dart';

  final socialLoginProvider = NotifierProvider<SocialLoginController, void>(() {
    return SocialLoginController();
  });

class SocialLoginController extends Notifier<void>{


  // 데이터 소스 여기서 관리
  final _kakaoSource = KakaoOauthDataSource();
  // final _naverSource = NaverOauthDataSource();
  // final _appleSource = AppleOauthDataSource();

  @override
  void build() {
  }

  Future<String?> loginKakao() async{
    return await _kakaoSource.login();
  }

}