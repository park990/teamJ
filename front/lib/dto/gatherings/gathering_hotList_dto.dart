import 'package:front/screen/gathering_screen/model/gathering_card_model.dart';

class GatheringHotlistDto {
  final GatheringMeetingModel meetingInfo;

  final int maxParticipants;
  final String location;
  final String categoryName;
  final DateTime meetingDate;

  const GatheringHotlistDto({
    required this.meetingInfo,
    required this.maxParticipants,
    required this.location,
    required this.categoryName,
    required this.meetingDate,
  });

  factory GatheringHotlistDto.fromJson(Map<String, dynamic> json) {
    return GatheringHotlistDto(
      meetingInfo: GatheringMeetingModel(
        title: json['roomName'] ?? '',
        content: json['roomDesc'] ?? '',
        imageUrl: json['roomImg'] ?? '',
        currentParticipants: json['usersIdx'] ?? 0,
      ),
      maxParticipants: json['max'] ?? 0,
      location: json['meetPlace'] ?? '',
      categoryName: json['roomType'] ?? '',
      meetingDate: json['meetDate'] != null
      ? DateTime.parse(json['meetDate'] as String)
      : DateTime.now(),
    );
  }
}

