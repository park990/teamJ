import 'package:flutter/material.dart';
import 'package:front/screen/Basic_Bar_screen.dart';
import 'package:front/screen/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('WAZZUP')),
      ),
      body: BottomNavBar()
    );
  }
}