import 'package:flutter/material.dart';
import 'package:front/theme/app_colors.dart';

class FriendMain extends StatelessWidget {
  const FriendMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: wazzupBackGround, // 배경

      body: Center(
        child: Text(
          '친구목록임 친구목록 안에서 친구끼리 채팅도 가능해야함',
        ),
      ),
    );
  }
}