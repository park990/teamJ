import 'package:flutter/material.dart';
import 'package:front/screen/gathering_screen/model/gathering_meeting.dart';
import 'package:front/screen/gathering_screen/widgets/ad_banner.dart';
import 'package:front/screen/gathering_screen/widgets/gathering_card_item.dart';
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

    //bool isSearching = false;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 고정: 광고 배너 영역
            AdBanner(),
            // Container(
            //   height: 70,
            //   color: Colors.grey[400],
            //   alignment: Alignment.center,
            //   child: Text('여기에 광고 배너(이미지)'),
            // ),
            // 고정 : 섹션 제목
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('🔥이번 주 핫한 모임', style: sectionTitleFont),
            ),

            // ListView가 들어갈 곳
            Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _gatheringMeetings.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return GatheringCardItem(meeting: _gatheringMeetings[index]);
                  }
                ),
              ),
          ],
        ),
      );
    }
}