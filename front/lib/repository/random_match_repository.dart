import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/dto/random_match_dto.dart';

class RandomMatchRepository {
  final String baseUrl = dotenv.env['API_URL']!;
  final andUrl = "http://10.0.2.2:8080";

  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<RandomMatchDto> enterQueue({
    required String genderOption,
  }) async {
    final response = await http.post(
      Uri.parse('$andUrl/api/random-match/enter'),
      headers: _headers,
      body: jsonEncode({
        'genderOption': genderOption,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('랜덤 매칭 실패 ${response.statusCode}');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes));
    return RandomMatchDto.fromJson(json['data']);
  }

  Future<void> cancelQueue() async {
    final response = await http.post(
      Uri.parse('$andUrl/api/random-match/cancel'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('랜덤 매칭 취소 실패 ${response.statusCode}');
    }
  }
}