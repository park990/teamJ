enum ChatMessageType { text, image }

class ChatUiModel {
  final String userIdx; // 유저 고유 번호
  final String nickname;
  final bool isMe; // 나인지 상대방인지
  final ChatMessageType type; // 메시지 타입
  final String? imageUrl;
  final String? message;
  final String? avatarUrl;
  final String time; // 이미 포맷된 시간

  ChatUiModel({
    required this.userIdx,
    required this.nickname,
    required this.isMe,
    required this.type,
    this.imageUrl,
    this.message,
    this.avatarUrl,
    required this.time,
  });
}
