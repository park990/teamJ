import 'package:flutter/material.dart';

class GatheringMain extends StatefulWidget {
  const GatheringMain({super.key});

  @override
  State<GatheringMain> createState() => _GatheringMainState();
}

class _GatheringMainState extends State<GatheringMain> 
  with TickerProviderStateMixin {

    bool isSearching = false;
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          children: [
            TabBar(
              controller: TabController(
                length: 4,
                vsync: this,
              ),
              tabs: [
                Tab(text: '홈'),
                Tab(text: '추천'),
                Tab(text: '탐색'),
                Tab(text: '내 모임'),
              ],
            ),
          ],
        ),
      );
    }
}