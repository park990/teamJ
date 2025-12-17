import 'package:flutter/material.dart';
import 'package:front/screen/gathering_screen/model/gathering_meeting.dart';
import 'package:front/theme/app_colors.dart';

class GatheringCardItem extends StatelessWidget {
  final GatheringMeeting meeting;

  const GatheringCardItem({
    required this.meeting,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            meeting.cardImageUrl,
            width: 120,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meeting.cardTitle, style: cardTitleFont),
              const SizedBox(height: 4),
              Text(meeting.cardBody, style: cardBodyFont),
              const SizedBox(height: 8),
              Text('참여자 ${meeting.cardParticipantsCount}명', style: captionLabelFont),
            ],
          ),
        ),
      ],
    );
  }
}