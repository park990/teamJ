import 'package:flutter/material.dart';
import 'package:front/screen/myPage_screen/login/login_bottom_sheet.dart';
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
        ElevatedButton(
          onPressed: () {
          _showLoginBottomSheet(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFeedaf2),
          ),
          child: Text('로그인하기'),
        ),
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

  // 바텀sheet 보여주기
  void _showLoginBottomSheet(BuildContext context) async {
    final String? resultToken= await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return LoginBottomSheet();
      },
    );
    // 여기 지우면 안댐 //

    // if(resultToken != null){
    // print("바텀쉿에서 열었던 토큰을 마이페이지 홈에서 받았다${resultToken}");
    //   if(!mounted) return;
    //   Navigator.of(context).push(
    //     MaterialPageRoute(builder: (context)=>
    //       SignupScreen(),
    //     ),
    //   );
    // }
  }


}
