import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/provider/gathering_meeting_provider.dart';
import 'package:front/screen/gathering_screen/widgets/gathering_horizontal_card.dart';
import 'package:front/screen/gathering_screen/widgets/gathering_keywords.dart';
import 'package:front/theme/app_colors.dart';

/// 모임 목록을 수평 스크롤로 보여주는 화면
class GatheringMain extends ConsumerStatefulWidget {
  GatheringMain({
    super.key,
  });

  @override
  ConsumerState<GatheringMain> createState() => _GatheringMainState();
}

class _GatheringMainState extends ConsumerState<GatheringMain>
  with TickerProviderStateMixin {
    // 현재 페이지 진행률 (0 ~ 1)
    int _currentPage = 0;

    // PageView 스크롤 제어를 위한 컨트롤러
    late PageController _pageController;

    /// 위젯 초기화: PageController 생성 및 스크롤 리스너 등록
    @override
    void initState() {
      super.initState();
      // PageController 생성 (viewportFraction: 1 = 전체 화면 크기)
      _pageController = PageController(viewportFraction: 1);
    }
    // 컨트롤러 종료(메모리 누수 방지)
    @override
    void dispose() {
      _pageController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      // Riverpod Provider에서 모임 데이터 가져오기
      final meetings = ref.watch(gatheringMeetingProvider);
      
      // 화면 크기 계산 (상단/하단 패딩 제외한 실제 사용 가능한 높이)
      double screenHeight = MediaQuery.of(context).size.height;
      double screenPaddingTop = MediaQuery.of(context).padding.top;
      double screenPaddingBottom = MediaQuery.of(context).padding.bottom;
      
      return Scaffold(
        backgroundColor: wazzupBackGround, // 배경
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 섹션 제목 (고정)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('🔥이번 주 핫한 모임', style: sectionTitleFont),
            ),
            // 모임 카드 수평 스크롤 영역 (화면 높이의 15%)
            SizedBox(
              height: (screenHeight - screenPaddingTop - screenPaddingBottom) * 0.15,
              child: PageView.builder(
                // 좌우 스크롤
                scrollDirection: Axis.horizontal,
                itemCount: meetings.length,
                // 스크롤 제어를 위한 컨트롤러 연결
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    //사용자가 넘긴 페이지 번호를 상태에 저장.
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  // 각 모임 카드를 수평 카드 위젯으로 표시
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GatheringHorizontalCard(meeting: meetings[index]),
                  );
                },
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //스프레드 연산자(...) - children[] 리스트 안에 다른 위젯들과 함께 사용 가능함
              //점선 인디케이터를 모임카드 갯수만큼 생성
              children: [...List.generate(meetings.length, (index){
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  width: 16.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? wazzupButton : Colors.white,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  );
              }),
              ]
            ),
            SizedBox(
              height: 12,
            ),
            // 페이지 진행률 표시 바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            GatheringKeywords(),
          ],
        ),
      );
    }
}