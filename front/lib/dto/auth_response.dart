class AuthResponse {
  final String wazzupToken;
  final String refreshToken;

  AuthResponse({
    required this.wazzupToken,
    required this.refreshToken,
  });

  // wazzup 토큰 받을 때
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      wazzupToken: json['wazzupToken'] ?? '', // null 방지
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  // wazzup 토큰 보낼 때 둘다 보낼 때는 accesstoken재발급을 위해 보낼 때임.
  Map<String, dynamic> toJson() {
    return {
      'wazzupToken': wazzupToken,
      'refreshToken': refreshToken,
    };
  }
  
  // 로그 찍을 때 객체 내용이 보이도록 오버라이드 (디버깅용)
  @override
  String toString() {
    return 'AuthResponse(wazzupToken: $wazzupToken, refreshToken: $refreshToken)';
  }

}

class AuthResult {
  final bool success;
  final AuthResponse? data; // 성공 시 토큰 데이터 담김
  final String? message;    // 실패 시 에러 메시지 담김

  AuthResult({
    required this.success,
    this.data,
    this.message,
  });
}
