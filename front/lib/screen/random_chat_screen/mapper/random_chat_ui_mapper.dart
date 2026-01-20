import 'package:front/dto/chat_dto.dart';
import 'package:front/screen/random_chat_screen/models/random_chat_ui_model.dart';

class ChatUiMapper {
  static ChatUiModel toUiModel({required ChatDto dto, required int myUserId}) {
    // ChatDto의 isMine 헬퍼 메서드 사용
    final isMe = dto.isMine(myUserId);

    return ChatUiModel(
      userIdx: dto.userIdx.toString(),
      nickname: dto.nickname,
      isMe: isMe,
      type: dto.isText ? ChatMessageType.text : ChatMessageType.image,
      message: dto.content,
      imageUrl: dto.imageUrl,
      avatarUrl: dto.profileImgUrl,
      time: _formatTime(dto.createdAt),
    );
  }

  static String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
