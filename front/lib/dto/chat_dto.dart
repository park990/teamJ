import 'package:image_picker/image_picker.dart';

class ChatUiModel {
  final String message;
  final String timeText;   // 이미 포맷된 시간
  final bool isMe;
  final String? avatarUrl;
  final XFile? image;

  ChatUiModel({
    required this.message,
    required this.timeText,
    required this.isMe,
    this.avatarUrl,
    this.image,
  });
}

/////////////////////////

class ChatDto {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime createdAt;
  final String profileImageUrl;

  ChatDto({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
    required this.profileImageUrl,
  });

  factory ChatDto.fromJson(Map<String, dynamic> json) {
    return ChatDto(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender']['id'],
      senderName: json['sender']['name'],
      content: json['content']['text'],
      createdAt: DateTime.parse(json['created_at']),
      profileImageUrl: json['sender']['profile_image'],
    );
  }
}


class Chat {
  final String room_id;
  final String name;
  final String message;
  final String time;
  final String profileImage;
  final XFile? Img;
  bool isOpponent;

  Chat({
    required this.room_id,
    required this.name,
    required this.message,
    required this.time,
    required this.  profileImage,
    this.Img,
    this.isOpponent = false,
  });
}

var CHATS = [
  Chat(
    room_id: '1',
    name: 'John Doe',
    message: 'ㅎㅇ요',
    time: '12:00',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: true,
  ),
  Chat(
    room_id: '1',
    name: 'John Doe',
    message: 'ㅎㅇ',
    time: '12:01',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: true,
  ),
  Chat(
    room_id: '1',
    name: 'John Doe',
    message: '안녕하세요',
    time: '12:01',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: true,
  ),
  Chat(
    room_id: '1',
    name: 'Jane Doe',
    message: 'ㅎㄹㅇ요',
    time: '12:02',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: false,
  ),
  Chat(
    room_id: '1',
    name: 'John Doe',
    message: 'ㅎㅇ요',
    time: '12:03',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: true,
  ),
  Chat(
    room_id: '1',
    name: 'John Doe',
    message: '빨리와라',
    time: '12:04',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: true,
  ),
  Chat(
    room_id: '1',
    name: 'John Doe',
    message: '진짜 ㅈㄴ맨날늦네',
    time: '12:05',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: true,
  ),
  Chat(
    room_id: '1',
    name: 'Jane Doe',
    message: '자신에게 하는 말?',
    time: '12:06',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: false,
  ),
  Chat(
    room_id: '1',
    name: 'John Doe',
    message: '그게나야빠둠빠두비두밥',
    time: '12:07',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: true,
  ),
  Chat(
    room_id: '1',
    name: 'Jane Doe',
    message: '자기객관화 ㅅㅌㅊ',
    time: '12:08',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: false,
  ),
  Chat(
    room_id: '1',
    name: 'John Doe',
    message: '어디쯤이야?',
    time: '12:09',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: true,
  ),
  Chat(
    room_id: '1',
    name: 'Jane Doe',
    message: '지하철 내림 5분!',
    time: '12:09',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: false,
  ),
  Chat(
    room_id: '1',
    name: 'John Doe',
    message: '오케이 얼른 와라',
    time: '12:10',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: true,
  ),
  Chat(
    room_id: '1',
    name: 'John Doe',
    message: '할 말 있음',
    time: '12:10',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: true,
  ),
  Chat(
    room_id: '1',
    name: 'Jane Doe',
    message: '뭔데 또 ㅋㅋ',
    time: '12:11',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: false,
  ),
  Chat(
    room_id: '1',
    name: 'John Doe',
    message: '오면 말해줌',
    time: '12:11',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: true,
  ),
  Chat(
    room_id: '1',
    name: 'Jane Doe',
    message: '뭔가 불안한데',
    time: '12:11',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: false,
  ),
  Chat(
    room_id: '1',
    name: 'John Doe',
    message: '걍 빨리 와',
    time: '12:12',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: true,
  ),
  Chat(
    room_id: '1',
    name: 'Jane Doe',
    message: '가는 중이라니까',
    time: '12:12',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: false,
  ),
  Chat(
    room_id: '1',
    name: 'John Doe',
    message: 'ㅇㅋ 기다림',
    time: '12:13',
    profileImage: 'https://via.placeholder.com/150',
    isOpponent: true,
  ),
];
