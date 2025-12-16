class RandomMatchDto {
  final bool matched;
  final String? roomIdx;

  final String? opponentUsersIdx;
  final String? opponentNickname;
  final String? opponentProfileImage;

  RandomMatchDto({
    required this.matched,
    this.roomIdx,
    this.opponentUsersIdx,
    this.opponentNickname,
    this.opponentProfileImage,
  });

  factory RandomMatchDto.fromJson(Map<String, dynamic> json) {
    return RandomMatchDto(
      matched: json['matched'],
      roomIdx: json['room_idx'],
      opponentUsersIdx: json['opponent_users_idx'],
      opponentNickname: json['opponent_nickname'],
      opponentProfileImage: json['opponent_profile_image'],
    );
  }
}