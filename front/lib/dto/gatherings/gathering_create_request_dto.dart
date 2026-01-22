class GatheringCreateRequestDto {
  final String roomName;
  final String roomType;
  final String roomDesc;
  //final String? roomImg; // 이미지 업로드는 백에서 multipart로 처리
  final DateTime? meetDate;  // nullable: 날짜는 나중에 정할 수 있음
  final String meetPlace;
  final int max;

  const GatheringCreateRequestDto({
    required this.roomName,
    required this.roomType,
    required this.roomDesc,
    this.meetDate,
    required this.meetPlace,
    required this.max
  });

  factory GatheringCreateRequestDto.fromJson(Map<String, dynamic> json) {
    return GatheringCreateRequestDto(
      roomName: json['roomName'] as String,
      roomType: json['roomType'] as String,
      roomDesc: json['roomDesc'] as String,
      //roomImg: json['roomImg'] as String?,
      meetDate: json['meetDate'] != null ? DateTime.parse(json['meetDate'] as String) : null,
      meetPlace: json['meetPlace'] as String,
      max: json['max'] as int,
    );
  }

  // Dart 객체 → JSON으로 변환 (백엔드로 보낼 때)
  Map<String, dynamic> toJson() {
    return {
      'roomName': roomName,
      'roomType': roomType,
      'roomDesc': roomDesc,
      'meetDate': meetDate?.toIso8601String(),  // DateTime → "2025-01-21T14:00:00.000Z" 형태
      'meetPlace': meetPlace,
      'max': max,
    };
  }
}
