import 'package:flutter/material.dart';

// 하단 바의 모양(items)만 정의하는 Stateless Widget
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex, // 현재 활성화된 탭 인덱스
    required this.onTap,        // 탭이 클릭되었을 때 실행할 함수
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // 아이템이 많아도 크기가 변하지 않게 고정
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '검색',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: '알림',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: '마이',
        ),
      ],
    );
  }
}