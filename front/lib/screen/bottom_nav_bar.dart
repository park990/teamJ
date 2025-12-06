import 'package:flutter/material.dart';
import 'package:front/const/tabs.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with TickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController=TabController(length: TABS.length, vsync: this);
    tabController.addListener(_onTabChanger);
  }
  @override
  void dispose() {
    tabController.removeListener(_onTabChanger);
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // 센터 화면
      body: _Center(tabController: tabController),

      // 바텀 네비 화면
      bottomNavigationBar: _BottomNavItems(tabController: tabController)
    );
  }

  // 함수
  void _onTabChanger(){
    if(!tabController.indexIsChanging){
      // 여기서 !를 넣어준 이유는 indexchanging 이 끝났을(false) 때 탭이 바뀌는 비동기적 처리임
      setState(() {});
    }
  }
}

// Center 화면 
class _Center extends StatelessWidget {
  final TabController tabController;
  const _Center({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: TABS
          .map((e) => Center(
            child: Text(
              '${e.label}화면',
              ),
            ),
          )
          .toList(),
    );
  }
}

// 바텀 NAV 화면
class _BottomNavItems extends StatelessWidget {
  final TabController tabController;
  const _BottomNavItems({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedItemColor: Colors.black,
      type: BottomNavigationBarType.fixed,

      // 탭 컨트롤러의 index를 currentIndex로 적용
      currentIndex: tabController.index,

      // 탭을 눌렀을 때 tabcontroller에게 클릭한 index 부여
      onTap: (index) {
        tabController.animateTo(index);
      },
      items: TABS
          .map(
            (e) => BottomNavigationBarItem(
              icon: Icon(e.icon),
              label: e.label,
            ),
          )
          .toList(),
    );
  }
}
