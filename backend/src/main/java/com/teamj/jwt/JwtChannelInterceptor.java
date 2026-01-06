package com.teamj.jwt;

import java.util.Collections;

import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import com.teamj.config.CustomUserDetails;  // WebSocket 인증 시 사용

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * WebSocket STOMP 메시지 인터셉터
 * 
 * 【 역할 】
 * - HTTP의 JwtAuthenticationFilter와 동일한 역할을 WebSocket에서 수행
 * - STOMP 메시지가 서버에 도착하기 전에 JWT 토큰 검증
 * - SecurityContext에 인증 정보 저장 → 컨트롤러에서 @AuthenticationPrincipal 사용 가능
 * 
 * 【 실행 시점 】
 * - 모든 STOMP 메시지 (CONNECT, SEND, SUBSCRIBE 등)가 서버에 도착하기 전
 * - configureClientInboundChannel()에 등록했기 때문에 클라이언트 → 서버 방향만 처리
 * 
 * 【 HTTP vs WebSocket 인증 비교 】
 * 
 * HTTP:
 *   .addFilterBefore(JwtAuthenticationFilter, ...)
 *   → Servlet Filter Chain
 *   → doFilterInternal() 실행
 *   
 * WebSocket:
 *   configureClientInboundChannel(JwtChannelInterceptor)
 *   → Spring Messaging Channel
 *   → preSend() 실행
 *   
 * 역할은 동일하지만 프로토콜이 다르니 구현 방식도 다름!
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class JwtChannelInterceptor implements ChannelInterceptor {

    private final JwtTokenProvider jwtTokenProvider;

    /**
     * STOMP 메시지가 서버로 전송되기 전에 실행되는 메서드
     * 
     * @param message STOMP 메시지 객체 (클라이언트가 보낸 원본)
     * @param channel 메시지가 전송될 채널
     * @return 처리된 메시지 (null 반환 시 메시지 차단)
     */
    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        // 1. STOMP 헤더 추출을 위해 StompHeaderAccessor로 래핑
        //    (원본 Message 객체는 헤더 접근이 불편하니까 래핑해서 사용)
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(message);
        
        // 2. STOMP 커맨드 타입 확인
        //    CONNECT, SEND, SUBSCRIBE, DISCONNECT 등
        StompCommand command = accessor.getCommand();
        
        // 3. CONNECT 커맨드 처리 (WebSocket 연결 시 최초 1회 실행)
        //    → 이때 JWT 토큰 검증하고 SecurityContext 설정
        if (StompCommand.CONNECT.equals(command)) {
            log.info("🔌 WebSocket CONNECT 요청 수신");
            
            // 3-1. Authorization 헤더에서 토큰 추출
            //      클라이언트: stompClient.connect({Authorization: 'Bearer xxx'}, ...)
            String bearerToken = accessor.getFirstNativeHeader("Authorization");
            
            // 3-2. 토큰 형식 검증 (Bearer 접두사 확인)
            if (bearerToken == null || !bearerToken.startsWith("Bearer ")) {
                log.warn("⚠️ WebSocket 연결 실패: Authorization 헤더 없음 또는 형식 오류");
                // null 반환 시 메시지 차단 → 연결 실패
                return null;
            }
            
            // 3-3. "Bearer " 접두사 제거 (실제 JWT만 추출)
            String token = bearerToken.substring(7);
            
            // 3-4. JWT 유효성 검증
            try {
                if (!jwtTokenProvider.validateToken(token)) {
                    log.warn("⚠️ WebSocket 연결 실패: 유효하지 않은 토큰");
                    return null;
                }
                
                // 3-5. 토큰에서 userIdx 추출
                Long userIdx = jwtTokenProvider.getuserIdx(token);
                log.info("✅ JWT 검증 성공 - userIdx: {}", userIdx);
                
                // 3-6. CustomUserDetails 생성 (Spring Security 인증 객체)
                //      CustomUserDetails는 userIdx와 authorities를 받는 생성자 사용
                CustomUserDetails userDetails = new CustomUserDetails(
                    userIdx, 
                    Collections.emptyList()  // authorities (권한 - 일단 빈 리스트)
                );
                
                // 3-7. Authentication 객체 생성
                //      (Spring Security가 인식할 수 있는 형태로 변환)
                Authentication authentication = new UsernamePasswordAuthenticationToken(
                    userDetails,                         // principal (인증된 사용자 정보)
                    null,                                // credentials (비밀번호 - JWT 방식이라 null)
                    userDetails.getAuthorities()         // authorities (CustomUserDetails의 권한 목록)
                );
                
                // 3-8. StompHeaderAccessor에 User 설정
                //      → 이렇게 설정하면 @MessageMapping에서 Principal로 접근 가능
                accessor.setUser(authentication);
                
                // 3-9. SecurityContextHolder에 인증 정보 저장
                //      → 이렇게 설정하면 @MessageMapping에서 @AuthenticationPrincipal로 접근 가능
                //      → HTTP의 JwtAuthenticationFilter와 동일한 역할!
                SecurityContextHolder.getContext().setAuthentication(authentication);
                
                log.info("🎉 WebSocket 연결 성공 - userIdx: {}", userIdx);
                
            } catch (Exception e) {
                log.error("⚠️ WebSocket 연결 실패: JWT 검증 중 오류 - {}", e.getMessage());
                return null;
            }
        }
        
        // 4. SUBSCRIBE 커맨드 처리 (구독 권한 체크)
        //    → 나중에 구현 (지금은 일단 통과)
        else if (StompCommand.SUBSCRIBE.equals(command)) {
            String destination = accessor.getDestination();
            log.info("📢 SUBSCRIBE 요청: {}", destination);
            
            // TODO: 구독 권한 체크
            // 예: /queue/match/{userIdx} → 본인 큐만 구독 가능
            // 예: /topic/room/{roomIdx} → 방 참여자만 구독 가능
            
            // 일단은 모든 구독 허용
        }
        
        // 5. SEND 커맨드 처리 (메시지 전송 권한 체크)
        //    → 나중에 구현 (지금은 일단 통과)
        else if (StompCommand.SEND.equals(command)) {
            String destination = accessor.getDestination();
            log.info("📤 SEND 요청: {}", destination);
            
            // TODO: 전송 권한 체크
            // 예: /app/chat/{roomIdx} → 방 참여자만 전송 가능
            
            // 일단은 모든 전송 허용
        }
        
        // 6. 메시지 반환 (정상 처리)
        //    → 다음 인터셉터 또는 @MessageMapping으로 전달
        return message;
    }
}


