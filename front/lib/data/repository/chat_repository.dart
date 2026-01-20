import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:front/data/data_source/remote/api_client.dart';
import 'package:front/data/data_source/remote/websocket_client.dart';
import 'package:front/dto/chat_dto.dart';

/// 채팅 Repository
/// - WebSocket: 실시간 메시지 수신/전송 (매칭에서 이미 연결된 WebSocket 재사용)
/// - HTTP: 채팅 히스토리 조회 (나중에 MongoDB 연동 시, ApiClient를 통한 토큰 자동 관리)
class ChatRepository {
  final WebSocketClient wsClient;
  final ApiClient apiClient;
  bool _isSubscribed = false; // 구독 중복 방지 플래그
  String? _currentRoomIdx; // 현재 구독 중인 roomIdx

  ChatRepository({required this.wsClient, required this.apiClient});

  /// ==========================
  /// WebSocket 메서드 (실시간 채팅)
  /// ==========================

  /// 채팅 구독 시작
  /// - **핵심**: 매칭에서 이미 WebSocket 연결되어 있으므로 연결은 하지 않고 구독만 시작
  /// - roomIdx 기반으로 `/topic/room/{roomIdx}` 구독
  /// - 실시간 메시지 수신 처리
  /// - **확장성**: 나중에 초기 데이터 수신 처리 추가 가능하도록 구조 설계
  Future<void> connectAndSubscribe({
    required String roomIdx,
    required Function(ChatDto) onMessage,
  }) async {
    debugPrint('🔌 [ChatRepo] 채팅 구독 시작 - roomIdx: $roomIdx');

    // WebSocket 연결 상태 확인 (이미 연결되어 있어야 함)
    if (!wsClient.isConnected) {
      final error = Exception(
        "WebSocket이 연결되지 않았습니다. 먼저 매칭을 통해 WebSocket을 연결해주세요.",
      );
      debugPrint('❌ [ChatRepo] WebSocket 연결 상태 확인 실패: $error');
      throw error;
    }

    try {
      // 구독은 한 번만 등록! (roomIdx가 바뀌면 재구독)
      if (!_isSubscribed || _currentRoomIdx != roomIdx) {
        // 이전 구독 해제 (roomIdx가 바뀐 경우)
        if (_isSubscribed &&
            _currentRoomIdx != null &&
            _currentRoomIdx != roomIdx) {
          wsClient.unsubscribe('/topic/room/$_currentRoomIdx');
          debugPrint('🔌 [ChatRepo] 이전 구독 해제 - roomIdx: $_currentRoomIdx');
        }

        _subscribeToChat(roomIdx, onMessage);
        _isSubscribed = true;
        _currentRoomIdx = roomIdx;
        debugPrint('✅ [ChatRepo] 채팅 구독 등록 완료 - roomIdx: $roomIdx');
      }
    } catch (e) {
      debugPrint('❌ [ChatRepo] 채팅 구독 실패: $e');
      rethrow;
    }
  }

  /// 구독 로직 분리 (응답 처리 전용)
  void _subscribeToChat(String roomIdx, Function(ChatDto) onMessage) {
    wsClient.subscribe(
      destination: '/topic/room/$roomIdx',
      callback: (frame) {
        try {
          final json = jsonDecode(frame.body ?? '{}');
          final chatMessage = ChatDto.fromJson(json);
          onMessage(chatMessage);
          debugPrint(
            '✅ [ChatRepo] 채팅 메시지 수신 완료 - chatIdx: ${chatMessage.chatIdx}',
          );
        } catch (e) {
          debugPrint('❌ [ChatRepo] 메시지 파싱 실패: $e');
        }
      },
    );
  }

  /// 메시지 전송
  /// - `/app/chat/{roomIdx}/send`로 전송
  Future<void> sendMessage({
    required String roomIdx,
    required String content,
  }) async {
    debugPrint('📤 [ChatRepo] 메시지 전송 - roomIdx: $roomIdx, content: $content');

    // 연결 상태 확인
    if (!wsClient.isConnected) {
      final error = Exception(
        "WebSocket이 연결되지 않았습니다. 먼저 connectAndSubscribe()를 호출해주세요.",
      );
      debugPrint('❌ [ChatRepo] 연결 상태 확인 실패: $error');
      throw error;
    }

    try {
      // 요청 보내기
      debugPrint('📤 [ChatRepo] 메시지 전송 요청 - /app/chat/$roomIdx/send');
      wsClient.send('/app/chat/$roomIdx/send', {'content': content});
      debugPrint('✅ [ChatRepo] 메시지 전송 요청 완료');
    } catch (e, s) {
      debugPrint('❌ [ChatRepo] sendMessage 실패: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  /// 채팅 구독 해제
  /// - `/topic/room/{roomIdx}` 구독 해제
  void unsubscribeFromChat(String roomIdx) {
    debugPrint('🔌 [ChatRepo] 채팅 구독 해제 - roomIdx: $roomIdx');
    try {
      wsClient.unsubscribe('/topic/room/$roomIdx');
      _isSubscribed = false;
      _currentRoomIdx = null;
      debugPrint('✅ [ChatRepo] 채팅 구독 해제 완료');
    } catch (e) {
      debugPrint('❌ [ChatRepo] 구독 해제 실패: $e');
    }
  }

  /// ==========================
  /// HTTP 메서드 (채팅 히스토리 조회 - 나중에 MongoDB 연동 시)
  /// ==========================

  /// 채팅방 메시지 목록 조회 (HTTP)
  /// - ApiClient를 통한 토큰 자동 검증 및 재발급
  /// - 나중에 MongoDB 히스토리 기능과 함께 사용
  Future<List<ChatDto>> fetchChats({required String roomId}) async {
    final response = await apiClient.get('/api/chat/rooms/$roomId/messages');

    if (response.statusCode != 200) {
      throw Exception('채팅 메시지 조회 실패: ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final List list = decoded['data'];

    return list
        .map((e) => ChatDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
