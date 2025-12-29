

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/data/repository/sign_up_repository.dart';
import 'package:front/dto/auth_response.dart';
import 'package:front/dto/social_user_dto.dart';
import 'package:front/screen/myPage_screen/login/provider/signup_provider.dart';
import 'package:front/screen/myPage_screen/login/signup/models/step_item.dart';

const _sentinel = Object();

class SignupState {
  final int currentStep;
  final List<StepItem> steps;
  final String? nicknameError;
  final bool showGenderError; // 성별 미선택 에러 추가
  final bool isSubmitting;

  SignupState({
    this.currentStep = 0,
    required this.steps,
    this.nicknameError,
    this.showGenderError = false,
    this.isSubmitting = false,
  });

  SignupState copyWith({
  int? currentStep,
  List<StepItem>? steps,
  Object? nicknameError = _sentinel,
  bool? showGenderError,
  bool? isSubmitting,
}) {
  return SignupState(
    currentStep: currentStep ?? this.currentStep,
    steps: steps ?? this.steps,
    nicknameError: nicknameError == _sentinel
        ? this.nicknameError
        : nicknameError as String?,
    showGenderError: showGenderError ?? this.showGenderError,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );
}
}

class SignupController extends AutoDisposeNotifier<SignupState>{

  late final  SignUpRepository _repository;


  @override
  SignupState build() {
    _repository = ref.read(signupRepositoryProvider);
    final steps = getSignupSteps();

    ref.onDispose((){
      for(var step in steps){
        step.controller.dispose();
        step.focusNode.dispose();
      }
    });
    return SignupState(steps: steps);
  }

  Future<bool> validateCurrentStep() async{
    final item = state.steps[state.currentStep];

    // 성별 유효성 검사
    if(item.type==StepType.gender){
      if(item.controller.text.isEmpty){
        state = state.copyWith(showGenderError: true);
        return false;
      }
      state = state.copyWith(showGenderError: false);
    }

    // 닉네임 중복 검사
    if(item.type == StepType.nickName){
      final isDup = await _repository.requestNickname(item.controller.text);
      if(isDup){
        state = state.copyWith(nicknameError: '이미 사용중인 닉네임 입니다');
        return false;
      }
      state = state.copyWith(nicknameError: null);
    }
    return true;
  }

  // 다음 항목으로 이동
  void goNextStep(){
    if(state.currentStep<state.steps.length-1){
      state = state.copyWith(currentStep: state.currentStep+1);
    }
  }


  // 닉네임 수정버튼 눌렀을 때 사용하는것 
  void goToStep(int index){
    state = state.copyWith(currentStep: index);
  }

    // 닉네임 중복 에러
  void clearNicknameError() {
    if (state.nicknameError != null) {
      state = state.copyWith(nicknameError: null);
    }
  }

  // 포커스 
  FocusNode get currentFocusNode =>
    state.steps[state.currentStep].focusNode;


  // 마지막 스텝인지 확인
  bool get isLastStep =>
      state.currentStep == state.steps.length - 1;


  // ✅ 최종 회원가입 제출
  Future<AuthResult?> submitSignUp(SocialUserDto socialUser) async {
    state = state.copyWith(isSubmitting: true);

    // 데이터 취합 (기존의 for문 로직)
    Map<StepType, String> inputs = {for (var s in state.steps) s.type: s.controller.text};

    SocialUserDto joinUser = SocialUserDto(
      usersEmail: socialUser.usersEmail,
      provider: socialUser.provider,
      usersSnsId: socialUser.usersSnsId,
      usersNickname: inputs[StepType.nickName] ?? "",
      usersName: inputs[StepType.name] ?? "",
      usersPhone: inputs[StepType.phone] ?? "",
      birthDate: inputs[StepType.birth] ?? "",
      usersGender: inputs[StepType.gender] ?? "",
    );

    final result = await _repository.requestSignUp(joinUser);
    state = state.copyWith(isSubmitting: false);

    if (!result.success) {
      // 서버에서 뒤늦게 중복이 발견된 경우 닉네임 단계로 후진
      int targetIndex = state.steps.indexWhere((item) => item.type == StepType.nickName);
      if (targetIndex != -1) {
        state = state.copyWith(
          currentStep: targetIndex,
          nicknameError: "앗..! 방금 누군가가 동일한 닉네임으로 가입했습니다.",
        );
      }
    }
    return result;
  }
}
