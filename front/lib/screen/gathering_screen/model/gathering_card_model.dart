class GatheringMeetingModel {
  // 모임 카드안에 보여줄 항목(제목, 본문, 이미지경로, 참여자 수)
  final String title;
  final String content;
  final String imageUrl;
  final int currentParticipants;

  GatheringMeetingModel({
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.currentParticipants,
  });
  
  // 변경된 값을 새 객체로 업데이트
  GatheringMeetingModel copyWith({
    String? title,
    String? content,
    String? imageUrl,
    int? currentParticipants,
  }) {
    return GatheringMeetingModel(
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      currentParticipants: currentParticipants ?? this.currentParticipants
    );
  }
}