import 'package:flutter/material.dart';
import 'package:front/theme/app_colors.dart';

class UpperAppBar extends StatelessWidget {
  const UpperAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // --- 추가된 부분 시작 ---
        Icon(
          Icons.local_florist, // 벚꽃과 비슷한 기본 꽃 아이콘
          color: wazzupButton, // 벚꽃색 (연분홍) 지정
          size: 24, // 아이콘 크기 조절 (필요시)
        ),
        const SizedBox(width: 8), // 아이콘과 글자 사이 간격 띄우기
        // --- 추가된 부분 끝 ---

        // 기존 텍스트 위젯
        Expanded(
          child: Text(
            'WAZZUP',
            // 기존 스타일 유지 (배경색에 따라 글자색 조정 필요할 수 있음)
            style: wazzupBarFont.copyWith(color: wazzupButton) 
          ),
        ),
        
        // 오른쪽 아이콘들
        const Icon(Icons.search),
        const SizedBox(width: 10),
        const Icon(Icons.notifications_none),
      ],
    );
  }
}