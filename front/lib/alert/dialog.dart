import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class WazzupToast {
  
  // 1. 에러/경고 토스트 (로그아웃, 실패 등)
  static void showError(String msg) {
    SmartDialog.showToast(
      '',
      builder: (_) => _buildToast(msg, Icons.error_outline, Colors.redAccent),
      displayTime: const Duration(seconds: 3),
    );
  }

  // 2. 성공 토스트 (회원가입 성공, 저장 완료 등)
  static void showSuccess(String msg) {
    SmartDialog.showToast(
      '',
      builder: (_) => _buildToast(msg, Icons.check_circle_outline, Colors.blueAccent),
      displayTime: const Duration(seconds: 2),
    );
  }

  // 공통 디자인 위젯 (내부에서만 씀)
  static Widget _buildToast(String msg, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30), // 하단에서 살짝 띄우기
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Flexible( // 글자가 길어지면 줄바꿈 되도록
            child: Text(
              msg,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}