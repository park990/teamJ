import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/remote/websocket_client.dart';
import 'package:front/data/repository/random_match_repository.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';
import 'package:front/screen/random_chat_screen/controller/random_chat_controller.dart';


/// 1. Repository Provider
final randomMatchRepositoryProvider =
    Provider<RandomMatchRepository>((ref) {
  return RandomMatchRepository(
    ref.read(webSocketClientProvider),
  );
});

/// 2. Controller Provider
final randomChatControllerProvider =
    ChangeNotifierProvider<RandomChatController>((ref) {

  final controller = RandomChatController(
    matchRepository: ref.read(randomMatchRepositoryProvider),
  );

  // userIdx 변경 감지 → 자동으로 setUserIdx() 호출
  ref.listen(authControllerProvider, (previous, next) {
    final newUserIdx = next.userIdx;
    debugPrint('[RandomChatProvider] 🔄 userIdx 변경 감지: ${previous?.userIdx} → $newUserIdx');
    controller.setUserIdx(newUserIdx);
  });

  debugPrint('▶ randomChatControllerProvider CALLED');  
  return controller;
});