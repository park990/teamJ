import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Lucide 아이콘 권장

class WazzupToast {
  // 1. 에러/경고 토스트
  static void showError(String msg) {
    SmartDialog.dismiss(status: SmartStatus.toast);

    SmartDialog.showToast(
      '',
      alignment: Alignment.topCenter,
      builder: (_) => SafeArea(
        child: _buildToastWidget(
          msg: msg,
          iconData: LucideIcons.alertCircle, // 에러에 적합한 아이콘
          color: Colors.redAccent,
        ),
      ),
      displayTime: const Duration(seconds: 3),
    );
  }

  // 2. 성공 토스트
  static void showSuccess(String msg) {
    SmartDialog.dismiss(status: SmartStatus.toast);

    SmartDialog.showToast(
      '',
      alignment: Alignment.topCenter,
      builder: (_) => SafeArea(
        child: _buildToastWidget(
          msg: msg,
          iconData: LucideIcons.checkCircle2, // 성공에 적합한 아이콘
          color: Colors.blueAccent,
        ),
      ),
      displayTime: const Duration(seconds: 2),
    );
  }

  // --- 공통 디자인 위젯 (통합 및 최적화) ---
  static Widget _buildToastWidget({
    required String msg,
    required IconData iconData,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95), // 살짝 투명해서 더 세련됨
        borderRadius: BorderRadius.circular(30), // 완전한 캡슐 모양
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 내용물만큼만 차지
        children: [
          // 아이콘 배경 동그라미
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              msg,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF2D2D2D), // 부드러운 검정색
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}