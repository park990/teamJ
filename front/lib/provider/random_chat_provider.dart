import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repository/random_match_repository.dart';
import 'package:front/screen/random_chat_screen/controller/random_chat_controller.dart';
import 'package:front/data/data_source/remote/api_client.dart';


/// 0. ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref);
});

/// 1. Repository Provider
final randomMatchRepositoryProvider =
    Provider<RandomMatchRepository>((ref) {
  return RandomMatchRepository(
    ref.read(apiClientProvider),
  );
});

/// 2. Controller Provider
final randomChatControllerProvider =
    ChangeNotifierProvider<RandomChatController>((ref) {
  return RandomChatController(
    matchRepository: ref.read(randomMatchRepositoryProvider),
  );
});