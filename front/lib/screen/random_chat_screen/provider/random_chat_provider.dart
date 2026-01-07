import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/remote/websocket_client.dart';
import 'package:front/data/repository/random_match_repository.dart';
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

  // ✅ 생성 시 자동 WebSocket 연결
  debugPrint('▶ randomChatControllerProvider CALLED');
  controller.initialize();
  
  return controller;
});