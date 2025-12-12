import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:front/screen/randomChating_screen/random_chat_screen.dart';

class RandomChatMain extends StatefulWidget {
  const RandomChatMain({super.key});

  @override
  State<RandomChatMain> createState() => _RandomChatMainState();
}

class _RandomChatMainState extends State<RandomChatMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('랜덤채팅 메인 화면'),
            ElevatedButton(
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: Text('랜덤채팅을 시작하시겠습니까?'),
                    content: Column(
                      children: [
                        SizedBox(height: 20),
                        Text('성변 선택 채팅은 포인트를 소모합니다.'),
                        SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RandomChatScreen(),
                            ),
                          );
                        },
                        child: Text('여성과 채팅'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RandomChatScreen(),
                            ),
                          );
                        },
                        child: Text('남성과 채팅'),
                        ),
                        SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RandomChatScreen(),
                            ),
                          );
                        },
                        child: Text('랜덤채팅'),
                        ),
                      ],
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: Text('취소'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      // CupertinoDialogAction(
                      //   child: Text('시작'),
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => RandomChatScreen(),
                      //       ),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                );
              },
              child: Text('랜덤채팅 시작!'),
            ),
          ],
        ),
      ),
    );
  }
}

/*
() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => RandomChatScreen()),
  );
}
*/
