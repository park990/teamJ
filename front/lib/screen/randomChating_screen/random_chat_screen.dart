import 'package:flutter/material.dart';
import 'package:front/var/chat_test.dart';
import 'package:image_picker/image_picker.dart';

class RandomChatScreen extends StatefulWidget {
  const RandomChatScreen({super.key});

  @override
  State<RandomChatScreen> createState() => _RandomChatScreenState();
}

class _RandomChatScreenState extends State<RandomChatScreen> {
  XFile? file;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    Chat opponent = CHATS.where((element) => element.isOpponent).first;
    Chat me = CHATS.where((element) => !element.isOpponent).first;

    return Scaffold(
      // body: Center(
      //   child: Text('이곳은 랜덤채팅을 위한 공간임 잘꾸며봐라 여기서 제일 중요한 것은 나중에 채팅LLM이 상대방과의 채팅을 Assist를 해주는거 그 기능이 완벽하게 구현이 될 수있어야함'),
      // ),
      body: Column(
        children: [
          chatComponent(scrollController: scrollController, chats: CHATS),

          chatInputComponent(
            textController: textController,
            sendMessage: _sendMessage,
            scrollToBottom: _scrollToBottom,
            pickImage: _pickImage,
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(opponent.name),
        actions: [OutlinedButton(onPressed: () {}, child: Text('새로운 채팅'))],
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

  void _sendMessage() {
    setState(() {
      CHATS.add(
        Chat(
          room_id: '1',
          name: 'Jane Doe',
          message: textController.text,
          time:
              DateTime.now().hour.toString() +
              ':' +
              DateTime.now().minute.toString(),
          profileImage: 'https://via.placeholder.com/150',
        ),
      );
      textController.clear();
    });
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
      color: Color.fromARGB(107, 197, 197, 197), // 스톤 그레이
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add_photo_alternate_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min, // 내용만큼만 높이
                  children: [
                    ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('갤러리에서 선택'),
                      onTap: () {
                        Navigator.pop(context); // 시트 닫기
                        // 갤러리에서 이미지 선택하는 코드
                        pickImage();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.camera_alt),
                      title: Text('카메라로 촬영'),
                      onTap: () {
                        Navigator.pop(context); // 시트 닫기
                        // 카메라로 촬영하는 코드
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
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '메시지를 입력하세요',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              sendMessage();
              // setState 후 마지막으로 스크롤
              WidgetsBinding.instance.addPostFrameCallback((_) {
                scrollToBottom();
              });
            },
          ),
          // Text('메시지 보내기'),
        ],
      ),
    );
  }
}

class chatComponent extends StatelessWidget {
  final ScrollController scrollController;
  final List<Chat> chats;
  const chatComponent({
    super.key,
    required this.scrollController,
    required this.chats,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        controller: scrollController,

        //-----------------------시간 표시 부분 -------------------------------------------
        separatorBuilder: (context, index) =>
          chats[index].time == chats[index + 1].time
          ? SizedBox.shrink()
          : Align(
              alignment: Alignment.center,
              child: Text(chats[index].time),
            ), // 시간 표시
        //-----------------------채팅 내용 부분 -------------------------------------------
        itemBuilder: (context, index) {
          return CHATS[index].isOpponent
              ? chatByOpponent(chat: CHATS[index])
              : chatByMe(chat: CHATS[index]);
        },
        itemCount: CHATS.length,
        padding: EdgeInsets.symmetric(horizontal: 5),
      ),
    );
  }
}

class chatByOpponent extends StatelessWidget {
  final Chat chat;
  const chatByOpponent({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              'https://avatars.githubusercontent.com/u/210041838?v=4',
            ),
          ),
          SizedBox(width: 10),
          Container(
            width: MediaQuery.of(context).size.width / 2.5,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xFFeedaf2),
            ),
            alignment: Alignment.centerLeft,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('${chat.name} : ')),
                      Text('${chat.time}'),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('${chat.message}'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class chatByMe extends StatelessWidget {
  final Chat chat;
  const chatByMe({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 2.5,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color.fromARGB(206, 255, 247, 177),
            ),
            alignment: Alignment.centerRight,
            child: Align(
              alignment: Alignment.centerRight,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('${chat.time}')),
                      Text('${chat.name} :'),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('${chat.message}'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10),
          CircleAvatar(
            backgroundImage: NetworkImage(
              'https://avatars.githubusercontent.com/u/215974764?v=4',
            ),
          ),
        ],
      ),
    );
  }
}
