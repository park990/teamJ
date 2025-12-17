import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color backColor;
  final Color textColor;

  const SocialLoginButtons({
    super.key,
    required this.onPressed,
    required this.backColor,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
        backgroundColor: backColor,
      ),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }
}
