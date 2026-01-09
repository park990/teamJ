package com.teamj.controller.randomChat_control;

import java.util.Map;

import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.teamj.dto.randomChat_dto.MatchData;
import com.teamj.dto.randomChat_dto.MatchPair;
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
     * 매칭 대기열 진입 요청 처리 (통신 레이어)
     * 
     * 【 역할 분담 】
     * Controller: 요청 받기 → Service 호출 → MatchPair 받기 → 각각 전송
     * Service:    비즈니스 로직 (MatchPair 반환)
     * 
     * 【 흐름 】
     * 1. 클라이언트 → 서버: stompClient.send('/app/match/enter', {}, {genderOption: 'female'})
     * 2. Service 호출: MatchPair 받음 (요청자용, 상대방용)
     * 3. 대기 중: 요청자에게만 전송
     * 4. 매칭 성공: 양쪽 모두에게 전송
     * 
     * 【 WebSocketResponse 제거 】
     * - destination으로 메시지 타입 구분 (/queue/match/ → 매칭)
     * - MatchData 직접 전송 (불필요한 중첩 제거)
     * 
     * 【 사용자 정보 추출 방법 】
     * - @Header("simpSessionAttributes")로 세션 속성에서 직접 추출
     * - 스레드 문제로 인한 Principal 주입 실패 대응
     * 
     * @param sessionAttributes WebSocket 세션 속성 맵 (JwtChannelInterceptor에서 저장한 userDetails 포함)
     * @param request 클라이언트 요청 { genderOption: 'male' | 'female' | 'random' }
     */
    @MessageMapping("/match/enter")
    public void enterQueue(
        @Header("simpSessionAttributes") Map<String, Object> sessionAttributes,
        @Payload Map<String, String> request
    ) {
        // 1. 인증 정보 추출 (세션 속성에서 직접 가져오기)
        //    → JwtChannelInterceptor에서 CONNECT 시 세션 속성에 저장한 userDetails 사용
        //    → 스레드 문제 없이 안전하게 접근 가능!
        if (sessionAttributes == null) {
            log.error("❌ 매칭 요청 실패: 세션 속성 맵이 null입니다!");
            return;
        }
        
        CustomUserDetails user = (CustomUserDetails) sessionAttributes.get("userDetails");
        if (user == null) {
            log.error("❌ 매칭 요청 실패: 세션에 사용자 정보가 없습니다! 세션 속성 키: {}", sessionAttributes.keySet());
            return;
        }
        
        Long userIdx = user.getUserIdx();
        String genderOption = request.get("genderOption");
        log.info("🎯 매칭 요청 수신 - userIdx: {}, genderOption: {}", userIdx, genderOption);
        
        // 2. Service 호출 (비즈니스 로직)
        MatchPair pair = matchService.enterQueue(userIdx, genderOption);
        
        // 3-1. 대기 중인 경우
        if (!pair.isMatched()) {
            // 요청자에게만 전송
            MatchData requesterData = pair.getRequesterData();
            messagingTemplate.convertAndSend("/queue/match/" + userIdx, requesterData);  // ← MatchData 직접!
            
            log.info("⏳ 대기 응답 전송 완료 - userIdx: {}", userIdx);
            return;
        }
        
        // 3-2. 매칭 성공인 경우 (양쪽 모두에게 전송)
        
        MatchData requesterData = pair.getRequesterData();
        MatchData partnerData = pair.getPartnerData();
        
        // Null 체크 (방어적 프로그래밍)
        if (partnerData == null) {
            log.error("❌ 매칭 성공 상태인데 partnerData가 null - userIdx: {}", userIdx);
            return;
        }
        
        // 요청자에게 전송
        messagingTemplate.convertAndSend("/queue/match/" + userIdx, requesterData);  // ← MatchData 직접!
        log.info("✅ 요청자에게 매칭 응답 전송 - userIdx: {}, roomIdx: {}, partnerIdx: {}", 
                 userIdx, requesterData.getRoomIdx(), requesterData.getPartnerIdx());
        
        // 상대방에게 전송 (partnerIdx는 MatchData에서 추출)
        Long partnerIdx = requesterData.getPartnerIdx();  // 요청자 입장에서 partnerIdx
        messagingTemplate.convertAndSend("/queue/match/" + partnerIdx, partnerData);  // ← MatchData 직접!
        log.info("✅ 상대방에게 매칭 응답 전송 - partnerIdx: {}, roomIdx: {}, partnerIdx: {}", 
                 partnerIdx, partnerData.getRoomIdx(), partnerData.getPartnerIdx());
        
        log.info("🎉 양쪽 모두에게 매칭 알림 전송 완료!");
    }

    /**
     * 매칭 취소 요청 처리
     * 
     * 클라이언트 → 서버:
     *   stompClient.send('/app/match/cancel', {}, {})
     * 
     * @param sessionAttributes WebSocket 세션 속성 맵 (JwtChannelInterceptor에서 저장한 userDetails 포함)
     */
    @MessageMapping("/match/cancel")
    public void cancelQueue(
        @Header("simpSessionAttributes") Map<String, Object> sessionAttributes
    ) {
        // 인증 정보 추출 (세션 속성에서 직접 가져오기)
        if (sessionAttributes == null) {
            log.error("❌ 매칭 취소 실패: 세션 속성 맵이 null입니다!");
            return;
        }
        
        CustomUserDetails user = (CustomUserDetails) sessionAttributes.get("userDetails");
        if (user == null) {
            log.error("❌ 매칭 취소 실패: 세션에 사용자 정보가 없습니다! 세션 속성 키: {}", sessionAttributes.keySet());
            return;
        }
        
        Long userIdx = user.getUserIdx();
        log.info("❌ 매칭 취소 요청 - userIdx: {}", userIdx);
        
        // TODO: 매칭 취소 로직 구현
        // - MatchQueueManager에서 사용자 제거
        // - 취소 응답 전송
        try {
            // Service 호출
            matchService.cancelQueue(userIdx);
            
            // 취소 응답 전송 (CANCELLED 상태)
            MatchData cancelData = MatchData.cancelled();
            messagingTemplate.convertAndSend("/queue/match/" + userIdx, cancelData);
            
            log.info("✅ 매칭 취소 응답 전송 완료 - userIdx: {}", userIdx);
        } catch (Exception e) {
            log.error("❌ 매칭 취소 실패 - userIdx: {}, error: {}", userIdx, e.getMessage());
            // 에러 응답 전송도 고려 (선택)
        }
    }
}
