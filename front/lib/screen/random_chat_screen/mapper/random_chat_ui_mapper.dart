import 'package:front/dto/chat_dto.dart';
import 'package:front/screen/random_chat_screen/models/random_chat_ui_model.dart';

/// ChatDto → ChatUiModel 변환 Mapper
/// - 모든 변환 로직과 헬퍼 메서드 포함
class ChatUiMapper {
  /// ChatDto를 ChatUiModel로 변환
  static ChatUiModel toUiModel({required ChatDto dto, required int myUserId}) {
    return ChatUiModel(
      userIdx: dto.userIdx.toString(),
      nickname: dto.nickname,
      isMe: isMine(dto, myUserId),
      type: isText(dto) ? ChatMessageType.text : ChatMessageType.image,
      message: dto.content,
      imageUrl: dto.imageUrl,
      avatarUrl: dto.profileImgUrl,
      time: formattedTime(dto),
    );
  }

  /// ==========================
  /// 헬퍼 메서드
  /// ==========================

  /// 내가 보낸 메시지인지 확인
  static bool isMine(ChatDto dto, int myUserIdx) {
    return dto.userIdx == myUserIdx;
  }

  /// 텍스트 메시지인지 확인
  static bool isText(ChatDto dto) {
    return dto.type == 'TEXT';
  }

  /// 이미지 메시지인지 확인
  static bool isImage(ChatDto dto) {
    return dto.type == 'IMAGE';
  }

  /// 시간 포맷팅 (HH:mm 형식)
  static String formattedTime(ChatDto dto) {
    return '${dto.createdAt.hour}:${dto.createdAt.minute.toString().padLeft(2, '0')}';
  }
}
