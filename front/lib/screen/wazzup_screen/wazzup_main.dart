import 'package:flutter/material.dart';

class WazzupMain extends StatelessWidget {
  const WazzupMain({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('WAZZUP 게시판')
        ),backgroundColor: Colors.grey,
      ),

      body: Column(
        children: [
          _BestBbs(),
          _BbsList(),
        ],
      ),
    );
  }
}

class _BestBbs extends StatelessWidget {
  const _BestBbs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.amber,
          width: double.infinity,
          child: Text("Best"),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.green,
              child: Text('긂ㅇㄴㄻㅇㄻㅇㄻㄹㄴㅇ'),
            ),
            Container(
              color: Colors.green,
              child: Text('긂ㅇㄴㄻㅇㄻㅇㄻㄹㄴㅇ'),
            ),
          ],
        ),
      ],
    );
  }
}

class _BbsList extends StatelessWidget {
  const _BbsList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> BbsTitle = ['자유게시판', '인연찾기', '운동게시판'];
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: BbsTitle.length,
        itemBuilder: (context, index) {
          final title = BbsTitle[index];
          return Column(
            children: [
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
