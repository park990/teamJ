package com.teamj.controller.randomChat_control;

import java.util.Map;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;

import com.teamj.dto.randomChat_dto.MatchData;
import com.teamj.dto.response.WebSocketResponse;
import com.teamj.config.CustomUserDetails;
import com.teamj.service.match_service.MatchService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
public class MatchWebSocketController {
    
    private final MatchService matchService;
    private final SimpMessagingTemplate messagingTemplate;
    // JwtTokenProvider 제거 (이제 Interceptor에서 처리하니까 불필요)

    /**
     * 매칭 대기열 진입 요청 처리
     * 
     * 클라이언트 → 서버:
     *   stompClient.send('/app/match/enter', {}, { genderOption: 'female' })
     * 
     * 서버 → 클라이언트:
     *   messagingTemplate.convertAndSend('/queue/match/123', response)
     * 
     * @param user JwtChannelInterceptor에서 SecurityContext에 저장한 인증 정보
     *             → HTTP 컨트롤러의 @AuthenticationPrincipal과 동일한 방식!
     * @param request 클라이언트가 보낸 페이로드 { genderOption: 'male' | 'female' | 'random' }
     */
    @MessageMapping("/match/enter")
    public void enterQueue(
        @AuthenticationPrincipal CustomUserDetails user,  // ← Interceptor에서 설정한 인증 정보
        @Payload Map<String, String> request
    ) {
        // 1. 인증된 사용자 정보 가져오기
        //    (JwtChannelInterceptor에서 이미 검증 완료!)
        Long userIdx = user.getUserIdx();
        log.info("🎯 매칭 요청 수신 - userIdx: {}", userIdx);
        
        // 2. 요청 데이터에서 genderOption 추출
        String genderOption = request.get("genderOption");
        log.info("   희망 성별: {}", genderOption);

        // 3. MatchService 호출 (매칭 로직 실행)
        WebSocketResponse<MatchData> response = matchService.enterQueue(userIdx, genderOption);
        
        // 4. 클라이언트에게 응답 전송 (개인 큐로)
        //    /queue/match/{userIdx} 를 구독하고 있는 클라이언트에게만 전송
        messagingTemplate.convertAndSend("/queue/match/" + userIdx, response);
        
        log.info("✅ 매칭 응답 전송 완료 - userIdx: {}, status: {}", userIdx, response.getData().getStatus());
    }

    /**
     * 매칭 취소 요청 처리
     * 
     * 클라이언트 → 서버:
     *   stompClient.send('/app/match/cancel', {}, {})
     * 
     * @param user 인증된 사용자 정보
     */
    @MessageMapping("/match/cancel")
    public void cancelQueue(@AuthenticationPrincipal CustomUserDetails user) {
        Long userIdx = user.getUserIdx();
        log.info("❌ 매칭 취소 요청 - userIdx: {}", userIdx);
        
        // TODO: 매칭 취소 로직 구현
        // - MatchQueueManager에서 사용자 제거
        // - 취소 응답 전송
    }
}
