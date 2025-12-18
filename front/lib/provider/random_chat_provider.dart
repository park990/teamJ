import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repository/random_match_repository.dart';
import 'package:front/screen/random_chat_screen/controller/random_chat_controller.dart';

/// 1. Repository Provider
final randomMatchRepositoryProvider = 
  Provider<RandomMatchRepository>((ref) {
  return RandomMatchRepository();
});


/// 2. Controller Provider
final randomChatControllerProvider =
  ChangeNotifierProvider<RandomChatController>((ref) {
  final repo = ref.read(randomMatchRepositoryProvider);
  return RandomChatController(matchRepository: repo);
});