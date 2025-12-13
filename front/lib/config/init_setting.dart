
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

Future<void> initAppSettings() async{
  // runApp 하기 전에 .env 파일 읽고
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // 카카오 SDK 초기화
  String? kakaoKey = dotenv.env['KAKAO_NATIVE_APP_KEY'];
  if(kakaoKey !=null && kakaoKey.isNotEmpty){
    KakaoSdk.init(nativeAppKey: kakaoKey);
    print('카카오 초기화 완료');
    print('🔑 내 앱의 키 해시: ${await KakaoSdk.origin}');
  }
  else{
    print('카카오 초기화 실패');
  }



}