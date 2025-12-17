import 'package:front/dto/chat_dto.dart';
import 'package:front/screen/random_chat_screen/models/random_chat_ui_model.dart';

class ChatUiMapper {
  static ChatUiModel toUiModel({
    required ChatDto dto,
    required int myUserId,
  }) {
    final isMe = dto.usersIdx == myUserId;

    return ChatUiModel(
      userIdx: dto.usersIdx,
      nickname: dto.nickname,
      isMe: isMe,
      type: dto.type == 'TEXT'
          ? ChatMessageType.text
          : ChatMessageType.image,
      message: dto.content,
      imageUrl: dto.imageUrl,
      avatarUrl: dto.profileImageUrl,
      time: _formatTime(dto.createdAt),
    );
  }

  static String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}