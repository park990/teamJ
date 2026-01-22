package com.teamj.controller.randomChat_control;

import java.util.Map;

import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.teamj.config.CustomUserDetails;
import com.teamj.dto.randomChat_dto.ChatMessageDto;
import com.teamj.service.chat_service.ChatService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * 채팅 WebSocket 컨트롤러 (통신 레이어)
 * 
 * 【 역할 분담 】
 * Controller: 요청 받기 → Service 호출 → ChatMessageDto 받기 → 브로드캐스트
 * Service:    비즈니스 로직 (ChatMessageDto 반환)
 * 
 * 【 흐름 】
 * 1. 클라이언트 → 서버: stompClient.send('/app/chat/{roomIdx}/send', {}, {content: '안녕'})
 * 2. Service 호출: ChatMessageDto 받음
 * 3. 브로드캐스트: /topic/room/{roomIdx}로 전송 (방에 있는 모든 사용자에게)
 * 
 * 【 사용자 정보 추출 방법 】
 * - @Header("simpSessionAttributes")로 세션 속성에서 직접 추출
 * - 스레드 문제로 인한 Principal 주입 실패 대응
 */
@Controller
@RequiredArgsConstructor
@Slf4j
public class ChatWebSocketController {
    
    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;

    /**
     * 채팅 메시지 전송 요청 처리 (통신 레이어)
     * 
     * 클라이언트 → 서버:
     *   stompClient.send('/app/chat/123/send', {}, {content: '안녕하세요'})
     * 
     * 서버 → 클라이언트 (브로드캐스트):
     *   /topic/room/123 구독한 모든 클라이언트에게 ChatMessageDto 전송
     * 
     * @param roomIdx 채팅방 ID (경로 변수)
     * @param sessionAttributes WebSocket 세션 속성 맵 (JwtChannelInterceptor에서 저장한 userDetails 포함)
     * @param request 클라이언트 요청 { content: '메시지 내용' }
     */
    @MessageMapping("/chat/{roomIdx}/send")
    public void sendMessage(
        @DestinationVariable("roomIdx") Long roomIdx,
        @Header("simpSessionAttributes") Map<String, Object> sessionAttributes,
        @Payload Map<String, String> request
    ) {
        // 1. 인증 정보 추출 (세션 속성에서 직접 가져오기)
        //    → JwtChannelInterceptor에서 CONNECT 시 세션 속성에 저장한 userDetails 사용
        //    → 스레드 문제 없이 안전하게 접근 가능!
        if (sessionAttributes == null) {
            log.error("❌ 채팅 메시지 전송 실패: 세션 속성 맵이 null입니다!");
            return;
        }
        
        CustomUserDetails user = (CustomUserDetails) sessionAttributes.get("userDetails");
        if (user == null) {
            log.error("❌ 채팅 메시지 전송 실패: 세션에 사용자 정보가 없습니다! 세션 속성 키: {}", sessionAttributes.keySet());
            return;
        }
        
        Long userIdx = user.getUserIdx();
        String content = request.get("content");
        
        if (content == null || content.trim().isEmpty()) {
            log.warn("⚠️ 빈 메시지 전송 시도 - roomIdx: {}, userIdx: {}", roomIdx, userIdx);
            return;
        }
        
        log.info("💬 채팅 메시지 전송 요청 - roomIdx: {}, userIdx: {}, content: {}", 
                roomIdx, userIdx, content);
        
        // 2. Service 호출 (비즈니스 로직)
        try {
            ChatMessageDto chatMessageDto = chatService.sendMessage(roomIdx, userIdx, content);
            
            // 3. 브로드캐스트 (방에 있는 모든 사용자에게 전송)
            //    → /topic/room/{roomIdx}를 구독한 모든 클라이언트에게 전송
            messagingTemplate.convertAndSend("/topic/room/" + roomIdx, chatMessageDto);
            
            log.info("✅ 채팅 메시지 브로드캐스트 완료 - roomIdx: {}, userIdx: {}, chatIdx: {}", 
                    roomIdx, userIdx, chatMessageDto.getChatIdx());
        } catch (Exception e) {
            // 예외 발생 시 에러 로그 기록
            log.error("❌ 채팅 메시지 전송 처리 실패 - roomIdx: {}, userIdx: {}, content: {}, error: {}", 
                    roomIdx, userIdx, content, e.getMessage(), e);
            
            // TODO: 나중에 에러 응답 전송 고려 (선택)
            // 클라이언트에 에러 알림을 보낼지 결정 (현재는 로그만 기록)
        }
    }
}
