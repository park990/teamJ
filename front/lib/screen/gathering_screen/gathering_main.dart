import 'package:flutter/material.dart';
import 'package:front/theme/app_colors.dart';

class GatheringMain extends StatefulWidget {
  const GatheringMain({super.key});

  @override
  State<GatheringMain> createState() => _GatheringMainState();
}

class _GatheringMainState extends State<GatheringMain> 
  with TickerProviderStateMixin {

    bool isSearching = false;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 광고 배너 영역
            Container(
              height: 70,
              color: Colors.grey[400],
              alignment: Alignment.center,
              child: Text('여기에 광고 배너(이미지)'),
            ),
            Container(
              child: Padding(
                //padding: const EdgeInsets.all(18.0),
                padding: const EdgeInsets.only(left: 3),
                child: Text('🔥이번 주 핫한 모임', style: subTitleFont),
              ),
            ),
            // 모임 카드 1
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 180.0,
                    height: 150.0,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    child: Image.asset(
                      'asset/img/image.png',
                      fit: BoxFit.cover,
                      // 에러 디버깅용
                      errorBuilder: (context, error, StackTrace) {
                        return Container(
                          //color: Colors.grey,
                          child: Icon(Icons.error),
                        );
                      }
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    child: Column(
                      children: [
                        Text(
                          '96년생 모여라~!', style: subTitleFont,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    padding: EdgeInsets.all(12),
                  ),
                ),
                SizedBox(
                  width: 80.0,
                  height: 4.0,
                ),
              ],
            ),
            //모임 카드 2
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 180.0,
                    height: 150.0,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    child: Image.asset(
                      'asset/img/image.png',
                      fit: BoxFit.cover,
                      // 에러 디버깅용
                      errorBuilder: (context, error, StackTrace) {
                        return Container(
                          //color: Colors.grey,
                          child: Icon(Icons.error),
                        );
                      }
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    child: Column(
                      children: [
                        Text(
                          '너 빼고 다 참가중ㅋ', style: subTitleFont,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    padding: EdgeInsets.all(12),
                  ),
                ),
                SizedBox(
                  width: 60.0,
                  height: 4.0,
                ),
              ],
            ),
          ],
        ),
      );
    }
}