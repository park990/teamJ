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
  /// 랜덤채팅 시작
  /// ==========================
  Future<void> startMatching({required String genderOption}) async {
    debugPrint(
      '▶ startMatching() CALLED '
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
      debugPrint('🌐 enterQueue() REQUEST START');

      final dto = await matchRepository.enterQueue(
        genderOption: genderOption,
      );

      debugPrint(
        '✅ enterQueue() RESPONSE '
        'matched=${dto.matched}, '
        'roomIdx=${dto.roomIdx}',
      );

      if (dto.matched && dto.roomIdx != null) {
        debugPrint('🎯 MATCH SUCCESS');

        _setState(
          state.copyWith(
            status: RandomChatStatus.matched,
            roomIdx: dto.roomIdx,
          ),
        );
      } else {
        debugPrint('⌛ STILL MATCHING');

        _setState(
          state.copyWith(status: RandomChatStatus.matching),
        );
      }
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
}