import 'package:flutter/material.dart';
import 'package:front/config/global_keys.dart';
import 'package:front/config/init_setting.dart';
import 'package:front/screen/home_screen.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// flutter_smart_dialog 알림창
void main() async {
  await initAppSettings();
  runApp(
    ProviderScope(
      child: MaterialApp(
        navigatorKey: navigatorKey, // 화면 이동용 열쇠
        
        builder: FlutterSmartDialog.init(),
        navigatorObservers: [FlutterSmartDialog.observer],

        home: HomeScreen(),
      ),
    ),
  );
}
