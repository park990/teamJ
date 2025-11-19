import 'package:flutter/material.dart';

// 이 클래스는 하단에 5개 버튼을 가로로 배치하는 위젯입니다
class Sjs extends StatelessWidget {
  const Sjs({super.key});

  // build 메서드는 화면에 무엇을 그릴지 정의합니다
  @override
  Widget build(BuildContext context) {
    // Container는 박스처럼 배경색, 패딩 등을 설정할 수 있습니다
    return Container(
      height: 60, // 높이 60
      color: Colors.grey[200], // 배경색 회색
      // Row는 자식들을 가로로 배치합니다
      child: Row(
        // mainAxisAlignment는 가로축 정렬 방법입니다
        // spaceEvenly는 버튼들을 균등하게 분배합니다
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 버튼 1
          ElevatedButton(
            onPressed: () {
              // 버튼을 눌렀을 때 실행될 코드
              print('버튼 1 클릭');
            },
            child: const Text('모임'),
          ),
          // 버튼 2
          ElevatedButton(
            onPressed: () {
              print('버튼 2 클릭');
            },
            child: const Text('랜덤'),
          ),
          // 버튼 3
          ElevatedButton(
            onPressed: () {
              print('버튼 3 클릭');
            },
            child: const Text('⏏︎'),
          ),
          // 버튼 4
          ElevatedButton(
            onPressed: () {
              print('버튼 4 클릭');
            },
            child: const Text('친구'),
          ),
          // 버튼 5
          ElevatedButton(
            onPressed: () {
              print('버튼 5 클릭');
            },
            child: const Text('내 정보'),
          ),
        ],
      ),
    );
  }
}
