
enum RandomChatStatus {
  idle,       // 시작 전
  matching,   // 대기열
  matched,    // 매칭 완료 (roomId 있음)
  chatting,   // 채팅 중
  left,       // 나감
  error,      // 에러
}

class RandomChatState {
  final RandomChatStatus status;
  final String? roomIdx;
  final String? errorMessage;
  const RandomChatState({
    required this.status,
    this.roomIdx,
    this.errorMessage,
  });

  factory RandomChatState.idle() {
    return const RandomChatState(status: RandomChatStatus.idle);
  }

  RandomChatState copyWith({
    RandomChatStatus? status,
    String? roomId,
    String? errorMessage,
  }) {
    return RandomChatState(
      status: status ?? this.status,
      roomIdx: roomIdx ?? this.roomIdx,
      errorMessage: errorMessage,
    );
  }
}