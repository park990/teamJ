import 'package:flutter/material.dart';
import 'package:front/screen/myPage_screen/login/login_bottom_sheet.dart';

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
      ],
    );
  }
  
  // 로그인이 되어있을 때
  Widget _buildMyInfoScreen() {
    return Container(child: Text('로그인 되어있슴'));
  }

  // 바텀sheet 보여주기
  void _showLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return LoginBottomSheet();
      },
    );
  }


}
