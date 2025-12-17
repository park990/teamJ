import 'package:flutter/material.dart';

class AdBanner extends StatelessWidget {
  final String content;
  final Color backgroundColor;

  const AdBanner({
    this.content = '여기에 광고 배너(이미지)',
    this.backgroundColor = const Color(0xFFBDBDBD), //Colors.grey[400]
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      color: backgroundColor,
      alignment: Alignment.center,
      child: Text(
        content,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}