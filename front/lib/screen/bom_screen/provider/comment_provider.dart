import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/data/repository/bbs/comments_repository.dart';
import 'package:front/screen/bom_screen/controller/comment_controller.dart';
import 'package:front/screen/bom_screen/model/comments_model.dart';

// 2. Repository 프로바이더
final commentsRepositoryProvider = Provider<CommentsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CommentsRepository(apiClient);
});

// 3. Controller 프로바이더
final commentListProvider = AsyncNotifierProvider.family<CommentController, List<Comments>, int>(
  () => CommentController(),
);

