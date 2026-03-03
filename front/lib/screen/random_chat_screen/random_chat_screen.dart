import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/screen/random_chat_screen/models/random_chat_ui_model.dart';
import 'package:front/screen/random_chat_screen/provider/random_chat_provider.dart';
import 'package:image_picker/image_picker.dart';

class RandomChatScreen extends ConsumerStatefulWidget {
  const RandomChatScreen({super.key});

  @override
  ConsumerState<RandomChatScreen> createState() => _RandomChatScreenState();
}

class _RandomChatScreenState extends ConsumerState<RandomChatScreen> {
  XFile? file;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // ✅ Controller를 필드로 저장 (dispose에서 사용하기 위해)
  late final chatController;

  @override
  void initState() {
    super.initState();

    // Controller 초기화 (필드로 저장)
    chatController = ref.read(randomChatControllerProvider);

    // ✅ 채팅 구독 시작 (매칭 완료 후 자동 호출)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChatSubscription();
      _scrollToBottom();
    });
  }

  /// 채팅 구독 초기화
  Future<void> _initializeChatSubscription() async {
    try {
      debugPrint('[RandomChatScreen] 🔌 채팅 구독 시작...');
      await chatController.connectAndSubscribe();
      debugPrint('[RandomChatScreen] ✅ 채팅 구독 완료');
    } catch (e, s) {
      debugPrint('[RandomChatScreen] ❌ 채팅 구독 실패: $e');
      debugPrintStack(stackTrace: s);

      // 에러 발생 시 사용자에게 알림
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('채팅 연결에 실패했습니다: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 실시간 메시지 리스트 가져오기
    final chatController = ref.watch(randomChatControllerProvider);
    final messages = chatController.messages;
    final roomIdx = chatController.roomIdx ?? '알 수 없음';

    // ✅ 메시지 추가 시 자동 스크롤 (build 안에서 ref.listen 사용)
    ref.listen(randomChatControllerProvider, (previous, next) {
      // 메시지 개수가 증가했을 때만 스크롤
      if (previous != null && next.messages.length > previous.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    // TODO: 나중에 상대방 정보 표시 (임시로 roomIdx 표시)

    return Scaffold(
      appBar: AppBar(
        title: Text('랜덤 채팅 - Room $roomIdx'),
        actions: [
          OutlinedButton(
            onPressed: () {
              // TODO: 새로운 채팅 시작 로직
            },
            child: const Text('새로운 채팅'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ 실시간 메시지 리스트
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('메시지를 전송해보세요!'))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: messages.length,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      // ✅ 이전 메시지와 시간(분 단위)이 다른지 확인
                      final shouldShowTime =
                          index == 0 || // 첫 메시지는 무조건 표시
                          _isDifferentTime(
                            messages[index - 1].createdAt,
                            message.createdAt,
                          );

                      return Column(
                        children: [
                          // ✅ 시간이 바뀔 때만 표시
                          if (shouldShowTime) ...[
                            _buildTimeStamp(message.createdAt),
                            const SizedBox(height: 5),
                          ],
                          // 채팅 내용
                          message.isMe
                              ? _buildMyMessage(message)
                              : _buildOpponentMessage(message),
                        ],
                      );
                    },
                  ),
          ),

          // ✅ 메시지 입력창
          chatInputComponent(
            textController: textController,
            sendMessage: _sendMessage,
            scrollToBottom: _scrollToBottom,
            pickImage: _pickImage,
          ),
        ],
      ),
    );
  }

  /// 두 시간이 다른지 확인 (시/분 단위 비교)
  /// - 시간(hour) 또는 분(minute)이 다르면 true 반환
  bool _isDifferentTime(DateTime prev, DateTime current) {
    return prev.hour != current.hour || prev.minute != current.minute;
  }

  /// 시간 표시 위젯 (중앙 정렬)
  /// TODO: 나중에 개선 - 날짜 바뀔 때도 표시 (예: "2026년 1월 23일")
  Widget _buildTimeStamp(DateTime createdAt) {
    final formattedTime =
        '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          formattedTime,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ),
    );
  }

  /// 내 메시지 위젯
  Widget _buildMyMessage(ChatUiModel message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ 메시지 상태 표시 (pending, failed)
          if (message.status == MessageStatus.pending)
            const Padding(
              padding: EdgeInsets.only(right: 5),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (message.status == MessageStatus.failed)
            GestureDetector(
              onTap: () async {
                // 재시도
                await chatController.retryMessage(message);
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: message.status == MessageStatus.failed
                  ? Colors.red.shade100 // 실패 시 빨간색
                  : const Color.fromARGB(206, 255, 247, 177),
            ),
            child: Text(message.message ?? ''),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundImage: message.avatarUrl != null
                ? NetworkImage(message.avatarUrl!)
                : null,
            child: message.avatarUrl == null
                ? Text(message.nickname[0])
                : null,
          ),
        ],
      ),
    );
  }

  /// 상대방 메시지 위젯
  Widget _buildOpponentMessage(ChatUiModel message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundImage: message.avatarUrl != null
                ? NetworkImage(message.avatarUrl!)
                : null,
            child: message.avatarUrl == null
                ? Text(message.nickname[0])
                : null,
          ),
          const SizedBox(width: 10),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color(0xFFeedaf2),
            ),
            child: Text(message.message ?? ''),
          ),
        ],
      ),
    );
  }

  void _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        this.file = file;
      });
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    debugPrint('[RandomChatScreen] ▶ dispose() CALLED');

    // ✅ 채팅 구독 해제 (필드로 저장된 controller 사용)
    chatController.unsubscribeFromChat();

    // TextField 컨트롤러 해제
    textController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  void _sendMessage() async {
    final content = textController.text.trim();
    if (content.isEmpty) return;

    try {
      debugPrint('[RandomChatScreen] 📤 메시지 전송: $content');
      await chatController.sendMessage(content);
      textController.clear();

      // 메시지 전송 후 스크롤
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e, s) {
      debugPrint('[RandomChatScreen] ❌ 메시지 전송 실패: $e');
      debugPrintStack(stackTrace: s);

      // 에러 발생 시 사용자에게 알림
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('메시지 전송 실패: $e')));
      }
    }
  }
}

class chatInputComponent extends StatelessWidget {
  final TextEditingController textController;
  final Function() sendMessage;
  final Function() scrollToBottom;
  final Function() pickImage;
  const chatInputComponent({
    super.key,
    required this.textController,
    required this.sendMessage,
    required this.scrollToBottom,
    required this.pickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: const Color.fromARGB(107, 197, 197, 197), // 스톤 그레이
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min, // 내용만큼만 높이
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('갤러리에서 선택'),
                      onTap: () {
                        Navigator.pop(context); // 시트 닫기
                        pickImage();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('카메라로 촬영'),
                      onTap: () {
                        Navigator.pop(context); // 시트 닫기
                        // TODO: 카메라 기능
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '메시지를 입력하세요',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              sendMessage();
            },
          ),
        ],
      ),
    );
  }
}
