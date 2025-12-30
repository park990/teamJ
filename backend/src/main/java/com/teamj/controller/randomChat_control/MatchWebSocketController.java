package com.teamj.controller.randomChat_control;

import java.util.Map;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.teamj.dto.randomChat_dto.MatchData;
import com.teamj.dto.response.WebSocketResponse;
import com.teamj.jwt.JwtTokenProvider;
import com.teamj.service.match_service.MatchService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
public class MatchWebSocketController {
    
    private final MatchService matchService;
    private final SimpMessagingTemplate messagingTemplate;
    private final JwtTokenProvider jwtTokenProvider;

    /**
 * SimpMessagingTemplate
 * 
 * 【 정의 】
 * - Spring WebSocket에서 서버가 클라이언트에게 메시지를 전송하기 위한 템플릿 클래스
 * - 브로커(Broker)를 통해 메시지를 발행(publish)하는 역할
 * 
 * 【 목적 】
 * - @MessageMapping 메서드는 void 반환이므로, 리턴값으로 응답을 보낼 수 없음
 * - HTTP 컨트롤러의 ResponseEntity처럼, WebSocket에서는 이 템플릿을 사용해서 응답 전송
 * - convertAndSend(destination, payload): 특정 경로(destination)로 메시지 전송
 *   • /topic/... → 여러 클라이언트에게 브로드캐스트
 *   • /queue/... → 특정 클라이언트에게 개인 메시지 전송
 * 
 * 【 자동 주입 】
 * - Spring Boot가 WebSocket 설정을 감지하면 자동으로 빈으로 등록
 * - @RequiredArgsConstructor를 통해 생성자 주입으로 사용
 */
    @MessageMapping("/match/enter")
    public void enterQueue(@Payload Map<String, String> request, SimpMessageHeaderAccessor headerAccessor) {
        // 1. 헤더에서 토큰 추출
        String bearerToken = headerAccessor.getFirstNativeHeader("Authorization");
        if (bearerToken == null || !bearerToken.startsWith("Bearer ")) {
            log.error("토큰이 없거나 형식이 잘못됨");
            // 에러 응답 전송 필요
            return;
        }
        
        String token = bearerToken.substring(7); // "Bearer " 제거
        
        // 2. 토큰에서 userIdx 추출
        Long userIdx;
        try {
            userIdx = jwtTokenProvider.getuserIdx(token);
        } catch (Exception e) {
            log.error("토큰 파싱 실패: {}", e.getMessage());
            // 에러 응답 전송 필요
            return;
        }
        
        // 3. genderOption 추출
        String genderOption = request.get("genderOption");

        // 4. MatchService 호출
        WebSocketResponse<MatchData> response = matchService.enterQueue(userIdx, genderOption);
        
        // 5. 클라이언트에게 응답 전송 (개인 큐로)
        messagingTemplate.convertAndSend("/queue/match/" + userIdx, response);
    }

    @MessageMapping("/match/cancel")
    public void cancelQueue(@Payload Map<String, String> request, SimpMessageHeaderAccessor headerAccessor) {
        // 매칭 취소 로직
    }
}
