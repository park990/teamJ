import 'package:flutter/material.dart';
import 'package:front/theme/app_colors.dart';

class GatheringSectionHeader extends StatelessWidget {
  final String title;
  final String actionText; // 버튼에 표시될 텍스트('더 보기 >')
  final VoidCallback? onTapAction; //버튼 클릭 시 콜백함수 실행

  const GatheringSectionHeader({
    required this.title, //반드시 title을 전달 받아야함
    this.actionText = '더 보기 >',
    this.onTapAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // 더보기 버튼이 타이틀보다 살짝 아래 위치시킴
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 1. 섹션 타이틀
          Text(
            title,
            style: sectionTitleFont,
          ),
          // 2. 조건부 버튼 렌더링
          if(onTapAction != null)
            GestureDetector(
              onTap: onTapAction,
              child: Text(
                // '더 보기 >'
                actionText,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
        ],
      ),
    );
  }
}