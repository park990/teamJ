import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/config/init_setting.dart';
import 'package:front/screen/home_screen.dart';
import 'package:get/get.dart';

void main() async {
  await initAppSettings();

  runApp(
    ProviderScope(
      child: GetMaterialApp(
        home: HomeScreen(),
      ),
    ),
  );
  
}