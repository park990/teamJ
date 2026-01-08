import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:front/const/app_assets.dart';
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
    final imageUrl = meeting.imageUrl;
    Widget imageWidget;

    if(imageUrl != null && imageUrl.isNotEmpty) {
      // 1. URL 있을 때
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        // 에러 발생 시 기본 이미지 보여주기
        errorWidget: (context, url, error) => Image.asset(
          AppAssets.defaultProfile,
          fit: BoxFit.cover,
        ),
        placeholder: (context, url) => Container(color: Colors.grey[200]),
      );
    } else {
      imageWidget = Image.asset(AppAssets.defaultProfile, fit: BoxFit.cover);
    }

    return Container(
      padding: const EdgeInsets.all(10),
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
              SizedBox(
                height: 130,
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageWidget,
                ),
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