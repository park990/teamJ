import 'package:flutter/material.dart';
import 'package:front/screen/nav_bar_screen/bottom_nav_bar.dart';
import 'package:front/screen/nav_bar_screen/upper_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 3),
          child: UpperAppBar(),
        ),
      ),
      body: BottomNavBar()
    );
  }
}