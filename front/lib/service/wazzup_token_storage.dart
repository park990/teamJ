import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WazzupTokenStorage {
  static final WazzupTokenStorage _instance =
      WazzupTokenStorage._internal();

  // 사용자가 이 클래스를 생성해도 _instance를 반환 시켜주기 위함
  factory WazzupTokenStorage() => _instance;

  // new 로 인한 새객체생성 방지
  WazzupTokenStorage._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // 안드로이드 암호화 공유 환경설정 사용
    ),
  );

  static const String _accessTokenKey = 'WAZZUP_ACCESS_TOKEN';
  static const String _refreshTokenKey = 'WAZZUP_REFRESH_TOKEN';

  // 1. 토큰 저장
  Future<void> saveToken({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // 2. 토큰 읽기 (자동 로그인용)
  Future<String?> getToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // 3. 토큰 삭제 (로그아웃)
  Future<void> deleteAllToken() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
