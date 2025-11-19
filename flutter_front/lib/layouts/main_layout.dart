import 'package:flutter/material.dart';
// 위에서 만든 커스텀 하단 바 위젯과 화면 위젯을 불러옵니다.
 // 실제 경로로 수정 필요
import 'package:flutter_front/screens/home_screen.dart';        // 실제 경로로 수정 필요
    // (가정)

import 'package:flutter_front/widgets/jaeyoon.dart';     // (가정)

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스 (초기값: 0)

  // 각 탭에 연결할 스크린(페이지) 리스트
  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('검색 화면')), // 임시 화면
    const Center(child: Text('알림 화면')), // 임시 화면
    const Center(child: Text('마이 페이지')), // 임시 화면
  ];

  // 탭 클릭 시 인덱스를 업데이트하는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 Flutter 앱'),
        backgroundColor: Colors.teal,
      ),
      
      // 1. [body] 현재 선택된 인덱스에 해당하는 화면을 보여줍니다.
      body: _screens[_selectedIndex], 

      // 2. [bottomNavigationBar] 하단 바 컴포넌트 연결
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex, // 현재 상태 전달
        onTap: _onItemTapped,        // 상태 변경 함수 전달
      ),
    );
  }
}