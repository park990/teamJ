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
  final bool isLoading;
  final String? accessToken;
  final String? nickName;
  final int? userIdx;

  AuthState({this.isLoggedIn = false, this.accessToken, this.isLoading = true, this.nickName, this.userIdx});

  // 데이터 보존을 위한 메서드!
  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? accessToken,
    String? nickName,
    int? userIdx,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      accessToken: accessToken ?? this.accessToken,
      nickName: nickName ?? this.nickName,
      userIdx: userIdx ?? this.userIdx,
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

      try{
        final response = await _repository.getUserInfo();
        if(response!=null){
        print('상태등록된 유저정보: ${response.usersNickname}');
        state= state.copyWith(
          isLoading: false,
          nickName: response.usersNickname,
          userIdx: response.usersIdx,
        );
        }
      }catch(e){

      }
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
      await _storage.deleteAll();
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
          print('기존 유저임 닉네임 갖고옴: ${tokenData.usersNickname}');
          
          await _saveTokenAndUpdateState(tokenData);
          return "success";
        }
      }
    }catch(e){

    }
  }

    // 로그인 상태로 변경 후 토큰 스토리지에 저장
    Future<void> _saveTokenAndUpdateState(AuthResponse tokenData) async {
    await _storage.saveTokensOnly(
      accessToken: tokenData.wazzupToken,
      refreshToken: tokenData.refreshToken,
    );

    // 상태 업데이트
    state = state.copyWith(
      isLoggedIn: true,
      isLoading: false,
      accessToken: tokenData.wazzupToken,
      nickName: tokenData.usersNickname,
      userIdx: tokenData.usersIdx,
    );
  }
  
  // 회원가입 완료 후 호출할 함수 회원가입해도 토큰받아와서 저장해줘야함.
  Future<void> completeSignUp(AuthResponse tokenData) async {
    print('${tokenData.usersNickname} ㄹ회원가입회원가입 회원가입회ㄱ원가입한 닉네');
    await _saveTokenAndUpdateState(tokenData);
  }
}
