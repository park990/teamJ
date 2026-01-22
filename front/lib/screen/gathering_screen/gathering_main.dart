import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/screen/gathering_screen/providers/gathering_providers.dart';
import 'package:front/screen/gathering_screen/widgets/gathering_horizontal_card.dart';
import 'package:front/screen/gathering_screen/widgets/gathering_keywords.dart';
import 'package:front/screen/gathering_screen/widgets/gathering_section_header.dart';
import 'package:front/theme/app_colors.dart';

/// 모임 목록을 수평 스크롤로 보여주는 화면
class GatheringMain extends ConsumerStatefulWidget {
  GatheringMain({super.key});

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
    // Riverpod Provider에서 핫한 모임 데이터 가져오기
    final meetingsAsync = ref.watch(gatheringHotListProvider);

    // 화면 크기 계산 (상단/하단 패딩 제외한 실제 사용 가능한 높이)
    double screenHeight = MediaQuery.of(context).size.height;
    double screenPaddingTop = MediaQuery.of(context).padding.top;
    double screenPaddingBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: wazzupBackGround, // 배경
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. 첫번째 섹션
          const GatheringSectionHeader(title: '🔥 이번 주 핫한 모임'),
          // 모임 카드 수평 스크롤 영역 (화면 높이의 15%)
          //****************여기서부터 */
          meetingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            
            error: (err, stack) => Text('에러발생: $err'),
            data: (meetings) {
              return Column(
                children: [
                  //카드 영역(PageView)
                  SizedBox(
                    height:
                        (screenHeight - screenPaddingTop - screenPaddingBottom) * 0.15,
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
                          child: GatheringHorizontalCard(meeting: meetings[index].meetingInfo),
                        );
                      },
                    ),
                  ),
                  //인디케이터 영역(Row)
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //스프레드 연산자(...) - children[] 리스트 안에 다른 위젯들과 함께 사용 가능함
                    //점선 인디케이터를 모임카드 갯수만큼 생성
                    children: [
                      ...List.generate(meetingsAsync.value?.length ?? 0, (index) {
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
                    ],
                  ),
                ],
              );
            },
          ),
          
          // *************여기까지
          const SizedBox(height: 12),
          
          SizedBox(height: 12),
          // 페이지 진행률 표시 바
          const GatheringSectionHeader(title: '🔍 요즘 유행하는 키워드'),
          //키워드 태그 불러오기
          const GatheringKeywords(),
          SizedBox(height: 12),
          GatheringSectionHeader(
            title: '✨ 새로운 모임을 찾아봐요!',
            onTapAction: () {
              //TODO: 페이지 이동 함수 추가해야됨
              //executeHandleMoreButton();
            },
          ),
        ],
      ),
    );
  }
}
