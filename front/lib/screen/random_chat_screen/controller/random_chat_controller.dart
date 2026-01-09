import 'package:flutter/material.dart';
import 'package:front/data/repository/random_match_repository.dart';
import '../models/random_chat_state.dart';

class RandomChatController extends ChangeNotifier {
  final RandomMatchRepository matchRepository;

  RandomChatController({required this.matchRepository}) {
    debugPrint(
      '🔥 RandomChatController CREATED '
      'hash=$hashCode',
    ); // 메모리 주소 출력
  }

  RandomChatState _state = RandomChatState.idle();

  RandomChatState get state => _state;

  /// ==========================
  /// 상태 변경 전용 함수
  /// ==========================
  void _setState(RandomChatState newState) {
    debugPrint(
      '🔄 STATE CHANGE '
      '[${_state.status} → ${newState.status}] '
      'roomIdx: ${newState.roomIdx}',
    );

    _state = newState;
    notifyListeners();

    debugPrint('📢 notifyListeners() called');
  }

  /// ==========================
  /// 상태 초기화
  /// ==========================
  void reset() {
    debugPrint('♻️ reset() called');
    _setState(RandomChatState.idle());
  }

  /// ==========================
  /// WebSocket 연결
  /// ==========================
  Future<void> initialize() async {
    await matchRepository.connect();
  }

  /// ==========================
  /// 매칭 시작
  /// ==========================
  Future<void> startMatching({
    required int userIdx,
    required String genderOption,
  }) async {
    debugPrint(
      '▶ startMatching() CALLED '
      'userIdx=$userIdx, '
      'genderOption=$genderOption',
    );

    try {
      debugPrint('🌐 startMatching() REQUEST START');

      // 요청 보내기 (성공하면 상태 변경)
      await matchRepository.startMatching(
        userIdx: userIdx,
        genderOption: genderOption,
        onMatchUpdate: (matchData) {
          // 콜백으로 실시간 응답 받기!
          if (matchData.isWaiting) {
            _setState(state.copyWith(status: RandomChatStatus.matching));
          } else if (matchData.isMatched) {
            _setState(
              state.copyWith(
                status: RandomChatStatus.matched,
                roomIdx: matchData.roomIdx.toString(),
              ),
            );
          }
        },
      );

      // 요청 전송 성공 후 상태 변경 (에러 없으면 여기까지 옴)
      debugPrint('✅ startMatching() REQUEST SUCCESS');
      _setState(state.copyWith(status: RandomChatStatus.matching));
    } catch (e, s) {
      debugPrint('❌ startMatching ERROR');
      debugPrint('❌ error=$e');
      debugPrintStack(stackTrace: s);

      // 에러 발생 시 error 상태로 변경
      _setState(
        state.copyWith(
          status: RandomChatStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// ==========================
  /// 매칭 취소
  /// ==========================
  void cancelMatching() {
    debugPrint('▶ cancelMatching() CALLED');
    try {
      matchRepository.cancelMatching();
      // 취소 요청 성공 시 상태를 idle로 변경
      _setState(state.copyWith(status: RandomChatStatus.idle));
    } catch (e, s) {
      debugPrint('❌ cancelMatching ERROR: $e');
      debugPrintStack(stackTrace: s);
      // 에러 발생 시에도 idle로 변경
      _setState(
        state.copyWith(
          status: RandomChatStatus.idle,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// ==========================
  /// 연결 해제
  /// ==========================
  @override
  void dispose() {
    debugPrint('▶ dispose() CALLED');
    matchRepository.disconnect();
    super.dispose();
  }
}
