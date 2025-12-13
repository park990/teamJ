class SignUpDTO {
  final String? name;
  final String? nickname;
  final String? phoneNumber;
  final String? birthDate;
  final String? gender;
  final String? platform; 
  final String? ci;

  SignUpDTO({
    this.name,
    this.nickname,
    this.phoneNumber,
    this.birthDate,
    this.gender,
    this.platform, // 기본값 설정
    this.ci,
  });

  // 데이터를 JSON으로 바꾸는 함수 (서버로 보낼 때 필요)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nickname': nickname,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate,
      'gender': gender,
      'platform': platform,
      'ci': ci,
    };
  }
}