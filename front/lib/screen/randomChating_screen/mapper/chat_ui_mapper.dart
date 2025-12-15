import 'package:front/dto/chat_dto.dart';
import 'package:front/screen/randomChating_screen/models/chat_ui_model.dart';

class ChatUiMapper {
  static ChatUiModel toUiModel({
    required ChatDto dto,
    required int myUserId,
  }) {
    final isMe = dto.senderId == myUserId;

    return ChatUiModel(
      userIdx: dto.senderId,
      nickname: dto.nickname,
      isMe: isMe,
      type: dto.type == 'TEXT'
          ? ChatMessageType.text
          : ChatMessageType.image,
      message: dto.text,
      imageUrl: dto.imageUrl,
      avatarUrl: dto.avatarUrl,
      time: _formatTime(dto.createdAt),
    );
  }

  static String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}