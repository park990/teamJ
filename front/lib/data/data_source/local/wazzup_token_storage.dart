import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WazzupTokenStorage {
  static final WazzupTokenStorage _instance = WazzupTokenStorage._internal();

  // 싱글톤 패턴 적용
  factory WazzupTokenStorage() => _instance;

  WazzupTokenStorage._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // 안드로이드 암호화 저장소 사용
    ),
  );

  // 고정된 키 값 정의
  static const String _accessTokenKey = 'WAZZUP_ACCESS_TOKEN';
  static const String _refreshTokenKey = 'WAZZUP_REFRESH_TOKEN';


  // [2] 토큰 재발급(Reissue) 시: 기존 유저 정보는 놔두고 토큰만 업데이트 (새로 추가!)
  Future<void> saveTokensOnly({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    
  }

  // [3] 정보 읽기 메서드들
  Future<String?> getAccessToken() async => await _storage.read(key: _accessTokenKey);
  
  Future<String?> getRefreshToken() async => await _storage.read(key: _refreshTokenKey);
  
  // [4] 로그아웃 시: 모든 정보 삭제
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}