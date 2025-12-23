class GatheringMeeting {
  // 모임 카드안에 보여줄 항목(제목, 본문, 이미지경로, 참여자 수)
  final String cardTitle;
  final String cardBody;
  final String cardImageUrl;
  final int cardParticipantsCount;

  GatheringMeeting({
    required this.cardTitle,
    required this.cardBody,
    required this.cardImageUrl,
    required this.cardParticipantsCount,
  });
  
  // 변경된 값을 새 객체로 업데이트
  GatheringMeeting copyWith({
    String? cardTitle,
    String? cardBody,
    String? cardImageUrl,
    int? cardParticipantsCount,
  }) {
    return GatheringMeeting(
      cardTitle: cardTitle ?? this.cardTitle,
      cardBody: cardBody ?? this.cardBody,
      cardImageUrl: cardImageUrl ?? this.cardImageUrl,
      cardParticipantsCount: cardParticipantsCount ?? this.cardParticipantsCount
    );
  }
}