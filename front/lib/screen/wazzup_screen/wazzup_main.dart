import 'package:flutter/material.dart';

class WazzupMain extends StatelessWidget {
  const WazzupMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text('WAZZUP 메인 화면  여기는 게시판들을 위한 공간임.'),
        ),
      ),
    );
  }
}