import 'package:flutter/material.dart';
import 'package:front/screen/gathering_screen/model/gathering_model.dart';

class GatheringVerticalCard extends StatelessWidget {
  // 새로운 모임 정보 불러오는 변수
  final GatheringModel model;

  const GatheringVerticalCard({
    required this.model,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    // 모임 카드안에 보여줄 항목을 불러오는 변수
    final info = model.meetingInfo;
    return Container(
      child: Text(info.title), //테스트
    );
  }
}