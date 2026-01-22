class GatheringActionResponseDto {
  final int roomIdx;
  final bool success;
  final String message;
  final int participantCount;
  final bool isFull;
  final bool isParticipating;

  const GatheringActionResponseDto({
    required this.roomIdx,
    required this.success,
    required this.message,
    required this.participantCount,
    required this.isFull,
    required this.isParticipating,
  });

  factory GatheringActionResponseDto.fromJson(Map<String, dynamic> json) {
    return GatheringActionResponseDto(
      roomIdx: json['roomIdx'] as int,
      success: json['success'] as bool,
      message: json['message'] as String,
      participantCount: json['participantCount'] as int,
      isFull: json['isFull'] as bool? ?? false,
      isParticipating: json['isParticipating'] as bool? ?? false,
    );
  }
}