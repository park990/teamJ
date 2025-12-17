import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:front/dto/chat_dto.dart';

class ChatRepository {
  final String baseUrl;
  final andUrl = "http://10.0.2.2:8080";

  ChatRepository({
    required this.baseUrl,
  });

  /// 채팅방 메시지 목록 조회
  Future<List<ChatDto>> fetchChats({
    required String roomId,
  }) async {

    final response = await http.get(
      Uri.parse('$andUrl/api/chat/rooms/$roomId/messages'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('채팅 메시지 조회 실패');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    final List list = decoded['data'];

    return list
        .map((e) => ChatDto.fromJson(e))
        .toList();
  }
}