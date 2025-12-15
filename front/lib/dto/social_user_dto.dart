class SocialUserDto {
  final String? usersName;
  final String? usersNickname;
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
    this.usersNickname,
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
      'usersNickname': usersNickname,
      'usersPhone': usersPhone,
      'birthDate': birthDate,
      'usersGender': usersGender,
      'provider': provider,
      'ci': ci,
      'usersSnsId':usersSnsId,
      'usersEmail':usersEmail,
      'grade':grade,
    };
  }

  // 데이터 받을 때(json변환)
  factory SocialUserDto.fromJson(Map<String, dynamic> json) {
    return SocialUserDto(
      usersName: json['usersName'],
      usersNickname: json['usersNickname'],
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