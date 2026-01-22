import 'package:front/dto/gatherings/gathering_action_response_dto.dart';

class GatheringCreateState {
  final bool? isLoading;
  final GatheringActionResponseDto? result;
  final String? errorMessage;

  const GatheringCreateState({
    required this.isLoading,
    this.result,
    this.errorMessage,
  });

  factory GatheringCreateState.initial() {
    return const GatheringCreateState(
      isLoading: false,
      result: null,
      errorMessage: null,
    );
  }

  GatheringCreateState copyWith({
    bool? isLoading,
    GatheringActionResponseDto? result,
    String? errorMessage,
  }) {
    return GatheringCreateState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

}