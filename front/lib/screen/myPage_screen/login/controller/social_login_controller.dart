
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/remote/social/kakao_oauth_data_source.dart';

final socialLoginProvider = Provider((ref)=>KakaoOauthDataSource());

  final socialLoginControllerProvider = NotifierProvider<SocialLoginController, void>(() {
    return SocialLoginController();
  });

class SocialLoginController extends Notifier<void>{
  


  // 데이터 소스 여기서 관리
  late final KakaoOauthDataSource _kakaoSource;
  // final _naverSource = NaverOauthDataSource();
  // final _appleSource = AppleOauthDataSource();

  @override
  void build() {
    _kakaoSource = ref.read(socialLoginProvider);
  }

  Future<String?> loginKakao() async{
    return await _kakaoSource.login();
  }

}