import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:front/data/data_source/remote/websocket_client.dart';
import 'package:front/dto/random_match_dto.dart';

class RandomMatchRepository {
  final WebSocketClient wsClient;

  RandomMatchRepository(this.wsClient);

  // 1. 연결
  Future<void> connect() async {
    await wsClient.connect();
  }

  // 2. 매칭 시작 (응답은 Stream으로)
  void startMatching({
    required int userIdx,
    required String genderOption,
    required Function(RandomMatchDto) onMatchUpdate,
  }) {
    // 구독 (응답 받기)
    wsClient.subscribe(
      destination: '/queue/match/$userIdx',
      callback: (frame) {
        final json = jsonDecode(frame.body ?? '{}');
        final matchData = RandomMatchDto.fromJson(json);
        onMatchUpdate(matchData);  // 콜백으로 전달!
      },
    );
    
    // 요청 보내기
    wsClient.send('/app/match/enter', {
      'genderOption': genderOption,
    });
  }

  // 3. 매칭 취소
  void cancelMatching() {
    wsClient.send('/app/match/cancel', {});
  }
  
  // 4. 연결 해제
  void disconnect() {
    wsClient.disconnect();
  }
}