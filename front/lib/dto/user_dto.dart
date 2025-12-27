class UserDto {
  final int usersIdx;
  final String usersNickname;
  final String grade;

  UserDto({required this.usersIdx, required this.usersNickname,required this.grade});

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      usersIdx: json['usersIdx'],
      usersNickname: json['usersNickname'],
      grade:json['grade'],
    );
  }
}