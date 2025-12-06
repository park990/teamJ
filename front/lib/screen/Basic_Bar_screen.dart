import 'package:flutter/material.dart';
import 'package:front/const/tabs.dart';

class BasicBarScreen extends StatelessWidget {
  const BasicBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: TABS.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('BasicAppBarScreen'),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: TabBar(
              indicatorColor:Colors.red ,
              indicatorWeight: 4,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.black,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w900,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w100
              ),
              tabs: TABS.map(
              (e)=> Tab(
                icon: Icon(e.icon),
                child: Text(e.label),
              )
            ).toList()
            ),
          ),
        ),
        body: TabBarView(
          children: TABS.map(
            (e)=> Center(
              child: Icon(
                e.icon
              ),
            )
          ).toList()
        ),
      ),
    );
  }
}
