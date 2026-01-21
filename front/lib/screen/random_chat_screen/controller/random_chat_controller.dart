import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repository/chat_repository.dart';
import 'package:front/dto/chat_dto.dart';
import 'package:front/screen/random_chat_screen/provider/random_chat_provider.dart';

/// 채팅 전용 Controller
/// - 채팅 메시지 관리
/// - randomChatRoomIdxProvider에서 roomIdx 읽기 (Controller 간 직접 의존성 없음)
/// - ChatRepository를 통한 WebSocket 구독 및 메시지 전송
class RandomChatController extends ChangeNotifier {
  final ChatRepository chatRepository;
  final Ref ref; // Provider 접근용 (roomIdx 읽기)

  RandomChatController({required this.chatRepository, required this.ref}) {
    debugPrint('🔥 RandomChatController CREATED hash=$hashCode');
  }

  /// ==========================
  /// roomIdx 읽기 (randomChatRoomIdxProvider에서)
  /// ==========================
  String? get roomIdx {
    return ref.read(randomChatRoomIdxProvider);
  }

  /// ==========================
  /// 채팅 메시지 리스트 관리
  /// ==========================
  final List<ChatDto> _messages = [];
  List<ChatDto> get messages => List.unmodifiable(_messages);

  /// 메시지 추가 (실시간 수신 시)
  void _addMessage(ChatDto message) {
    // 중복 체크 (chatIdx로)
    if (_messages.any((m) => m.chatIdx == message.chatIdx)) {
      debugPrint('[RandomChatController] ⚠️ 중복 메시지 무시: ${message.chatIdx}');
      return;
    }

    _messages.add(message);
    notifyListeners();
    debugPrint(
      '[RandomChatController] ✅ 메시지 추가: ${message.chatIdx} (총 ${_messages.length}개)',
    );
  }

  /// 메시지 리스트 초기화
  void clearMessages() {
    _messages.clear();
    notifyListeners();
    debugPrint('[RandomChatController] ♻️ 메시지 리스트 초기화');
  }

  /// ==========================
  /// WebSocket 구독 시작
  /// ==========================
  /// - roomIdx 기반으로 `/topic/room/{roomIdx}` 구독
  /// - 실시간 메시지 수신 시 _messages에 추가
  /// - **확장성**: 나중에 초기 데이터 로딩 추가 가능
  Future<void> connectAndSubscribe() async {
    final currentRoomIdx = roomIdx;
    if (currentRoomIdx == null) {
      debugPrint('[RandomChatController] ❌ roomIdx가 null입니다.');
      throw Exception('roomIdx가 설정되지 않았습니다. 먼저 매칭을 완료해주세요.');
    }

    try {
      debugPrint(
        '[RandomChatController] 🔌 채팅 구독 시작 - roomIdx: $currentRoomIdx',
      );

      await chatRepository.connectAndSubscribe(
        roomIdx: currentRoomIdx,
        onMessage: (ChatDto message) {
          // 실시간 메시지 수신 시 리스트에 추가
          _addMessage(message);
        },
      );

      debugPrint('[RandomChatController] ✅ 채팅 구독 완료');
    } catch (e, s) {
      debugPrint('[RandomChatController] ❌ 채팅 구독 실패: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  /// ==========================
  /// 메시지 전송
  /// ==========================
  /// - `/app/chat/{roomIdx}/send`로 전송
  /// - **확장성**: 나중에 Optimistic UI 추가 가능
  Future<void> sendMessage(String content) async {
    final currentRoomIdx = roomIdx;
    if (currentRoomIdx == null) {
      debugPrint('[RandomChatController] ❌ roomIdx가 null입니다.');
      throw Exception('roomIdx가 설정되지 않았습니다.');
    }

    if (content.trim().isEmpty) {
      debugPrint('[RandomChatController] ⚠️ 빈 메시지는 전송할 수 없습니다.');
      return;
    }

    try {
      debugPrint('[RandomChatController] 📤 메시지 전송 - content: $content');

      await chatRepository.sendMessage(
        roomIdx: currentRoomIdx,
        content: content.trim(),
      );

      debugPrint('[RandomChatController] ✅ 메시지 전송 요청 완료');
      // 실제 메시지는 WebSocket으로 브로드캐스트되어 onMessage 콜백으로 수신됨
    } catch (e, s) {
      debugPrint('[RandomChatController] ❌ 메시지 전송 실패: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  /// ==========================
  /// 채팅 구독 해제
  /// ==========================
  void unsubscribeFromChat() {
    final currentRoomIdx = roomIdx;
    if (currentRoomIdx != null) {
      chatRepository.unsubscribeFromChat(currentRoomIdx);
      debugPrint('[RandomChatController] 🔌 채팅 구독 해제 완료');
    }
  }

  /// ==========================
  /// 연결 해제
  /// ==========================
  @override
  void dispose() {
    debugPrint('[RandomChatController] ▶ dispose() CALLED');
    unsubscribeFromChat();
    clearMessages();
    super.dispose();
  }
}
