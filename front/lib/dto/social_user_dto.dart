class SocialUserDto {
  final String? usersName;
  final String? usersNickName;
  final String? usersPhone;
  final String? birthDate;
  final String? usersGender;
  final String? provider; 
  final String? ci;
  final String? usersSnsId;
  final String? usersEmail;
  final String? grade;
 

  SocialUserDto({
    this.usersName,
    this.usersNickName,
    this.usersPhone,
    this.birthDate,
    this.usersGender,
    this.provider, // 기본값 설정
    this.ci,
    this.usersSnsId,
    this.usersEmail,
    this.grade,
  });

  // 데이터 보낼 때(json변환)
  Map<String, dynamic> toJson() {
    return {
      'usersName': usersName,
      'usersNickName': usersNickName,
      'phoneNumber': usersPhone,
      'birthDate': birthDate,
      'usersGender': usersGender,
      'platform': provider,
      'ci': ci,
      'userSnsId':usersSnsId,
      'usersEmail':usersEmail,
      'grade':grade,
    };
  }

  // 데이터 받을 때(json변환)
  factory SocialUserDto.fromJson(Map<String, dynamic> json) {
    return SocialUserDto(
      usersName: json['usersName'],
      usersNickName: json['usersNickName'],
      usersPhone: json['usersPhone'],
      birthDate: json['birthDate'],
      usersGender: json['usersGender'],
      provider: json['provider'], 
      ci: json['ci'],
      // 숫자로 올 수도 있음
      usersSnsId: json['usersSnsId']?.toString(), 
      usersEmail: json['usersEmail'],
      grade: json['grade'],
    );
  }

}