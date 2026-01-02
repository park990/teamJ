import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/data/repository/gathering_repository.dart';
import 'package:front/screen/gathering_screen/model/gathering_model.dart';
//******** 기본 인프라 Provider (ApiClient, Repository) ********/
// ApiClient 인스턴스를 제공하는 Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref);
});

// 모임 데이터 API 호출 Repository
final gatheringRepositoryProvider = Provider<GatheringRepository>((ref) {
  return GatheringRepository(ref.read(apiClientProvider));
});

//******** 핫한 모임 Provider ********/
// Provider 등록
final gatheringHotListProvider =
    AsyncNotifierProvider<GatheringHotListNotifier, List<GatheringModel>>(() {
  return GatheringHotListNotifier();
});

// 상태 관리 클래스
class GatheringHotListNotifier extends AsyncNotifier<List<GatheringModel>> {
  @override
  FutureOr<List<GatheringModel>> build() async {
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

//******** 새로운 모임 Provider ********/
// Provider 등록
final gatheringNewListProvider =
    AsyncNotifierProvider<GatheringNewListNotifier, List<GatheringModel>>(() {
  return GatheringNewListNotifier();
});

// 상태 관리 클래스
class GatheringNewListNotifier extends AsyncNotifier<List<GatheringModel>> {
  @override
  FutureOr<List<GatheringModel>> build() async {
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
