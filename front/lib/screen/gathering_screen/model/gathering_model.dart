import 'package:front/screen/gathering_screen/model/gathering_card_model.dart';

class GatheringModel {
  final GatheringMeetingModel meetingInfo;

  final int maxParticipants;
  final String location;
  final String categoryName;
  final DateTime meetingDate;

  const GatheringModel({
    required this.meetingInfo,
    required this.maxParticipants,
    required this.location,
    required this.categoryName,
    required this.meetingDate,
  });

  factory GatheringModel.fromJson(Map<String, dynamic> json) {
    return GatheringModel(
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

