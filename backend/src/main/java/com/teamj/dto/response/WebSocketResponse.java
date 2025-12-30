package com.teamj.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WebSocketResponse<T> {
    private String messageType;  // "MATCH", "CHAT", "NOTIFICATION" 등
    private T data;              // 실제 데이터
    private String error;        // 에러 메시지 (선택적)
    
    // 성공 응답 (데이터 있음)
    public static <T> WebSocketResponse<T> success(String messageType, T data) {
        return new WebSocketResponse<>(messageType, data, null);
    }
    
    // 에러 응답
    public static <T> WebSocketResponse<T> error(String messageType, String error) {
        return new WebSocketResponse<>(messageType, null, error);
    }
}

/*
*매칭 데이터 예시
    public class MatchData {
        private String status;      // "WAITING" | "MATCHED"
        private Long roomIdx;
        private Long partnerIdx;
    }

WebSocket Controller 예시
    MatchData matchData = new MatchData("MATCHED", roomIdx, partnerIdx);
    WebSocketResponse<MatchData> response = WebSocketResponse.success("MATCH", matchData);
    messagingTemplate.convertAndSend("/queue/match/" + userIdx, response); 
*/

/*
*채팅 데이터 예시
    public class ChatData {
        private String message;
        private Long senderIdx;
        private Long receiverIdx;
    }

WebSocket Controller 예시
    ChatData chatData = new ChatData("Hello", senderIdx, receiverIdx);
    WebSocketResponse<ChatData> response = WebSocketResponse.success("CHAT", chatData);
    messagingTemplate.convertAndSend("/topic/chat/" + roomIdx, response); 
*/

/*
*단체 채팅도 동일한 구조 사용
    WebSocketResponse<ChatMessage> response = WebSocketResponse.success("GROUP_CHAT", chatData);
    messagingTemplate.convertAndSend("/topic/group/" + groupId, response);
*/

/*
*알림 데이터 예시
    public class NotificationData {
        private String message;
        private Long senderIdx;
        private Long receiverIdx;
    }

WebSocket Controller 예시
    NotificationData notificationData = new NotificationData("Hello", senderIdx, receiverIdx);
    WebSocketResponse<NotificationData> response = WebSocketResponse.success("NOTIFICATION", notificationData);
    messagingTemplate.convertAndSend("/queue/notification/" + userIdx, response); 
*/