import 'package:flutter/material.dart';
import 'package:front/var/chat_test.dart';

class RandomchatMain extends StatefulWidget {
  const RandomchatMain({super.key});

  @override
  State<RandomchatMain> createState() => _RandomchatMainState();
}

class _RandomchatMainState extends State<RandomchatMain> {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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
          id: DateTime.now().millisecondsSinceEpoch.toString(),
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

  @override
  Widget build(BuildContext context) {
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
          ),
        ],
      ),
      appBar: AppBar(),
    );
  }
}

class chatInputComponent extends StatelessWidget {
  final TextEditingController textController;
  final Function() sendMessage;
  final Function() scrollToBottom;

  const chatInputComponent({
    super.key,
    required this.textController,
    required this.sendMessage,
    required this.scrollToBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.grey,
      child: Row(
        children: [
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
      child: ListView.builder(
        controller: scrollController,
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
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xFFE6C7F0), // 약간 더 진한 라벤더
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
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color.fromARGB(255, 224, 212, 158),
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
    );
  }
}
