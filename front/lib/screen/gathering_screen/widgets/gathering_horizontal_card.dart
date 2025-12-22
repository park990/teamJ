import 'package:flutter/material.dart';
import 'package:front/screen/gathering_screen/model/gathering_meeting.dart'; //데이터모델
import 'package:front/theme/app_colors.dart'; //폰트

class GatheringHorizontalCard extends StatelessWidget {
  // 데이터 주입(카드내용)
  final GatheringMeeting meeting;

  const GatheringHorizontalCard({
    required this.meeting,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              meeting.cardImageUrl, fit: BoxFit.cover, height: 130,
            ),
            SizedBox(
              //height: 15,
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meeting.cardTitle,
                    style: cardTitleFont,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis
                  ),
                  SizedBox(
                    height: 4
                  ),
                  Text(
                    meeting.cardBody, style: cardBodyFont, maxLines: 1, overflow: TextOverflow.ellipsis
                  ),
                  SizedBox(
                    height: 4
                  ),
                  Text(
                    '참여자 ${meeting.cardParticipantsCount} 명', style: captionLabelFont
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}