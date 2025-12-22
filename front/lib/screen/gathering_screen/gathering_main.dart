import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repository/gathering_repository.dart';
import 'package:front/provider/gathering_meeting_provider.dart';
import 'package:front/screen/gathering_screen/widgets/gathering_horizontal_card.dart';
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
    // 현재 페이지 진행률 (0.0 ~ 1.0)
    double _pageValue = 0;

    // PageView 스크롤 제어를 위한 컨트롤러
    late PageController _pageController;

    /// 위젯 초기화: PageController 생성 및 스크롤 리스너 등록
    @override
    void initState() {
      super.initState();
      // PageController 생성 (viewportFraction: 1 = 전체 화면 크기)
      _pageController = PageController(viewportFraction: 1);
      // 페이지 스크롤 시 진행률 업데이트 리스너 등록
      _pageController.addListener((){
        print("현재 스크롤 위치: ${_pageController.page}");
        // 컨트롤러가 연결되어 있고 모임이 2개 이상일 때만 진행률 계산
        if(_pageController.hasClients && meetings.length > 1) {
          // 진행률 = 현재 페이지 인덱스 / 최대 페이지 인덱스
          setState(() {
            _pageValue = (
              _pageController.page! / (meetings.length - 1)
            ).clamp(0.0, 1.0); // 0.0 ~ 1.0 사이로 제한
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
                scrollDirection: Axis.horizontal, // 좌우 스크롤
                itemCount: meetings.length,
                controller: _pageController, // 스크롤 제어를 위한 컨트롤러 연결
                itemBuilder: (context, index) {
                  // 각 모임 카드를 수평 카드 위젯으로 표시
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GatheringHorizontalCard(meeting: meetings[index]),
                  );
                },
              ),
            ),
            // 페이지 진행률 표시 바
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