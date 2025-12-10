import 'package:flutter/material.dart';

class BuildsocialLoginButtons extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color backColor;
  final Color textColor;

  const BuildsocialLoginButtons({
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
