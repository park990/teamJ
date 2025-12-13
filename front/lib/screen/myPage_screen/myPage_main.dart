import 'package:flutter/material.dart';
import 'package:front/screen/myPage_screen/login/login_bottom_sheet.dart';
import 'package:front/screen/myPage_screen/login/services/OAuth_service.dart';
import 'package:front/screen/myPage_screen/login/signup/signUp_screen.dart';

class MypageMain extends StatefulWidget {
  const MypageMain({super.key});

  @override
  State<MypageMain> createState() => _MypageMainState();
}

class _MypageMainState extends State<MypageMain> {
  bool _isLoggeIn = false;

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

        // 회원가입 하는 곳 버튼
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_)=>SignupScreen())
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFeedaf2),
          ),
          child: Text('회원가입이지만 로그인 했을때 처음 로그인이면 signupscreen나와야하고 아니면 스킵하는 창'),
        ),
      ],
    );
  }
  
  // 로그인이 되어있을 때
  Widget _buildMyInfoScreen() {
    return Container(child: Text('로그인 되어있슴'));
  }

  // sns 로그인을 위한 바텀 컨테이너들 sheet 보여주기
  void _showLoginBottomSheet(BuildContext context) async {
    final Map<String,dynamic>? result = await showModalBottomSheet(
      builder: (BuildContext context) {
        return LoginBottomSheet();
      },
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
    );

    // 위에서 로그인을 실행해서 소셜 토큰을 받아 왔다면
    if(result != null){
    print("소셜 토큰을 마이페이지 홈에서 pop 받은 상태: ${result}");
    String token = result['token'];
    String platform = result['platform'];
      if(!mounted) return;

      OauthService oAuthService = OauthService();
      final responseData = await oAuthService.sendSocialLogin(token, platform);
      
      if(responseData != null ){
        String serverResult = responseData['result'];

          if(serverResult == 'register'){
            String snsId = responseData['data']['userSnsId'];
            print('userSnsId는 : ${snsId}');
            if(!mounted) return;
            print("로그인에 성공하여 서버에서 받은 것 최초 로그인 이라 회원가입 창으로 안내해줘야함 그리고 현재 여기서 받은 snsId와 platform을 갖고 회원가입할때 닉네임까지 받기."+serverResult);
            // 이다음은 그 아이디와 플랫폼들고 회원가입 하고 그 안에서 닉네임 챙기고 본인인증후 성별, 이름, 생일 받기. 
          }else if(serverResult =='success'){
            String jwtToken = responseData['data']['token'];
            print('기존유저임 이는 로그인 성공으로 두고 마이페이지 화면을 보이도록 해야함 받은 토큰은 ${jwtToken} 이 토큰은 스토리지에 저장해두고 관리해야함.' );
            setState(() {
              // _isLoggeIn = true;
            });
          }
      }
    }
  }


}
