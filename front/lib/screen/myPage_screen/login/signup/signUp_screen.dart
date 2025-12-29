import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/dto/social_user_dto.dart';
import 'package:front/screen/myPage_screen/login/controller/signup_controller.dart';
import 'package:front/screen/myPage_screen/login/provider/signup_provider.dart';
import 'package:front/screen/myPage_screen/login/signup/models/step_item.dart';
import 'package:front/theme/app_colors.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key, required SocialUserDto this.user});
  final SocialUserDto user;

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  
  // 입력을 안했을때 유효성 검사를 위한 폼키
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // 화면이 전부 바뀐뒤에 텍스트 필드에 포커스 해주는 액션
    // 아래 버튼 누를때도 써주는데 처음 화면 렌더링때 이름레이블에 포커싱이 안돼서 init때 해줌.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final steps = ref.read(SignupControllerProvider).steps;

      if(steps.isNotEmpty){
        FocusScope.of(context).requestFocus(steps[0].focusNode);
      }
      
    });
  }


  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(SignupControllerProvider);
    final notifier = ref.read(SignupControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 단계표시 바
            _stateBar(signupState),

            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30,),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // 상단 본인인증 해주세요 레이블
                        _Header(),
                        // 하단 본인인증 항목 리스트들
                        Column(
                          children: signupState.steps.map((e) {
                            if (e.stepIndex > signupState.currentStep) {
                              return SizedBox.shrink();
                            }
                            return _buildStepField(e,signupState, notifier);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            nextButton(signupState, notifier),
          ],
        ),
      ),
    );
  }


  Widget _buildStepField(StepItem e, SignupState state, SignupController notifier) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 레이블
          Text(
            e.title,
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.grey[500])),
          SizedBox(height: 3),

            // 성별 선택
          if (e.type == StepType.gender)
            _buildGenderSlector(e, state)
          else
            // 텍스트 상자
            TextFormField(
              style: TextStyle(fontSize: 20),
              focusNode: e.focusNode,
              controller: e.controller,
              readOnly: (e.type==StepType.nickName&&state.currentStep>e.stepIndex),
              
              decoration: _textFieldDesign(e).copyWith(
                suffixIcon: (e.type==StepType.nickName && state.currentStep>e.stepIndex)
                ?IconButton(
                  onPressed: ()=>notifier.goToStep(e.stepIndex),
                  icon:  Icon(Icons.edit),color: Colors.grey[500])
                :null,
              ),

              // 사용자가 공백을 남겨뒀을시 재입력하면 에러 삭제
              autovalidateMode:AutovalidateMode.onUserInteraction,

              // 닉네임 재입력시 오류메시지 사라지게
              onChanged: (_)=>notifier.clearNicknameError(),

                // 공백 유효성 검사
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '${e.title}을 입력해주세요';
                }

                // 닉네임 중복 오류
                if (e.type==StepType.nickName &&
                    state.nicknameError != null) {
                  return state.nicknameError;
                }
                return null;
              },
            ),
        ],
      ),
    );
  }

  // 다음 버튼
  Widget nextButton(SignupState state, SignupController notifier) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only( left: 30,right: 30,bottom: 20),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: wazzupButton, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10))
            ),
            onPressed: state.isSubmitting ? null : ()=>_handleNext(state,notifier),
            child: state.currentStep==state.steps.length-1?Text('본인인증'):Text('다음')
          ),
        ),
      ),
    );
  }

  void _handleNext(SignupState state, SignupController notifier) async {
    if(!_formKey.currentState!.validate())return;

    final isValid = await notifier.validateCurrentStep();

    if(!isValid){
      _formKey.currentState!.validate();
      return;
    }
    
    if(notifier.isLastStep){
      final result = await notifier.submitSignUp(widget.user);
      if(result !=null && result.success && mounted){
        Navigator.of(context).pop(
          result.data
        );
      }
      return;
    }

    notifier.goNextStep();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(notifier.currentFocusNode);
      });
    }

  }


  // 성별 선택 위젯
  Widget _buildGenderSlector(StepItem item, SignupState state) {
    return Column(
      children: [
        Container(
          child: RadioGroup<String>(
            groupValue: item.controller.text, 
            onChanged: (String? value) {
              setState(() {
                item.controller.text = value!;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRadioOption(item, title: '여성', value: '0'),
                _buildRadioOption(item, title: '남성', value: '1'),
              ],
            ),
          ),
        ),
        if(state.showGenderError && item.controller.text.isEmpty)
        Text("성별을 선택해 주세요",style: TextStyle(color: Colors.red,fontSize: 12)),
        if (item.controller.text.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: Text(
              "거짓 성별 선택 시 wazzup이용이 제한됩니다.\n 추후 변경 불가능.", 
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500], // 글자색도 붉은 계열로
                fontSize: 13,
                fontWeight: FontWeight.bold, // 중요하니까 굵게
              ),
            ),
          ),
      ],
    );
  }

  // 2. 라디오 버튼 
  Widget _buildRadioOption(StepItem item, {
    required String title,
    required String value,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          item.controller.text = value;
        });
      },
      child: Row(
        children: [
          Radio<String>(
            value: value,
            activeColor: value=='0'?Colors.red[200]:Colors.blue[200],
          ),
          Text(title),
        ],
      ),
    );
  }

  // 입력받는 값들 Design
  InputDecoration _textFieldDesign(StepItem e) {
    return InputDecoration(
      hintText: e.hint,
      hintStyle: TextStyle(
        color: Colors.grey[500],
        fontSize: 14,
      ),
      
      // 입력 전
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      // 입력중
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1),
      ),
    );
  }

  // 최상단 스텝 표시상태 바 
  Widget _stateBar(SignupState state){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal:30,vertical: 10),
      child: TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0, 
        end: (state.currentStep+1) / state.steps.length // 전체대비 얼마나 찼는지
      ),
      duration: Duration(milliseconds: 300), // 게이지 차오르는 속도
      builder: (context, value, _) => LinearProgressIndicator(
        value: value,
        backgroundColor: Colors.grey[200], // 배경색
        color: wazzupButton, 
        minHeight: 6, // 두께
        borderRadius: BorderRadius.circular(10), 
      ),
      ),
    );
  }

  // 상단 본인인증 및 회원가입을 위해 머시기 레이블
  Widget _Header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        Text(
          '본인인증',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.red[200],
          ),
        ),
        SizedBox(height: 10),
        Text(
          '본인인증 및 회원가입을 위해 정보를 입력해주세요.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
