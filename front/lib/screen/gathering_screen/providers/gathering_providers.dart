import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/data/repository/gathering_repository.dart';
import 'package:front/dto/gatherings/gathering_create_request_dto.dart';

import 'package:front/dto/gatherings/gathering_hotList_dto.dart';
import 'package:front/dto/gatherings/gathering_newList_dto.dart';
import 'package:front/screen/gathering_screen/providers/gathering_create_state.dart';
import 'package:image_picker/image_picker.dart';

//*** 기본 인프라 Provider (ApiClient, Repository) ***/
// ApiClient 인스턴스를 제공하는 Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref);
});

// 모임 데이터 API 호출 Repository
final gatheringRepositoryProvider = Provider<GatheringRepository>((ref) {
  return GatheringRepository(ref.read(apiClientProvider));
});

//*** 모임 생성 Provider ***/
// 모임 생성 상태 관리를 위한 Provider 등록
// Provider 등록
final gatheringCreateProvider =
    NotifierProvider<GatheringCreateNotifier, GatheringCreateState>(() {
  return GatheringCreateNotifier();
});

class GatheringCreateNotifier extends Notifier<GatheringCreateState> {
  // 초기 상태 반환(필수)
  @override
  GatheringCreateState build() {
    return GatheringCreateState.initial();
  }
  // 모임 생성 메서드
  Future<void> createGathering({
    required GatheringCreateRequestDto dto,
    XFile? imageFile,
  }) async {
    try {
      // (1) 로딩 시작 - state를 copyWith로 업데이트
      // TODO: isLoading을 true로, errorMessage를 null로 설정
      state = state.copyWith(isLoading: true, errorMessage: null);
      // (2) Repository 가져오기
      // TODO: ref.read()로 gatheringRepositoryProvider 가져오기
      final repository = ref.read(gatheringRepositoryProvider);
      // (3) API 호출
      // TODO: repository.createGathering() 호출
      final result = await repository.createGathering(dto: dto, imageFile: imageFile);
      // (4) 성공 - 결과 저장
      // TODO: isLoading을 false로, result에 결과 저장
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      // (5) 실패 - 에러 메시지 저장
      // TODO: isLoading을 false로, errorMessage에 에러 저장
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}


//*** 핫한 모임 Provider ***/
// Provider 등록
final gatheringHotListProvider =
    AsyncNotifierProvider<GatheringHotListNotifier, List<GatheringHotlistDto>>(() {
  return GatheringHotListNotifier();
});

// 상태 관리 클래스
class GatheringHotListNotifier extends AsyncNotifier<List<GatheringHotlistDto>> {
  @override
  FutureOr<List<GatheringHotlistDto>> build() async {
    // Repository에서 '핫한 모임' 가져오기
    final repository = ref.watch(gatheringRepositoryProvider);
    return await repository.fetchHotGatherings();
  }

  // 핫한 모임만 새로고침 (Pull to refresh 또는 버튼 클릭 시 사용)
  Future<void> refresh() async {
    state = const AsyncLoading(); // 로딩 상태로 전환
    final repository = ref.read(gatheringRepositoryProvider);
    // 에러 발생 시 예외 처리까지 포함하여 상태 업데이트
    state = await AsyncValue.guard(() => repository.fetchHotGatherings());
  }
}

//*** 새로운 모임 Provider ***/
// Provider 등록
final gatheringNewListProvider =
    AsyncNotifierProvider<GatheringNewListNotifier, List<GatheringNewlistDto>>(() {
  return GatheringNewListNotifier();
});

// 상태 관리 클래스
class GatheringNewListNotifier extends AsyncNotifier<List<GatheringNewlistDto>> {
  @override
  FutureOr<List<GatheringNewlistDto>> build() async {
    // Repository에서 '새로운 모임' 가져오기
    final repository = ref.watch(gatheringRepositoryProvider);
    return await repository.fetchNewGatherings();
  }

  // 새로운 모임만 새로고침
  Future<void> refresh() async {
    state = const AsyncLoading();
    final repository = ref.read(gatheringRepositoryProvider);
    state = await AsyncValue.guard(() => repository.fetchNewGatherings());
  }
}
