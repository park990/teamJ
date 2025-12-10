import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  int _currentStep = 0;

  final _nameNode = FocusNode();
  final _nickNameNode = FocusNode();
  final _phoneNode = FocusNode();

  @override
  void dispose() {
    _nameNode.dispose();
    _nickNameNode.dispose();
    _phoneNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepField(
                title: "이름",
                hint: '실명을 입력해 주세요',
                stepIndex: 0,
                onNext: (){},
                buttonText: '다음',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left:20,right: 20,bottom: 20),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: (){},
              child: Text('버튼')),
          ),
        )
      ),
    );
  }

  Widget _buildStepField({
    required String title,
    required String hint,
    required int stepIndex,
    required VoidCallback onNext,
    required String buttonText,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    TextInputType keyboardType = TextInputType.text,
  }) {
    bool isCompleted = _currentStep > stepIndex;
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            fillColor: isCompleted ? Colors.grey[200]:Colors.grey[100],

            // 입력 전
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!, width:1),
            ),

            // 입력중
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1)
            ),
          ),
        ),
      ],
    );
  }
}
