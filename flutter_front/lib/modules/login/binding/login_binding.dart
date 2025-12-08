import 'package:flutter_front/modules/login/controller/login_controller.dart';
import 'package:flutter_front/modules/login/service/login_service.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginService());
    Get.lazyPut(() => LoginController());
  }
}
