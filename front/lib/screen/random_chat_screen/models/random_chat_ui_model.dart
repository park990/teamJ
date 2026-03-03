enum ChatMessageType { text, image }

enum MessageStatus {
  pending, // 전송 중
  sent, // 전송 완료
  failed, // 전송 실패
}

class ChatUiModel {
  final String userIdx; // 유저 고유 번호
  final String nickname;
  final bool isMe; // 나인지 상대방인지
  final ChatMessageType type; // 메시지 타입
  final String? imageUrl;
  final String? message;
  final String? avatarUrl;
  final String time; // 이미 포맷된 시간 (UI 표시용)
  final DateTime createdAt; // 원본 시간 (비교용)
  final MessageStatus status; // 메시지 전송 상태
  final String? tempId; // 임시 ID (Optimistic UI용, pending 상태에서만 사용)

  ChatUiModel({
    required this.userIdx,
    required this.nickname,
    required this.isMe,
    required this.type,
    this.imageUrl,
    this.message,
    this.avatarUrl,
    required this.time,
    required this.createdAt,
    this.status = MessageStatus.sent, // 기본값: 전송 완료
    this.tempId,
  });

  /// copyWith 메서드 (상태 업데이트용)
  ChatUiModel copyWith({
    String? userIdx,
    String? nickname,
    bool? isMe,
    ChatMessageType? type,
    String? imageUrl,
    String? message,
    String? avatarUrl,
    String? time,
    DateTime? createdAt,
    MessageStatus? status,
    String? tempId,
  }) {
    return ChatUiModel(
      userIdx: userIdx ?? this.userIdx,
      nickname: nickname ?? this.nickname,
      isMe: isMe ?? this.isMe,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      message: message ?? this.message,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      time: time ?? this.time,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      tempId: tempId ?? this.tempId,
    );
  }
}
