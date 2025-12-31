class GatheringNewlistDto {
  final String? roomIdx;
  final String? roomName;
  final String? roomType;
  final DateTime? createdAt;
  final DateTime? meetDate;
  final String? meetPlace;
  final int? max;
  final String? roomImg;
  final String? roomDesc;
  final int? usersIdx;


  GatheringNewlistDto({
    this.roomIdx,
    this.roomName,
    this.roomType,
    this.createdAt,
    this.meetDate,
    this.meetPlace,
    this.max,
    this.roomImg,
    this.roomDesc,
    this.usersIdx,
  });

  factory GatheringNewlistDto.fromJson(Map<String, dynamic>
  json) {
    return GatheringNewlistDto(
      roomIdx: json['roomIdx'],
      roomName: json['roomName'],
      roomType: json['roomType'],
      createdAt: json['createdAt'],
      meetDate: json['meetDate'],
      meetPlace: json['meetPlace'],
      max: json['max'],
      roomImg: json['roomImg'],
      roomDesc: json['roomDesc'],
      usersIdx: json['usersIdx'],
    );
  }
}