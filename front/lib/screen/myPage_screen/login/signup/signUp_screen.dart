import 'package:flutter/material.dart';
import 'package:front/screen/myPage_screen/login/signup/models/step_item.dart';
import 'package:front/theme/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 입력을 안했을때 유효성 검사를 위한 폼키
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  late List<StepItem> _steps;

  @override
  void initState() {
    super.initState();
    _steps=getSignupSteps();
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 단계표시 바
            _stateBar(),

            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [


                        SizedBox(height: 30),
                        Text('본인인증',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.red[200])),
                        SizedBox(height: 10),
                        Text('본인인증 및 회원가입을 위해 정보를 입력해주세요.',style: TextStyle(fontSize: 15, color: Colors.grey[500])),

                        Column(
                          children: 
                            _steps.map(
                              (e){
                                if(e.stepIndex > _currentStep){
                                  return SizedBox.shrink();
                                }
                                return _buildStepField(e);
                              }
                            ).toList()
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            nextButton()
          ],
        ),
      ),
    );
  }

  Widget _buildStepField(StepItem e) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 레이블 
          Text(
            e.title,
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.grey[500]),
          ),
          SizedBox(height: 3),

          if(e.type==StepType.gender)
            _buildGenderSlector(e)
          else
          
          // 텍스트 상자
          TextFormField(
            style: TextStyle(fontSize: 20),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '${e.title}을 입력해주세요';
              }
              return null;
            },
            focusNode: e.focusNode,
            decoration: _textFieldDesign(e)
          ),
        ],
      ),
    );
  }

  // 다음 버튼
  Widget nextButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only( left: 30,right: 30,bottom: 20),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: wazzupButton, 
            ),
            onPressed: _nextStep,
            child: _currentStep==_steps.length-1?Text('본인인증'):Text('다음')
          ),
        ),
      ),
    );
  }

  // 다음 버튼을 누르면 다음 스텝이 나오도록 그리고 그 다음 스텝 아이템에 FOCUS
  void _nextStep() async {

    // 유효성 검사
    if (!_formKey.currentState!.validate()) return;


    if (_currentStep == 1) {
      print("닉네임 중복 확인 중...");
      String nickName = _steps[1].controller.text;
      // bool isDup = await _checkNickNameDuplicate(nickName);

      // if (isDup) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('이미 사용 중인 닉네임입니다')),
      //   );
      //   return;
      // }
    }
    setState(() {
      if (_currentStep < _steps.length - 1) {
        _currentStep++;
      } else {
        print('완료 (본인인증 시작)');
        // 여기서 본인인증 로직 실행
      }
    });
    // 화면이 전부 바뀐뒤에 텍스트 필드에 포커스 해주는 액션
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(
        context,
      ).requestFocus(_steps[_currentStep].focusNode);
    });
  }

  // 성별 선택 위젯
  Widget _buildGenderSlector(StepItem item) {
    return Container(
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

  // 상단 단계표시 바 
  Widget _stateBar(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal:30,vertical: 10),
      child: TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0, 
        end: (_currentStep+1) / _steps.length // 전체대비 얼마나 찼는지
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



  // controller & focusNode dispose
  @override
  void dispose() {
    super.dispose();
    for(var step in _steps){
      step.controller.dispose();
      step.focusNode.dispose();
    }
  }
}
