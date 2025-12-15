import 'package:flutter/material.dart';
import 'package:front/theme/app_colors.dart';

class UpperAppBar extends StatelessWidget {
  const UpperAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('WAZZUP',style: wazzupFont)),
        Icon(Icons.search),
        SizedBox(width: 10),
        Icon(Icons.notifications_none),
        SizedBox(width: 10),
        Icon(Icons.more_vert),
      ],
    );
  }
}
