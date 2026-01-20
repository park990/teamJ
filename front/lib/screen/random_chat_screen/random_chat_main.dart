import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/screen/random_chat_screen/provider/random_chat_provider.dart';
import 'package:front/screen/random_chat_screen/models/random_chat_state.dart';
import 'package:front/screen/random_chat_screen/random_chat_screen.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';
import 'package:front/theme/app_colors.dart';

class RandomChatMain extends ConsumerStatefulWidget {
  const RandomChatMain({super.key});

  @override
  ConsumerState<RandomChatMain> createState() => _RandomChatMainState();
}

class _RandomChatMainState extends ConsumerState<RandomChatMain>
    with WidgetsBindingObserver {
  // 클래스에 앱 라이프사이클 관찰자 추가 : 앱이 백그라운드로 이동할 때 매칭 취소 요청을 보낼 수 있게 하기 위해
  @override
  void initState() {
    super.initState();

    // 다른 화면들과 동일하게 authController 초기화
    Future.microtask(() {
      ref.read(authControllerProvider.notifier).init();
    });

    // 앱 라이프사이클 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
  }

  // 앱 라이프사이클 상태 변경 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint('[RandomChatMain] didChangeAppLifecycleState - $state');

    // paused 상태: 앱이 백그라운드로 이동
    if (state == AppLifecycleState.paused) {
      final controller = ref.read(randomMatchControllerProvider);
      final currentStatus = controller.state.status;

      // 매칭 중일 때만 취소 요청
      if (currentStatus == RandomChatStatus.matching) {
        debugPrint('[RandomChatMain] ⏸️ 백그라운드 이동 감지 → 매칭 취소 요청');
        controller.cancelMatching();
      }
    }
  }

  @override
  void dispose() {
    // 앱 라이프사이클 관찰자 해제
    debugPrint('[RandomChatMain] dispose - 앱 라이프사이클 관찰자 해제');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(randomMatchControllerProvider);
    final randomChatState = controller.state;

    // ✅ 1. userIdx 가져오기
    final authState = ref.watch(authControllerProvider);
    final userIdx = authState.userIdx;

    debugPrint('[RandomChatMain] build - status=${randomChatState.status}');

    // ✅ 2. 매칭 성공 시 자동 화면 이동
    ref.listen(randomMatchControllerProvider, (previous, next) {
      if (next.state.status == RandomChatStatus.matched) {
        debugPrint('🎉 매칭 성공! 채팅 화면으로 이동 - roomIdx: ${next.state.roomIdx}');

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RandomChatScreen()),
        );
      }
    });

    print('randomChatState: ${randomChatState.status}');
    if (randomChatState.status == RandomChatStatus.matching) {
      debugPrint('[RandomChatMain] UI = MATCHING');
      return Scaffold(
        backgroundColor: wazzupBackGround, // 배경색 통일
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('매칭 중입니다...'),
              SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {
                  ref.read(randomMatchControllerProvider).cancelMatching();
                },
                child: Text('매칭 취소'),
              ),
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
              ref.read(randomMatchControllerProvider).reset(); // idle로
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

                              // ✅ 3. userIdx 전달
                              if (userIdx == null) {
                                debugPrint('❌ userIdx가 null입니다. 로그인이 필요합니다.');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('로그인이 필요합니다.')),
                                );
                                return;
                              }

                              ref
                                  .read(randomMatchControllerProvider)
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
