import 'package:flutter/material.dart';
import 'package:front/data/repository/random_match_repository.dart';
import '../models/random_chat_state.dart';

class RandomChatController extends ChangeNotifier {
  final RandomMatchRepository matchRepository;

  RandomChatController({
    required this.matchRepository,
  }) {
    debugPrint('🔥 RandomChatController CREATED '
        'hash=$hashCode'); // 메모리 주소 출력
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
  void startMatching({required int userIdx, required String genderOption}) {
    debugPrint(
      '▶ startMatching() CALLED '
      'userIdx=$userIdx, '
      'genderOption=$genderOption',
    );

    _setState(
      state.copyWith(status: RandomChatStatus.matching),
    );

    debugPrint(
      '⏳ AFTER set matching '
      'currentState=${state.status}',
    );

    try {
      debugPrint('🌐 startMatching() REQUEST START');

      matchRepository.startMatching(
        userIdx: userIdx,
        genderOption: genderOption,
        onMatchUpdate: (matchData) {
          // 콜백으로 실시간 응답 받기!
          if (matchData.isWaiting) {
            _setState(state.copyWith(status: RandomChatStatus.matching));
          } else if (matchData.isMatched) {
            _setState(state.copyWith(status: RandomChatStatus.matched, roomIdx: matchData.roomIdx.toString()));
          }
        },
      );
    } catch (e, s) {
      debugPrint('❌ startMatching ERROR');
      debugPrint('❌ error=$e');
      debugPrintStack(stackTrace: s);

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
    matchRepository.cancelMatching();
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