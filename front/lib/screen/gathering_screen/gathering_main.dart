import 'package:flutter/material.dart';

class GatheringMain extends StatelessWidget {
  const GatheringMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '여기는 모임공간임 모임이 어디서 열리는지 혹은 그 모임의 인원수나 좋아요 갯수 등등 들어가야 함'
        ),
      ),
    );
  }
}