import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/provider/random_chat_provider.dart';
import 'package:front/screen/random_chat_screen/models/random_chat_state.dart';
import 'package:front/screen/random_chat_screen/random_chat_screen.dart';
import 'package:front/theme/app_colors.dart';

class RandomChatMain extends ConsumerWidget {
  RandomChatMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final controller = ref.watch(randomChatControllerProvider);
    final randomChatState = controller.state;

    debugPrint('[RandomChatMain] build - status=${randomChatState.status}');

    print('randomChatState: ${randomChatState.status}');
    if (randomChatState.status == RandomChatStatus.matching) {
      debugPrint('[RandomChatMain] UI = MATCHING');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('매칭 중입니다...'),
            ],
          ),
        ),
      );
    } else if (randomChatState.status == RandomChatStatus.error) {
      debugPrint('[RandomChatMain] UI = ERROR');
      return Column(
        children: [
          Text('매칭 실패'),
          Text(randomChatState.errorMessage ?? ''),
          ElevatedButton(
            onPressed: () {
              ref.read(randomChatControllerProvider)
                .reset(); // idle로
            },
            child: Text('다시 시도'),
          ),
        ],
      );
    } else {
      debugPrint('[RandomChatMain] UI = IDLE');
      return Scaffold(
      backgroundColor: wazzupBackGround, // 배경

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
                              Navigator.pop(context); // 다이얼로그 닫기

                              ref
                                  .read(randomChatControllerProvider)
                                  .startMatching(genderOption: 'random');
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
}
