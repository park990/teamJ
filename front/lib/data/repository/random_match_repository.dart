import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:front/data/data_source/remote/websocket_client.dart';
import 'package:front/dto/random_match_dto.dart';

class RandomMatchRepository {
  final WebSocketClient wsClient;

  RandomMatchRepository(this.wsClient);

  // 1. 연결
  Future<void> connect() async {
    debugPrint('🔌 [RandomMatchRepo] WebSocket 연결 시작...');
    try {
      await wsClient.connect();
      debugPrint('✅ [RandomMatchRepo] WebSocket 연결 완료!');
    } catch (e) {
      debugPrint('❌ [RandomMatchRepo] WebSocket 연결 실패: $e');
      rethrow;
    }
  }

  // 2. 매칭 시작 (응답은 Stream으로)
  Future<void> startMatching({
    required int userIdx,
    required String genderOption,
    required Function(RandomMatchDto) onMatchUpdate,
  }) async {
    debugPrint(
      '🎯 [RandomMatchRepo] 매칭 시작 - userIdx: $userIdx, genderOption: $genderOption',
    );

    // 연결 상태 확인 (즉시 에러 감지!)
    if (!wsClient.isConnected) {
      final error = Exception("WebSocket이 연결되지 않았습니다. 먼저 connect()를 호출해주세요.");
      debugPrint('❌ [RandomMatchRepo] 연결 상태 확인 실패: $error');
      throw error;
    }

    try {
      // 구독 (응답 받기)
      debugPrint('📢 [RandomMatchRepo] 구독 등록 - /queue/match/$userIdx');
      wsClient.subscribe(
        destination: '/queue/match/$userIdx',
        callback: (frame) {
          debugPrint('📨 [RandomMatchRepo] 서버 응답 수신!');
          debugPrint('   body: ${frame.body}');

          try {
            final json = jsonDecode(frame.body ?? '{}');
            debugPrint('   parsed: $json');

            final matchData = RandomMatchDto.fromJson(json);
            debugPrint(
              '   status: ${matchData.status}, roomIdx: ${matchData.roomIdx}, partnerIdx: ${matchData.partnerIdx}',
            );

            onMatchUpdate(matchData); // 콜백으로 전달!
            debugPrint('✅ [RandomMatchRepo] onMatchUpdate 콜백 호출 완료');
          } catch (e, s) {
            debugPrint('❌ [RandomMatchRepo] 응답 파싱 실패: $e');
            debugPrintStack(stackTrace: s);
          }
        },
      );
      debugPrint('✅ [RandomMatchRepo] 구독 등록 완료');

      // 요청 보내기
      debugPrint('📤 [RandomMatchRepo] 매칭 요청 전송 - /app/match/enter');
      wsClient.send('/app/match/enter', {'genderOption': genderOption});
      debugPrint('✅ [RandomMatchRepo] 매칭 요청 전송 완료');
    } catch (e, s) {
      debugPrint('❌ [RandomMatchRepo] startMatching 실패: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  // 3. 매칭 취소
  void cancelMatching() {
    debugPrint('❌ [RandomMatchRepo] 매칭 취소 요청 - /app/match/cancel');
    try {
      wsClient.send('/app/match/cancel', {});
      debugPrint('✅ [RandomMatchRepo] 매칭 취소 요청 전송 완료');
    } catch (e) {
      debugPrint('❌ [RandomMatchRepo] 매칭 취소 실패: $e');
      rethrow;
    }
  }

  // 4. 연결 해제
  void disconnect() {
    debugPrint('🔌 [RandomMatchRepo] WebSocket 연결 해제');
    try {
      wsClient.disconnect();
      debugPrint('✅ [RandomMatchRepo] WebSocket 연결 해제 완료');
    } catch (e) {
      debugPrint('❌ [RandomMatchRepo] 연결 해제 중 오류: $e');
    }
  }
}
