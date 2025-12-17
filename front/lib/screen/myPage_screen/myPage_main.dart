import 'package:flutter/material.dart';
import 'package:front/dto/auth_response.dart';
import 'package:front/dto/social_user_dto.dart';
import 'package:front/dto/social_token_and_provider_dto.dart';
import 'package:front/screen/myPage_screen/login/login_bottom_sheet.dart';
import 'package:front/screen/myPage_screen/login/services/OAuth_service.dart';
import 'package:front/screen/myPage_screen/login/signup/signUp_screen.dart';
import 'package:front/service/wazzup_token_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class MypageMain extends StatefulWidget {
  const MypageMain({super.key,});

  @override
  State<MypageMain> createState() => _MypageMainState();
}

class _MypageMainState extends State<MypageMain> {
  bool _isLoggeIn = false;
  String? wazzupToken;

  @override
  void initState() {
    super.initState();

    // 자동 로그인
    _checkAutoLogin();
  }
  void _checkAutoLogin() async {
    final storage = new WazzupTokenStorage();
    String? storedToken = await storage.getToken();
    if(storedToken!=null){
      print('자동로그인 됐음');
      setState(() {
        wazzupToken = storedToken;
        _isLoggeIn = true;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoggeIn
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
        if (_isLoggeIn)
          ElevatedButton(
            onPressed: () async {
              await OauthService().wazzupLogout();
              try {
                // 소셜 로그아웃
                await UserApi.instance.logout();
                print('소셜 로그아웃 성공!');
              } catch (error) {
                print('로그아웃 실패: $error');
              }

              // 스토리지에 저장된 토큰도 삭제해 줘야함
              final storage = WazzupTokenStorage();
              await storage.deleteAllToken();
              print('스토리지에 저장된 토큰 삭제 완료');

              if (mounted) {
                setState(() {
                  _isLoggeIn = false;
                  wazzupToken = null;
                });
              }
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
    if (result != null) {
      print("소셜 토큰을 마이페이지 홈에서 pop 받은 상태: ${result.socialToken}");
      if (!mounted) return;

      OauthService oAuthService = OauthService();

      // 로그인 했을 때 register이면 신규유저 success면 기존유저
      final responseData = await oAuthService.sendSocialLogin(
        result,
      );
      print("데이터의 형태는 이런식으로 되어있음 ${responseData}");

      if (responseData != null) {
        String serverResult = responseData['result'];

        // 신규 유저 register면 data 안에 유저정보가 담겨 있고
        if (serverResult == 'register') {
          SocialUserDto user = SocialUserDto.fromJson(responseData['data']);
        print('분명히 SocialUserDTO를 socialUser라고 보낸건데${responseData['data']}');
          if (!mounted) return;

          // 회원가입 창으로
          final AuthResponse? resultFromSignUp = await Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => SignupScreen(user: user),
                ),
              );

          if (resultFromSignUp != null) {
            String accessToken = resultFromSignUp.wazzupToken;
            String refreshToken = resultFromSignUp.refreshToken;

            // 토큰 저장을 위한 스토리지
            final storage = new WazzupTokenStorage();
            await storage.saveToken(accessToken: accessToken, refreshToken: refreshToken);

            print('마이페이지까지 토큰 잘 받아옴 ${accessToken}');
            setState(() {
              wazzupToken = accessToken;
              _isLoggeIn = true;
            });
          }
          // 기존 유저 success면 data안에 토큰 정보가 담겨 있음
        } else if (serverResult == 'success') {
          AuthResponse tokenData = AuthResponse.fromJson(responseData['data']); 
             String accessToken = tokenData.wazzupToken;
            String refreshToken = tokenData.refreshToken;

          print(
            '기존유저임 이는 로그인 성공으로 두고 마이페이지 화면을 보이도록 해야함 받은 토큰은 ${accessToken} 이 토큰은 스토리지에 저장해두고 관리해야함.',
          );
            // 토큰 저장을 위한 스토리지
            final storage = new WazzupTokenStorage();
            await storage.saveToken(accessToken: accessToken, refreshToken: refreshToken );
            print('${storage.getToken()} 스토리지에 저장된 토큰들임');
          setState(() {
            wazzupToken = accessToken;
            _isLoggeIn = true;
          });
        }
      }
    }
  }


}