/*
====================================================================================================
🔥 핵심 개념 정리
====================================================================================================

【 ChannelInterceptor란? 】
- Spring Messaging의 인터셉터 (HTTP의 Filter와 유사)
- 메시지가 채널을 통과할 때 전처리/후처리 가능
- preSend(), postSend(), afterSendCompletion() 등의 메서드 제공

【 preSend() 실행 시점 】
클라이언트가 STOMP 메시지 전송
  ↓
WebSocket 연결 (ws://server/ws)
  ↓
STOMP 프레임 파싱
  ↓
🔥 preSend() 실행 ← 여기서 JWT 검증!
  ↓
@MessageMapping("/match/enter") 메서드 실행
  ↓
서버 응답 (messagingTemplate.convertAndSend)

【 SecurityContext 저장 목적 】
HTTP:
  @GetMapping("/api/user/me")
  public ResponseEntity<?> getMe(@AuthenticationPrincipal CustomUserDetails user) {
      Long userIdx = user.getUserIdx();  // ← SecurityContext에서 가져옴
  }

WebSocket:
  @MessageMapping("/match/enter")
  public void enterQueue(@AuthenticationPrincipal CustomUserDetails user, ...) {
      Long userIdx = user.getUserIdx();  // ← SecurityContext에서 가져옴
  }

→ 둘 다 SecurityContext에 인증 정보가 있어야 @AuthenticationPrincipal 사용 가능!

【 왜 accessor.setUser()와 SecurityContextHolder 둘 다 설정? 】
accessor.setUser(authentication):
  - STOMP 세션에 User 정보 저장
  - @MessageMapping의 Principal 파라미터로 접근 가능
  
SecurityContextHolder.getContext().setAuthentication(authentication):
  - Spring Security의 SecurityContext에 저장
  - @AuthenticationPrincipal로 접근 가능
  
→ 두 가지 방식 모두 지원하기 위해 둘 다 설정!

【 HTTP Filter vs WebSocket Interceptor 】

HTTP (JwtAuthenticationFilter):
  실행 대상: 모든 HTTP 요청 (GET, POST, PUT, DELETE)
  실행 메서드: doFilterInternal()
  객체: HttpServletRequest
  등록: .addFilterBefore()
  
WebSocket (JwtChannelInterceptor):
  실행 대상: 모든 STOMP 메시지 (CONNECT, SEND, SUBSCRIBE)
  실행 메서드: preSend()
  객체: Message<?>
  등록: configureClientInboundChannel()

====================================================================================================
*/

