import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/local/wazzup_token_storage.dart';
import 'package:front/data/repository/Auth_repository.dart';
import 'package:front/dto/auth_response.dart';
import 'package:front/dto/social_token_and_provider_dto.dart';
import 'package:front/dto/social_user_dto.dart';
import 'package:front/provider/token_storage_provider.dart';
import 'package:front/screen/myPage_screen/login/provider/auth_provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class AuthState {
  final bool isLoggedIn;
  final bool authResolved;
  final String? accessToken;
  final String? nickName;
  final int? userIdx;
  final int sessionVersion;

  AuthState({
    this.authResolved = false,
    this.isLoggedIn = false,
    this.accessToken,
    this.nickName,
    this.userIdx,
    this.sessionVersion = 0,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? authResolved,
    String? accessToken,
    String? nickName,
    int? userIdx,
    int? sessionVersion,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      authResolved: authResolved ?? this.authResolved,
      accessToken: accessToken ?? this.accessToken,
      nickName: nickName ?? this.nickName,
      userIdx: userIdx ?? this.userIdx,
      sessionVersion: sessionVersion ?? this.sessionVersion,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;
  late final WazzupTokenStorage _storage;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    _storage = ref.read(tokenStorageProvider);

    return AuthState();
  }

  // 자동로그인
  Future<void> init() async {
    await _checkAutoLogin();
  }

  // 자동 로그인 처리
  Future<void> _checkAutoLogin() async {
    try {
      final token = await _storage.getAccessToken();

      if (token == null) {
        state = AuthState(isLoggedIn: false, authResolved: true);
        return;
      }

      try {
        final response = await _repository.getUserInfo();
        if (response != null) {
          print('상태등록된 유저정보: ${response.usersNickname}');

          state = state.copyWith(
            isLoggedIn: true,
            authResolved: true,
            accessToken: token,
            nickName: response.usersNickname,
            userIdx: response.usersIdx,
          );
        } else {
          print('❌ 토큰 무효 - 자동 로그아웃');
          await _clearAuthState();
        }
      } catch (e) {
        print('❌ 토큰 만료 감지: $e');
        await _clearAuthState();
      }
    } catch (e) {
      print('자동로그인 체크 중 오류 발생');
      state = AuthState(isLoggedIn: false, authResolved: true);
    }
  }

  // 인증 상태 초기화
  Future<void> _clearAuthState() async {
    await _storage.deleteAll();
    state = AuthState(
      isLoggedIn: false,
      authResolved: true,
      accessToken: null,
      nickName: null,
      userIdx: null,
      sessionVersion: state.sessionVersion + 1,
    );
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      await _repository.wazzupLogout();
    } catch (e) {
      print('WAZZUP 로그아웃 에러: $e');
    }

    try {
      await UserApi.instance.logout();
    } catch (e) {
      print('카카오톡 로그아웃 에러: $e');
    }

    await _clearAuthState();
  }

  // 소셜 로그인 서버통신 처리
  Future<dynamic> handleSocialLogin(SocialTokenAndProviderDto dto) async {
    try {
      final responseData = await _repository.sendSocialLogin(dto);

      if (responseData != null) {
        String serverResult = responseData['result'];

        // 신규유저
        if (serverResult == 'register') {
            print('신규유저임 소셜 토큰으로 받아온 유저정보:${responseData['data']}를 들고 signUpScreen으로 보내줘야함');
          return SocialUserDto.fromJson(responseData['data']);

        // 기존 유저
        } else if (serverResult == 'success') {
          AuthResponse tokenData = AuthResponse.fromJson(responseData['data']);
          await saveTokenAndUpdateState(tokenData);
          return "success";
        }
      }
    } catch (e) {
      print('❌ 소셜 로그인 에러: $e');
      return null;
    }
  }

  // 로그인 상태로 변경 후 토큰 저장
  Future<void> saveTokenAndUpdateState(AuthResponse tokenData) async {
    await _storage.saveTokensOnly(
      accessToken: tokenData.wazzupToken,
      refreshToken: tokenData.refreshToken,
    );

    state = state.copyWith(
      isLoggedIn: true,
      authResolved: true,
      accessToken: tokenData.wazzupToken,
      nickName: tokenData.usersNickname,
      userIdx: tokenData.usersIdx,
      sessionVersion: state.sessionVersion + 1,
    );
  }

  // 토큰만 갱신
  Future<void> updateTokensOnly(String newAt, String newRt) async {
    await _storage.saveTokensOnly(accessToken: newAt, refreshToken: newRt);

    state = state.copyWith(
      accessToken: newAt,
      sessionVersion: state.sessionVersion + 1,
    );
    print("🔑 토큰만 갱신 완료 (사용자 정보 유지)");
  }

  // 회원가입 완료 후 호출
  Future<void> completeSignUp(AuthResponse tokenData) async {
    await saveTokenAndUpdateState(tokenData);
  }
}