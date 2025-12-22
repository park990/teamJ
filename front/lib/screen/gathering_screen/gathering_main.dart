import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repository/gathering_repository.dart';
import 'package:front/provider/gathering_meeting_provider.dart';
import 'package:front/screen/gathering_screen/widgets/gathering_horizontal_card.dart';
import 'package:front/theme/app_colors.dart';

class GatheringMain extends ConsumerStatefulWidget {
  GatheringMain({
    super.key,
  });

  @override
  ConsumerState<GatheringMain> createState() => _GatheringMainState();
}

class _GatheringMainState extends ConsumerState<GatheringMain>
  with TickerProviderStateMixin {
    // 현재 페이지 진행률
    double _pageValue = 0;

    // 나중에 변수를 처음 사용할 때 값을 초기화함
    late PageController _pageController;

    // 변경사항 덮어쓰기(다시 빌드할때 덮어쓴걸로 그려짐)
    @override
    void initState() {
      super.initState();
      _pageController = PageController(viewportFraction: 1);
      _pageController.addListener((){
        print("현재 스크롤 위치: ${_pageController.page}");
        if(_pageController.hasClients && meetings.length > 1) {
          // 진행률 = 현재 페이지 인덱스 / 최대 페이지 인덱스
          setState(() {
            _pageValue = (
              _pageController.page! / (meetings.length - 1)
            ).clamp(0.0, 1.0);
          });
        }//if문 끝
      });
    }
    // 컨트롤러 종료(메모리 누수 방지)
    @override
    void dispose() {
      _pageController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final meetings = ref.watch(gatheringMeetingProvider);
      double screenHeight = MediaQuery.of(context).size.height;
      double screenPaddingTop = MediaQuery.of(context).padding.top;
      double screenPaddingBottom = MediaQuery.of(context).padding.bottom;
      return Scaffold(
      backgroundColor: wazzupBackGround, // 배경

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 고정 : 섹션 제목
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('🔥이번 주 핫한 모임', style: sectionTitleFont),
            ),
            // ListView가 들어갈 곳
            SizedBox(
              height: (screenHeight - screenPaddingTop - screenPaddingBottom) * 0.15,
              child: PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  // 모임카드 수평으로 보여주기
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GatheringHorizontalCard(meeting: meetings[index]),
                  );
                },
                controller: _pageController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(10),
                value: _pageValue,
                backgroundColor: Color(0xFF),
                valueColor: AlwaysStoppedAnimation(Color(0xFFe497b8)),
              ),
            ),
          ],
        ),
      );
    }
}