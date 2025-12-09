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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Center(
      //   child: Text('이곳은 랜덤채팅을 위한 공간임 잘꾸며봐라 여기서 제일 중요한 것은 나중에 채팅LLM이 상대방과의 채팅을 Assist를 해주는거 그 기능이 완벽하게 구현이 될 수있어야함'),
      // ),
      body: Column(
        children: [

          _chatList(),
          
          Container(
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
                    setState(() {
                      CHATS.add(Chat(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: 'Jane Doe',
                        message: textController.text,
                        time: DateTime.now().hour.toString() + ':' + DateTime.now().minute.toString(),
                        profileImage: 'https://via.placeholder.com/150',
                      ));
                      textController.clear();
                    });
                    // setState 후 마지막으로 스크롤
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                  },
                ),
                Text('메시지 보내기'),
              ]
            ),
          ),
        ],
      ),
      appBar: AppBar(
        
      ),
    );
  }

  Widget _chatList() {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemBuilder: 
        (context, index) {
          return Align(
            alignment: 
            CHATS[index].isOpponent
            ? Alignment.centerLeft
            : Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width /2.5,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: 
                CHATS[index].isOpponent
                ? Colors.yellow
                : Colors.green,
              ),
              alignment: 
              CHATS[index].isOpponent
              ? Alignment.centerLeft
              : Alignment.centerRight,
              child: 
              CHATS[index].isOpponent
              ? Align(alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${CHATS[index].name} : '
                          ),
                        ),
                        Text(
                          '${CHATS[index].time}'
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${CHATS[index].message}'
                      ),
                    ),
                  ],
                ),
              )

              : Align(alignment: Alignment.centerRight,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${CHATS[index].time}'
                          ),
                        ),
                        Text(
                          '${CHATS[index].name} :'
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${CHATS[index].message}'
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: CHATS.length,
        padding: EdgeInsets.symmetric(horizontal: 5),
      ),
    );
  }
}