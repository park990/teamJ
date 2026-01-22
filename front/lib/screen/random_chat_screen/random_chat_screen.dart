import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/dto/chat_dto.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';
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

  @override
  void initState() {
    super.initState();

    // ✅ 채팅 구독 시작 (매칭 완료 후 자동 호출)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChatSubscription();
      _scrollToBottom();
    });
  }

  /// 채팅 구독 초기화
  Future<void> _initializeChatSubscription() async {
    final chatController = ref.read(randomChatControllerProvider);

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

    // ✅ 현재 로그인한 사용자 userIdx 가져오기
    final authState = ref.watch(authControllerProvider);
    final myUserIdx = authState.userIdx;

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

                      // ✅ 내 메시지인지 판단 (userIdx 비교)
                      final isMe =
                          myUserIdx != null && message.userIdx == myUserIdx;

                      return Column(
                        children: [
                          // 시간 표시 (임시로 생략)
                          // 채팅 내용
                          isMe
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

  /// 내 메시지 위젯
  Widget _buildMyMessage(ChatDto message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromARGB(206, 255, 247, 177),
            ),
            child: Text(message.content),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundImage: message.profileImgUrl != null
                ? NetworkImage(message.profileImgUrl!)
                : null,
            child: message.profileImgUrl == null
                ? Text(message.nickname[0])
                : null,
          ),
        ],
      ),
    );
  }

  /// 상대방 메시지 위젯
  Widget _buildOpponentMessage(ChatDto message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundImage: message.profileImgUrl != null
                ? NetworkImage(message.profileImgUrl!)
                : null,
            child: message.profileImgUrl == null
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
            child: Text(message.content),
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

  void _sendMessage() async {
    final content = textController.text.trim();
    if (content.isEmpty) return;

    final chatController = ref.read(randomChatControllerProvider);

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
