import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/screen/random_chat_screen/provider/random_chat_provider.dart';

/// 채팅 전용 Controller
/// - 채팅 메시지 관리
/// - randomChatRoomIdxProvider에서 roomIdx 읽기 (Controller 간 직접 의존성 없음)
/// - 나중에 ChatRepository 주입 예정
class RandomChatController extends ChangeNotifier {
  final Ref ref; // Provider 접근용 (roomIdx 읽기)

  // TODO: 나중에 ChatRepository 주입 필요
  // final ChatRepository chatRepository;

  RandomChatController({
    required this.ref,
    // required this.chatRepository,  // 나중에 추가
  }) {
    debugPrint('🔥 RandomChatController CREATED hash=$hashCode');
  }

  /// ==========================
  /// roomIdx 읽기 (randomChatRoomIdxProvider에서)
  /// ==========================
  String? get roomIdx {
    return ref.read(randomChatRoomIdxProvider);
  }

  /// ==========================
  /// 채팅 메시지 리스트 (나중에 추가)
  /// ==========================
  // List<ChatMessage> _messages = [];
  // List<ChatMessage> get messages => _messages;

  /// ==========================
  /// 초기화 (나중에 ChatRepository 연동 시 구현)
  /// ==========================
  // Future<void> connectAndSubscribe() async {
  //   final currentRoomIdx = roomIdx;
  //   if (currentRoomIdx == null) {
  //     debugPrint('[RandomChatController] ❌ roomIdx가 null입니다.');
  //     return;
  //   }
  //
  //   // TODO: ChatRepository로 WebSocket 연결 및 구독
  //   // await chatRepository.connectAndSubscribe(currentRoomIdx);
  // }

  /// ==========================
  /// 메시지 전송 (나중에 ChatRepository 연동 시 구현)
  /// ==========================
  // Future<void> sendMessage(String content) async {
  //   final currentRoomIdx = roomIdx;
  //   if (currentRoomIdx == null) {
  //     debugPrint('[RandomChatController] ❌ roomIdx가 null입니다.');
  //     return;
  //   }
  //
  //   // TODO: ChatRepository로 메시지 전송
  //   // await chatRepository.sendMessage(currentRoomIdx, content);
  // }

  /// ==========================
  /// 연결 해제
  /// ==========================
  @override
  void dispose() {
    debugPrint('[RandomChatController] ▶ dispose() CALLED');
    // TODO: 나중에 ChatRepository disconnect 추가
    super.dispose();
  }
}
