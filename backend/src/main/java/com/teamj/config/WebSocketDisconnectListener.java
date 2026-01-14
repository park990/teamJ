package com.teamj.config;

import java.util.Map;

import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import com.teamj.service.match_service.MatchService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Component
@RequiredArgsConstructor
@Slf4j
public class WebSocketDisconnectListener {
    
    private final MatchService matchService;

    @EventListener
    public void handleSessionDisconnect(SessionDisconnectEvent event) {
        
        // 1. StompHeaderAccessor로 세션 정보 추출
        // event.getMessage(): SessionDisconnectEvent에 포함된 원시 메시지 객체
        //   → 연결이 끊긴 세션의 정보(세션 속성, 헤더 등)가 들어있지만 원시 형태라 직접 읽기 어려움
        // StompHeaderAccessor.wrap(): 원시 메시지를 StompHeaderAccessor로 감싸서 사용하기 쉽게 만듦
        //   → 이제 headerAccessor.getSessionAttributes() 같은 편리한 메서드 사용 가능
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());

        // 2. 세션 속성에서 userDetails 추출
        //    (JwtChannelInterceptor에서 CONNECT 시 저장한 정보)
        Map<String, Object> sessionAttributes = headerAccessor.getSessionAttributes();
        if (sessionAttributes == null) {
            log.debug("❌ 세션 속성 맵이 null입니다!");
            return;
        }

        CustomUserDetails userDetails = (CustomUserDetails) sessionAttributes.get("userDetails");
        if (userDetails == null) {
            log.debug("❌ 세션에 사용자 정보가 없습니다!");
            return;
        }

        Long userIdx = userDetails.getUserIdx();
        log.info("🔌 WebSocket 연결 해제 감지 - userIdx: {}", userIdx);

        // 3. Redis 매칭 큐에서 제거
        try {
            matchService.cancelQueue(userIdx);
            log.info("✅ 연결 해제 시 매칭 큐에서 제거 완료 - userIdx: {}", userIdx);
        } catch (Exception e) {
            // 큐에 없을 수도 있음 (이미 매칭 완료했거나, 취소했거나)
            log.debug("⚠️ 연결 해제 시 큐 제거 실패 (정상일 수 있음) - userIdx: {}, error: {}", 
                userIdx, e.getMessage());
        }
    }
}
