import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WazzupToast {
  static DateTime? _lastShowTime;
  static const _throttleDuration = Duration(seconds: 2);

  // 1. 에러/경고 토스트
  static void showError(String msg) {
    _show(
      msg: msg,
      iconData: LucideIcons.alertCircle,
      color: Colors.redAccent,
      displayTime: const Duration(seconds: 3),
    );
  }

  // 2. 성공 토스트
  static void showSuccess(String msg) {
    _show(
      msg: msg,
      iconData: LucideIcons.checkCircle2,
      color: Colors.blueAccent,
      displayTime: const Duration(seconds: 2),
    );
  }

  // --- [공통] 토스트 실행 로직 (연타 방지 및 설정 통합) ---
  static void _show({
    required String msg,
    required IconData iconData,
    required Color color,
    required Duration displayTime,
  }) {
    final now = DateTime.now();
    
    // [공통 로직] 연타 방지 체크
    if (_lastShowTime != null && 
        now.difference(_lastShowTime!) < _throttleDuration) {
      return;
    }
    _lastShowTime = now;

    // 기존 토스트 즉시 제거
    SmartDialog.dismiss(status: SmartStatus.toast);

    // 토스트 표시
    SmartDialog.showToast(
      '',
      alignment: Alignment.topCenter,
      consumeEvent: false,
      displayTime: displayTime,
      builder: (_) => SafeArea(
        child: _buildToastWidget(
          msg: msg,
          iconData: iconData,
          color: color,
        ),
      ),
    );
  }

  // --- [공통] 디자인 위젯 ---
  static Widget _buildToastWidget({
    required String msg,
    required IconData iconData,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
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
                color: Color(0xFF2D2D2D),
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}