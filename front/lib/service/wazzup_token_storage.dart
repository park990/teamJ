import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WazzupTokenStorage {
  static final WazzupTokenStorage _instance = WazzupTokenStorage._internal();

  // 사용자가 이 클래스를 생성해도 _instance를 반환 시켜주기 위함
  factory WazzupTokenStorage() => _instance;

  // new 로 인한 새객체생성 방지
  WazzupTokenStorage._internal();

  
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // 안드로이드 암호화 공유 환경설정 사용
    ),
  );

  static const String _tokenKey = 'wazzupToken';

  // 1. 토큰 저장
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // 2. 토큰 읽기 (자동 로그인용)
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // 3. 토큰 삭제 (로그아웃)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
