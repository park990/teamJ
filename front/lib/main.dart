import 'package:flutter/material.dart';
import 'package:front/config/global_keys.dart';
import 'package:front/config/init_setting.dart';
import 'package:front/screen/home_screen.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/widgets/matching_status_overlay.dart';

// flutter_smart_dialog 알림창
void main() async {
  await initAppSettings();
  runApp(
    ProviderScope(
      child: MaterialApp(
        navigatorKey: navigatorKey, // 화면 이동용 열쇠
        // ✅ FlutterSmartDialog와 전역 오버레이를 함께 사용
        builder: (context, child) {
          // FlutterSmartDialog의 builder를 먼저 적용
          child = FlutterSmartDialog.init()(context, child);

          // 그 위에 매칭 상태 오버레이 추가
          return Stack(
            children: [
              child, // 실제 앱 화면 (FlutterSmartDialog 포함)
              // ✅ 전역 오버레이: 매칭 상태 배너
              const MatchingStatusOverlay(),
            ],
          );
        },
        navigatorObservers: [FlutterSmartDialog.observer],

        home: HomeScreen(),
      ),
    ),
  );
}
