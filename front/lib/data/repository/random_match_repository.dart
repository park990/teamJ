import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:front/data/data_source/remote/websocket_client.dart';
import 'package:front/dto/random_match_dto.dart';

class RandomMatchRepository {
  final WebSocketClient wsClient;
  bool _isSubscribed = false;  // 구독 중복 방지 플래그

  RandomMatchRepository(this.wsClient);

    // 1. 연결 + 구독 (한 번만!)
  Future<void> connectAndSubscribe({
    required int userIdx,
    required Function(RandomMatchDto) onMatchUpdate,
  }) async {
    debugPrint('🔌 [RandomMatchRepo] WebSocket 연결 시작 + 구독...');
    try {
      debugPrint('🔌 [RandomMatchRepo] WebSocket 연결 상태 확인: ${wsClient.isConnected}');
      if (!wsClient.isConnected) {
        await wsClient.connect();
        debugPrint('✅ [RandomMatchRepo] WebSocket 연결 완료!');
      }
      // 구독은 한 번만 등록!
      if (!_isSubscribed) {
        _subscribeToMatchUpdates(userIdx, onMatchUpdate);
        _isSubscribed = true;
        debugPrint('✅ [RandomMatchRepo] 구독 등록 완료!');
      }
    } catch (e) {
      debugPrint('❌ [RandomMatchRepo] WebSocket 연결 실패: $e');
      rethrow;
    } 
  }

  // 구독 로직 분리 (응답 처리 전용)
  void _subscribeToMatchUpdates(
    int userIdx,
    Function(RandomMatchDto) onMatchUpdate,
  ) {
    wsClient.subscribe(
      destination: '/queue/match/$userIdx',
      callback: (frame) {
        try {
          final json = jsonDecode(frame.body ?? '{}');
          final matchData = RandomMatchDto.fromJson(json);
          onMatchUpdate(matchData);
          debugPrint('✅ [RandomMatchRepo] 구독 응답 처리 완료!');
        } catch (e) {
          debugPrint('❌ [RandomMatchRepo] 응답 파싱 실패: $e');
        }
      },
    );
  }

  // 2. 매칭 시작 (응답은 Stream으로)
  Future<void> startMatching({required String genderOption}) async {
    debugPrint(
      '🎯 [RandomMatchRepo] 매칭 시작 - genderOption: $genderOption',
    );

    // 연결 상태 확인 (즉시 에러 감지!)
    if (!wsClient.isConnected) {
      final error = Exception("WebSocket이 연결되지 않았습니다. 먼저 connectAndSubscribe()를 호출해주세요.");
      debugPrint('❌ [RandomMatchRepo] 연결 상태 확인 실패: $error');
      throw error;
    }

    try {
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
