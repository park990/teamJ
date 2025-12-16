import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/dto/random_match_dto.dart';

class RandomMatchRepository {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<RandomMatchDto> enterQueue({
    required String genderOption,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/random-match/enter'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'genderOption': genderOption,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('랜덤 매칭 실패');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes));
    return RandomMatchDto.fromJson(json['data']);
  }

  Future<void> cancelQueue() async {
    await http.post(
      Uri.parse('$baseUrl/api/random-match/cancel'),
    );
  }
}