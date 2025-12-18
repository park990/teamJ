import 'package:flutter/material.dart';
import 'package:front/data/repository/random_match_repository.dart';
import '../models/random_chat_state.dart';

class RandomChatController extends ChangeNotifier {
  final RandomMatchRepository matchRepository;

  RandomChatController({
    required this.matchRepository,
  }) {
    print('🔥 RandomChatController created: $hashCode');
  }
  
  RandomChatState _state = RandomChatState.idle();

  RandomChatState get state => _state;

  // 상태 변경 전용 함수
  void _setState(RandomChatState newState) {
    _state = newState;
    notifyListeners();
  }

  /// 랜덤채팅 시작 버튼 클릭
  Future<void> startMatching({required String genderOption}) async {
    _setState(
      state.copyWith(status: RandomChatStatus.matching),
    );
    print('startMatching: $genderOption, state: ${state.status}');

    try {
      final dto = await matchRepository.enterQueue(
        genderOption: genderOption,
      );

      if (dto.matched && dto.roomIdx != null) {
        _setState(
          state.copyWith(
            status: RandomChatStatus.matched,
            roomIdx: dto.roomIdx,
          ),
        );
      } else {
        // 아직 매칭 안 됨 → 대기 상태 유지
        _setState(
          state.copyWith(status: RandomChatStatus.matching),
        );
      }
    } catch (e) {
      print('에러: ${e.toString()}');
      _setState(
        state.copyWith(
          status: RandomChatStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

}