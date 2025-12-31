import 'package:flutter/material.dart';
import 'package:front/screen/gathering_screen/model/gathering_card_model.dart'; //데이터모델
import 'package:front/theme/app_colors.dart'; //폰트

class GatheringHorizontalCard extends StatelessWidget {
  // 데이터 주입(카드내용)
  final GatheringMeetingModel meeting;

  const GatheringHorizontalCard({
    required this.meeting,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.brown[100]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: 300,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                (meeting.imageUrl == null || meeting.imageUrl!.isEmpty)
                    ? 'asset/img/image.png'
                    : meeting.imageUrl!,
                fit: BoxFit.cover,
                height: 130,
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
                      meeting.title,
                      style: cardTitleFont,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                    ),
                    SizedBox(
                      height: 4
                    ),
                    Text(
                      meeting.content, style: cardBodyFont, maxLines: 1, overflow: TextOverflow.ellipsis
                    ),
                    SizedBox(
                      height: 4
                    ),
                    Text(
                      '참여자 ${meeting.currentParticipants} 명', style: captionLabelFont
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}