class GatheringDetailDto {
  final int roomIdx;
  final String roomName;
  final String roomType;
  final String roomDesc;
  final String? roomImg;
  final String meetDate;
  final String meetPlace;
  final int max;
  final int participatCount;
  final bool isFull;
  final bool isParticipating;

  const GatheringDetailDto({
    required this.roomIdx,
    required this.roomName,
    required this.roomType,
    required this.roomDesc,
    this.roomImg,
    required this.meetDate,
    required this.meetPlace,
    required this.max,
    required this.participatCount,
    required this.isFull,
    required this.isParticipating,
  });

  factory GatheringDetailDto.fromJson(Map<String, dynamic> json) {
    return GatheringDetailDto(
      roomIdx: json['roomIdx'] as int,
      roomName: json['roomName'] as String,
      roomType: json['roomType'] as String,
      roomDesc: json['roomType'] as String,
      roomImg: json['roomImg'] as String,
      meetDate: json['meetDate'] as String,
      meetPlace: json['meetPlace'] as String,
      max: json['max'] as int,
      participatCount: json['participantCount'] as int,

      isFull: json['isFull'] as bool? ?? false,
      isParticipating: json['isParticipating'] as bool? ?? false,
    );
  }
}