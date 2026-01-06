import 'package:flutter/material.dart';
import 'package:front/dto/gathering_newList_dto.dart';

class GatheringVerticalCard extends StatelessWidget {
  // 새로운 모임 정보 불러오는 변수
  final GatheringNewlistDto gathering;

  const GatheringVerticalCard({
    required this.gathering,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(gathering.roomName ?? '제목 없음'),
    );
  }
}