import 'package:flutter/material.dart';

class UpperAppBar extends StatelessWidget {
  const UpperAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('WAZZUP')),
        Icon(Icons.search),
        SizedBox(width: 5),
        Icon(Icons.more_vert),
      ],
    );
  }
}
