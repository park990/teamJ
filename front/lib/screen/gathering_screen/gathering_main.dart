import 'package:flutter/material.dart';
import 'package:front/screen/gathering_screen/model/gathering_meeting.dart';
import 'package:front/screen/gathering_screen/widgets/gathering_horizontal_card.dart';
import 'package:front/theme/app_colors.dart';

class GatheringMain extends StatefulWidget {

  GatheringMain({super.key});

  @override
  State<GatheringMain> createState() => _GatheringMainState();
}

class _GatheringMainState extends State<GatheringMain> 
  with TickerProviderStateMixin {

    List<GatheringMeeting> _gatheringMeetings = [
    //더미데이터
    GatheringMeeting(
      cardTitle: '96년생 모여라~!',
      cardBody: '동갑 친구들끼리 허심탄회하게 얘기해봐용',
      cardImageUrl: 'asset/img/image.png',
      cardParticipantsCount: 5,
    ),
    GatheringMeeting(
      cardTitle: '여미새 남미새 다 모여라~~',
      cardBody: '매력발산 시작~',
      cardImageUrl: 'asset/img/image.png',
      cardParticipantsCount: 10,
    ),
    GatheringMeeting(
      cardTitle: 'TeamJ',
      cardBody: '코딩 쌉고수 모임',
      cardImageUrl: 'asset/img/image.png',
      cardParticipantsCount: 3,
    ),
  ];

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 고정: 광고 배너 영역
            //AdBanner(),
            // 고정 : 섹션 제목
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('🔥이번 주 핫한 모임', style: sectionTitleFont),
            ),
            // ListView가 들어갈 곳
            SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _gatheringMeetings.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  // 모임카드 수평으로 보여주기
                  return GatheringHorizontalCard(meeting: _gatheringMeetings[index]);
                },
              ),
            ),
          ],
        ),
      );
    }
}