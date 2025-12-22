import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/local/wazzup_token_storage.dart';
import 'package:front/data/repository/Auth_repository.dart';
import 'package:front/dto/auth_response.dart';
import 'package:front/dto/social_token_and_provider_dto.dart';
import 'package:front/dto/social_user_dto.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

final authRepositoryProvider = Provider((ref)=>AuthRepository());
final tokenStorageProvider = Provider((ref)=>WazzupTokenStorage());

final authControllerProvider =NotifierProvider<AuthController, AuthState>(() {
      return AuthController();
    });

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? accessToken;

  AuthState({this.isLoggedIn = false, this.accessToken, this.isLoading = true});
}

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;
  late final WazzupTokenStorage _storage;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    _storage = ref.read(tokenStorageProvider);

    return AuthState(isLoading: true);
  }

  // 자동로그인
  Future<void> init() async {
  await _checkAutoLogin();
  }

  // 자동 로그인 처리(억섹스 토큰으로만 구현함)
  Future<void> _checkAutoLogin() async {
    try{
    final token = await _storage.getAccessToken();
    if (token != null) {
      state = AuthState(isLoggedIn: true, isLoading: false, accessToken: token);
    }else {
      // 토큰이 없어도 확인은 끝난 것 (isLoading: false)
      state = AuthState(isLoggedIn: false, isLoading: false);
    }
    }catch(e){
      print('자동로그인 체크 중 오류 발생');
      state = AuthState(isLoading: false, isLoggedIn: false);
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      await _repository.wazzupLogout();

      try {
        await UserApi.instance.logout();
      } catch (e) {
        print('카카오톡 로그아웃 에러: {e}');
      }
      await _storage.deleteAllToken();
      state = AuthState(isLoggedIn: false, accessToken: null);
    } catch (e) {
      print('WAZZUP 로그아웃 에러: ${e}');
    }
  }

  // 소셜 로그인 서버통신 처리 
  Future<dynamic> handleSocialLogin(SocialTokenAndProviderDto dto) async {
    try{
      final responseData = await _repository.sendSocialLogin(dto);
      
      if(responseData!=null){
        String serverResult = responseData['result'];

        // 신규유저
        if(serverResult=='register'){
          print('신규유저임 소셜 토큰으로 받아온 유저정보:${responseData['data']}를 들고 signUpScreen으로 보내줘야함');
          return SocialUserDto.fromJson(responseData['data']);
        }

        // 기존유저
        else if(serverResult=='success'){
          AuthResponse tokenData = AuthResponse.fromJson(responseData['data']);
          print('기존 유저임 와접 토큰 발급: ${tokenData}');
          await _saveTokenAndUpdateState(tokenData);
          return "success";
        }
      }
    }catch(e){

    }
  }

  // 로그인 상태로 변경 후 토큰 스토리지에 저장
  Future<void> _saveTokenAndUpdateState(AuthResponse tokenData) async {

    await _storage.saveToken(
    accessToken: tokenData.wazzupToken,
    refreshToken: tokenData.refreshToken);

    state = AuthState(isLoggedIn: true, accessToken: tokenData.wazzupToken);
  }
  
  // 회원가입 완료 후 호출할 함수 (외부에서 호출용) 아직 안써봤는데 언제 쓰는거지?
  Future<void> completeSignUp(AuthResponse tokenData) async {
    await _saveTokenAndUpdateState(tokenData);
  }
}
