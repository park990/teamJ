import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/data/data_source/remote/websocket_client.dart';
import 'package:front/data/repository/random_match_repository.dart';
import 'package:front/data/repository/chat_repository.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';
import 'package:front/screen/random_chat_screen/controller/random_match_controller.dart';
import 'package:front/screen/random_chat_screen/controller/random_chat_controller.dart';

/// 0. roomIdx 공유 Provider (Controller 간 직접 의존성 없이 roomIdx만 공유)
/// - RandomMatchController: 매칭 완료 시 roomIdx 설정
/// - RandomChatController: 채팅 시 roomIdx 읽기
final randomChatRoomIdxProvider = StateProvider<String?>((ref) => null);

/// 1. Repository Provider
final randomMatchRepositoryProvider = Provider<RandomMatchRepository>((ref) {
  return RandomMatchRepository(ref.read(webSocketClientProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    wsClient: ref.read(webSocketClientProvider),
    apiClient: ref.read(apiClientProvider),
  );
});

/// 2. RandomMatchController Provider (매칭 전용)
final randomMatchControllerProvider =
    ChangeNotifierProvider<RandomMatchController>((ref) {
      final controller = RandomMatchController(
        matchRepository: ref.read(randomMatchRepositoryProvider),
        ref: ref, // Provider 접근용
      );

      // ✅ 초기 userIdx 설정 (Provider 생성 시점의 값)
      final initialUserIdx = ref.read(authControllerProvider).userIdx;
      if (initialUserIdx != null) {
        controller.setUserIdx(initialUserIdx);
        debugPrint('[RandomMatchProvider] 초기 userIdx 설정: $initialUserIdx');
      }

      // ✅ 이후 변경 감지 userIdx 변경 감지 → 자동으로 setUserIdx() 호출
      ref.listen(authControllerProvider, (previous, next) {
        final newUserIdx = next.userIdx;
        debugPrint(
          '[RandomMatchProvider] 🔄 userIdx 변경 감지: ${previous?.userIdx} → $newUserIdx',
        );
        controller.setUserIdx(newUserIdx);
      });

      debugPrint('▶ randomMatchControllerProvider CALLED');
      return controller;
    });

/// 3. RandomChatController Provider (채팅 전용) - 나중에 구현 예정
final randomChatControllerProvider =
    ChangeNotifierProvider<RandomChatController>((ref) {
      // TODO: 나중에 ChatRepository 주입 필요
      final controller = RandomChatController(
        // chatRepository: ref.read(chatRepositoryProvider),  // 나중에 추가
        ref: ref, // Provider 접근용 (roomIdx 읽기)
      );

      debugPrint('▶ randomChatControllerProvider CALLED');
      return controller;
    });
