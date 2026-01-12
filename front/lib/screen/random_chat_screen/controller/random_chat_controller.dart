import 'package:flutter/material.dart';
import 'package:front/data/repository/random_match_repository.dart';
import '../models/random_chat_state.dart';

class RandomChatController extends ChangeNotifier {
  final RandomMatchRepository matchRepository;
  int? _userIdx;  // ← nullable로 변경
  bool _isInitialized = false;  // 초기화 중복 방지

  RandomChatController({required this.matchRepository}) {
    debugPrint(
      '🔥 RandomChatController CREATED hash=$hashCode',
    ); // 메모리 주소 출력
  }

  RandomChatState _state = RandomChatState.idle();

  RandomChatState get state => _state;
  
  // userIdx 설정
  void setUserIdx(int? userIdx) {
    _userIdx = userIdx;
    debugPrint('[RandomChatController] 🔄 userIdx 설정: $userIdx');

    // userIdx가 null이 되면 연결 해제 (로그아웃 시)
    if (userIdx == null && _isInitialized) {
      matchRepository.disconnect();
      _isInitialized = false;
      _userIdx = null;
    }
  }

  /// ==========================
  /// 상태 변경 전용 함수
  /// ==========================
  void _setState(RandomChatState newState) {
    debugPrint(
      '[RandomChatController] 🔄 STATE CHANGE '
      '[${_state.status} → ${newState.status}] '
      'roomIdx: ${newState.roomIdx}',
    );

    _state = newState;
    notifyListeners(); // 상태 변경 알림 = ref.watch() 호출

    debugPrint('[RandomChatController] 📢 notifyListeners() called');
  }

  /// ==========================
  /// 상태 초기화
  /// ==========================
  void reset() {
    debugPrint('[RandomChatController] ♻️ reset() called');
    _setState(RandomChatState.idle());
  }

  /// ==========================
  /// WebSocket 연결
  /// ==========================
  Future<void> connect() async {

    if (_userIdx == null) {
      debugPrint('[RandomChatController] ❌ userIdx가 null입니다. 초기화할 수 없습니다.');
      throw Exception('로그인이 필요합니다.');
    }
    
    if (_isInitialized) {
      debugPrint('[RandomChatController] ⚠️ 이미 초기화되었습니다.');
      return;
    }

    try {
      await matchRepository.connectAndSubscribe(
        userIdx: _userIdx!,
        onMatchUpdate: (matchData) {
          // 콜백으로 실시간 응답 받기!
          // 모든 응답 처리 (시작, 취소, 성공 등)
          if (matchData.isWaiting) {
            _setState(state.copyWith(status: RandomChatStatus.matching));
          } else if (matchData.isMatched) {
            _setState(state.copyWith(status: RandomChatStatus.matched, roomIdx: matchData.roomIdx.toString()));
          } else if (matchData.isCancelled) {
            _setState(state.copyWith(status: RandomChatStatus.idle));
          }
        },
      );
      _isInitialized = true;
      debugPrint('[RandomChatController] ✅ connect() 완료');
    } catch (e, s) {
      debugPrint('[RandomChatController] ❌ connect() 실패: $e');
      debugPrintStack(stackTrace: s);
      _isInitialized = false;  // 재시도 가능하도록
      rethrow;  // startMatching()에서 처리하도록
    }
  }

  /// ==========================
  /// 매칭 시작
  /// ==========================
  Future<void> startMatching({required String genderOption}) async {
    debugPrint('[RandomChatController] ▶ startMatching() CALLED genderOption: $genderOption');
    try {
      // 연결 안 되어있으면 먼저 연결
      if (!_isInitialized) {
        debugPrint('[RandomChatController] 🔌 WebSocket 연결 시작...');
        await connect();
      }


      debugPrint('[RandomChatController] 🌐 startMatching() REQUEST START');

      // 요청 보내기 (성공하면 상태 변경)
      await matchRepository.startMatching(genderOption: genderOption);

      // 요청 전송 성공 후 상태 변경 (에러 없으면 여기까지 옴)
      debugPrint('[RandomChatController] ✅ startMatching() REQUEST SUCCESS');
      _setState(state.copyWith(status: RandomChatStatus.matching));
    } catch (e, s) {
      debugPrint('[RandomChatController] ❌ startMatching ERROR = $e');
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
    debugPrint('[RandomChatController] ▶ cancelMatching() CALLED');
    try {
      matchRepository.cancelMatching();
    } catch (e, s) {
      debugPrint('[RandomChatController] ❌ cancelMatching ERROR: $e');
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
    debugPrint('[RandomChatController] ▶ dispose() CALLED');
    matchRepository.disconnect();
    super.dispose();
  }
}
