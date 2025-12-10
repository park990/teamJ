import 'package:flutter/material.dart';
import 'package:front/screen/config/init_setting.dart';
import 'package:front/screen/home_screen.dart';

void main() async {
  await initAppSettings();

  runApp(
    MaterialApp(
      home: HomeScreen()
    ),
  );
}