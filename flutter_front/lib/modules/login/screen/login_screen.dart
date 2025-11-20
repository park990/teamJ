import 'package:flutter/material.dart';
import 'package:flutter_front/modules/login/controller/login_controller.dart';
import 'package:get/state_manager.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // return Obx(() => Scaffold());   // <LoginController>
    return Obx(() {
      return Scaffold(body: Text(controller.token.value));
    });
  }
} 

// 토큰 관리
// flutter_secure_storage
// shared_preferences


// 이미지 선택
// image_picker