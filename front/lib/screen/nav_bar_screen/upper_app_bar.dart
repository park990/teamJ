import 'package:flutter/material.dart';
import 'package:front/theme/app_colors.dart';

class UpperAppBar extends StatelessWidget {
  const UpperAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      // 1. 모든 요소를 수직 중앙(Center)에 정렬합니다.
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 첫 번째 벚꽃
        Image.asset(
          'asset/img/sakura2.png',
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),

        // 2. 텍스트와 두 번째 벚꽃을 하나의 그룹으로 묶되, 별도의 Row 없이 나열합니다.
        Text(
          '봄밍',
          style: wazzupBarFont.copyWith(
            color: wazzupButton,
            // 3. 글자가 너무 아래로 처진다면 height를 조절해 보세요.
            height: 1.2, 
          ),
        ),
        const SizedBox(width: 8),

        // 4. 나머지 아이콘들을 오른쪽 끝으로 밀어내기 위해 Spacer를 사용합니다.
        const Spacer(),

        // 오른쪽 아이콘들
        const Icon(Icons.search),
        const SizedBox(width: 10),
        const Icon(Icons.notifications_none),
        const SizedBox(width: 10),
      ],
    );
  }
}