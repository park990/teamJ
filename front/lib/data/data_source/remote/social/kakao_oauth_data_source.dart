import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoOauthDataSource {
  Future<String?> login() async {
    try {
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          if (error is PlatformException &&
              error.code == 'CANCELD') {
            return null;
          }
        } // catch 끝
      } else {
        try {
        await UserApi.instance.loginWithKakaoAccount();

        } catch (error) {
          print('카카오 로그인 실패 ${error}');
          return null;
        }
      } // else 마지막

      var token = await TokenManagerProvider.instance.manager.getToken();
      return token?.accessToken;
    } catch (error) {
      print('로그인 에러: ${error}');
      return null;
    }
  }
}
