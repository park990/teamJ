import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/dto/random_match_dto.dart';

class RandomMatchRepository {
  final ApiClient apiClient;

  RandomMatchRepository(this.apiClient);

  Future<RandomMatchDto> enterQueue({
    required String genderOption,
  }) async {
    debugPrint(
      '🌐 [RandomMatchRepo] POST /api/random-match/enter '
      'genderOption=$genderOption',
    );

    final response = await apiClient.post(
      '/api/random-match/enter',
      body: {
        'genderOption': genderOption,
      },
    );

    final body = utf8.decode(response.bodyBytes);

    debugPrint(
      '🌐 [RandomMatchRepo] RESPONSE '
      'status=${response.statusCode} body=$body',
    );

    if (response.statusCode != 200) {
      debugPrint('❌ [RandomMatchRepo] enterQueue FAILED');
      throw Exception('랜덤 매칭 실패 ${response.statusCode}');
    }

    final json = jsonDecode(body);
    return RandomMatchDto.fromJson(json['data']);
  }

  Future<void> cancelQueue() async {
    debugPrint('🌐 [RandomMatchRepo] POST /api/random-match/cancel');

    final response = await apiClient.post('/api/random-match/cancel');

    debugPrint(
      '🌐 [RandomMatchRepo] cancel RESPONSE '
      'status=${response.statusCode}',
    );

    if (response.statusCode != 200) {
      debugPrint('❌ [RandomMatchRepo] cancelQueue FAILED');
      throw Exception('랜덤 매칭 취소 실패 ${response.statusCode}');
    }
  }
}