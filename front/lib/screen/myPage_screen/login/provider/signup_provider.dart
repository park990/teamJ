import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/data/repository/sign_up_repository.dart';
import 'package:front/screen/myPage_screen/login/controller/signup_controller.dart';

final signupRepositoryProvider = Provider((ref){
  final apiclient = ref.watch(apiClientProvider);
    return SignUpRepository(apiclient);
});

final SignupControllerProvider = NotifierProvider.autoDispose<SignupController,SignupState>(() {
  return SignupController();
});