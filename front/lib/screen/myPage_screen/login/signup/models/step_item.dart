import 'package:flutter/material.dart';

enum StepType{
  text,gender
}
class StepItem {
  StepItem({
    required this.title,
    required this.hint,
    required this.stepIndex,
    required this.focusNode, // 커서 깜빡이 제어용
    required this.controller,

    // 값이 없으면 기본적으로 text
    this.type=StepType.text,
    
  });

  final String title;
  final String hint;
  final int stepIndex;
  final FocusNode focusNode;
  final StepType type;
  final TextEditingController controller;
}

List<StepItem> getSignupSteps() {
  return [
    StepItem(
      title: "이름",
      hint: '실명을 입력해 주세요.',
      stepIndex: 0,
      focusNode: FocusNode(),
      controller: TextEditingController(),
    ),
    StepItem(
      title: "닉네임",
      hint: 'wazzup에서 이용할 닉네임을 입력해 주세요.',
      stepIndex: 1,
      focusNode: FocusNode(),
      controller: TextEditingController(),

    ),
    StepItem(
      title: "생년월일",
      hint: '예) 20020609',
      stepIndex: 2,
      focusNode: FocusNode(),
      controller: TextEditingController(),
    ),
    StepItem(
      title: "휴대폰 번호",
      hint: '"-"제외',
      stepIndex: 3,
      focusNode: FocusNode(),
      controller: TextEditingController(),
    ),
    StepItem(
      title: "성별",
      hint: '',
      stepIndex: 4,
      focusNode: FocusNode(),
      controller: TextEditingController(),
      type: StepType.gender
    ),    
  ];
}
