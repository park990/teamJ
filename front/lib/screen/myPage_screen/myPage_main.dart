import 'package:flutter/material.dart';

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
        Text('WAZZUP'),
        SizedBox(height: 10),
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

  void _showLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          
          // 로그인 bottomn sheet을 감싸고 있는 컨테이너
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //상단 그레이 바
                _greyBar(),

                // 그 아래 로그인 텍스트
                _loginText(),
                SizedBox(height: 8),

                // 로그인 버튼들
                _SocialLoginButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  // 로그인이 되어있을 때
  Widget _buildMyInfoScreen() {
    return Container(child: Text('로그인 되어있슴'));
  }

  // 소셜 로그인 버튼
  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required String text,
    required Color backColor,
    required Color textColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
        backgroundColor: backColor,
      ),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  // 바텀 sheet 상단 회색 바
  Widget _greyBar() {
    return Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // 바텀 sheet 회색 바 아래 text
  Widget _loginText() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '간편 로그인',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            '뭐든 간편한게 좋잖아요',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 바텀 sheet 로그인 buttons
  Widget _SocialLoginButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSocialButton(
          onPressed: () {
            print('카카오클릭');
          },
          text: '카카오 로그인',
          backColor: Color(0xFFFEE500),
          textColor: Colors.black,
        ),
        _buildSocialButton(
          onPressed: () {
            print('네이버 클릭');
          },
          text: '네이버 로그인',
          backColor: Color(0xFF03C75A),
          textColor: Colors.white,
        ),
        _buildSocialButton(
          onPressed: () {
            print('애플 클릭');
          },
          text: '애플 로그인',
          backColor: Colors.black,
          textColor: Colors.white,
        ),
        _buildSocialButton(
          onPressed: () {
            print('구글 클릭');
          },
          text: '구글 로그인',
          backColor: Colors.grey[300]!,
          textColor: Colors.black,
        ),
      ],
    );
  }
}
