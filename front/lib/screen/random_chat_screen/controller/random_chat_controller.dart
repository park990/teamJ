import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repository/chat_repository.dart';
import 'package:front/dto/chat_dto.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';
import 'package:front/screen/random_chat_screen/mapper/random_chat_ui_mapper.dart';
import 'package:front/screen/random_chat_screen/models/random_chat_ui_model.dart';
import 'package:front/screen/random_chat_screen/provider/random_chat_provider.dart';
import 'package:uuid/uuid.dart';

/// 채팅 전용 Controller
/// - 채팅 메시지 관리 (ChatUiModel 리스트)
/// - randomChatRoomIdxProvider에서 roomIdx 읽기 (Controller 간 직접 의존성 없음)
/// - ChatRepository를 통한 WebSocket 구독 및 메시지 전송
/// - Optimistic UI 지원 (pending, sent, failed 상태)
class RandomChatController extends ChangeNotifier {
  final ChatRepository chatRepository;
  final Ref ref; // Provider 접근용 (roomIdx, myUserIdx 읽기)

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
  /// myUserIdx 읽기 (authControllerProvider에서)
  /// ==========================
  int? get myUserIdx {
    return ref.read(authControllerProvider).userIdx;
  }

  /// ==========================
  /// 채팅 메시지 리스트 관리 (ChatUiModel)
  /// ==========================
  final List<ChatUiModel> _messages = [];
  List<ChatUiModel> get messages => List.unmodifiable(_messages);

  /// 메시지 추가 (실시간 수신 시 - ChatDto → ChatUiModel 변환)
  void _addMessage(ChatDto dto) {
    final myIdx = myUserIdx;
    if (myIdx == null) {
      debugPrint('[RandomChatController] ⚠️ myUserIdx가 null입니다.');
      return;
    }

    // 중복 체크 (chatIdx로)
    if (_messages.any((m) => m.userIdx == dto.userIdx.toString() && 
                             m.message == dto.content && 
                             m.status == MessageStatus.sent)) {
      debugPrint('[RandomChatController] ⚠️ 중복 메시지 무시: ${dto.chatIdx}');
      return;
    }

    // 내가 보낸 메시지인 경우: pending 메시지를 찾아서 제거
    if (dto.userIdx == myIdx) {
      final pendingIndex = _messages.indexWhere(
        (m) => m.isMe && 
               m.status == MessageStatus.pending && 
               m.message == dto.content,
      );

      if (pendingIndex != -1) {
        debugPrint(
          '[RandomChatController] 🔄 Pending 메시지를 실제 메시지로 교체: ${dto.chatIdx}',
        );
        _messages.removeAt(pendingIndex);
      }
    }

    // ChatDto → ChatUiModel 변환
    final uiModel = ChatUiMapper.toUiModel(dto: dto, myUserId: myIdx);
    _messages.add(uiModel);
    notifyListeners();
    debugPrint(
      '[RandomChatController] ✅ 메시지 추가: ${dto.chatIdx} (총 ${_messages.length}개)',
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
  /// 메시지 전송 (Optimistic UI)
  /// ==========================
  /// - 즉시 UI에 pending 메시지 추가
  /// - `/app/chat/{roomIdx}/send`로 전송
  /// - 실패 시 failed로 변경
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

    final myIdx = myUserIdx;
    if (myIdx == null) {
      debugPrint('[RandomChatController] ❌ myUserIdx가 null입니다.');
      throw Exception('사용자 정보를 가져올 수 없습니다.');
    }

    // 1. Optimistic UI: 임시 메시지 생성 및 즉시 추가
    final tempId = const Uuid().v4();
    final now = DateTime.now();
    final authState = ref.read(authControllerProvider);
    final myNickname = authState.nickName ?? '나';
    // TODO: AuthState에 profileImgUrl 추가 시 사용
    // final myProfileImg = authState.profileImgUrl;

    final tempMessage = ChatUiModel(
      userIdx: myIdx.toString(),
      nickname: myNickname,
      isMe: true,
      type: ChatMessageType.text,
      message: content.trim(),
      avatarUrl: null, // TODO: AuthState에 profileImgUrl 추가 후 사용
      time: '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      createdAt: now,
      status: MessageStatus.pending, // 전송 중
      tempId: tempId,
    );

    _messages.add(tempMessage);
    notifyListeners();
    debugPrint('[RandomChatController] 📤 Optimistic UI: pending 메시지 추가 (tempId: $tempId)');

    // 2. 실제 메시지 전송
    try {
      await chatRepository.sendMessage(
        roomIdx: currentRoomIdx,
        content: content.trim(),
      );

      debugPrint('[RandomChatController] ✅ 메시지 전송 요청 완료 (tempId: $tempId)');
      // 실제 메시지는 WebSocket으로 브로드캐스트되어 onMessage 콜백으로 수신됨
      // _addMessage에서 pending 메시지를 제거하고 실제 메시지로 교체
    } catch (e, s) {
      debugPrint('[RandomChatController] ❌ 메시지 전송 실패 (tempId: $tempId): $e');
      debugPrintStack(stackTrace: s);

      // 3. 실패 시 pending 메시지를 failed로 변경
      _markMessageAsFailed(tempId);
      rethrow;
    }
  }

  /// 임시 메시지를 failed 상태로 변경
  void _markMessageAsFailed(String tempId) {
    final index = _messages.indexWhere((m) => m.tempId == tempId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(status: MessageStatus.failed);
      notifyListeners();
      debugPrint('[RandomChatController] ❌ 메시지를 failed 상태로 변경: $tempId');
    }
  }

  /// 실패한 메시지 재시도
  Future<void> retryMessage(ChatUiModel failedMessage) async {
    if (failedMessage.status != MessageStatus.failed || failedMessage.message == null) {
      debugPrint('[RandomChatController] ⚠️ 재시도 불가: 메시지 상태 확인 필요');
      return;
    }

    // 실패한 메시지 제거
    _messages.removeWhere((m) => m.tempId == failedMessage.tempId);
    notifyListeners();

    // 다시 전송 (새로운 tempId로)
    await sendMessage(failedMessage.message!);
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
