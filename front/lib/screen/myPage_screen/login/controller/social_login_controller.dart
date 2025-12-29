import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/remote/social/kakao_oauth_data_source.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';

class SocialLoginController extends Notifier<void>{
  


  // 데이터 소스 여기서 관리
  late final KakaoOauthDataSource _kakaoSource;
  // final _naverSource = NaverOauthDataSource();
  // final _appleSource = AppleOauthDataSource();

  @override
  void build() {
    _kakaoSource = ref.read(kakaoLoginProvider);
  }

  Future<String?> loginKakao() async{
    return await _kakaoSource.login();
  }

}