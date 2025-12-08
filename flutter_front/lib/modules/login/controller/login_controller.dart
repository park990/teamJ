import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

// Controller는 UI에 들어가는 값 담당
class LoginController extends GetxController {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  RxInt userId = RxInt(0);
  RxString token = RxString('');

  void changeView(int newId) {
    userId.value = newId;
  }

  void saveToken(String token) async {
    await storage.write(key: 'accessToekn', value: token);
  }

  void getToken() async {
    token.value = await storage.read(key: 'accessToken') ?? '';
    Get.toNamed('/login');
  }
}
