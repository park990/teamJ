package com.teamj.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker  // ← WebSocket 메시지 브로커 활성화
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    // 1. registerStompEndpoints - 클라이언트가 WebSocket 연결을 시도하는 주소를 임의로 등록하는 부분 
    // -> 처음 웹소켓을 연결할 때 사용하는 요청

    /*
    .addEndpoint("/ws/matching")
        클라이언트가 연결하는 주소설정
        예: ws://서버주소/ws/matching
    .setAllowedOriginPatterns("*")
        CORS: 어떤 도메인에서 접근 허용할지
        "*"는 모든 도메인 허용 (개발용)
        운영에서는 특정 도메인 지정: .setAllowedOriginPatterns("https://yourdomain.com")
    .withSockJS()
        브라우저 호환성 지원
        일부 브라우저에서 WebSocket을 못 쓰는 경우 대비 
    */
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws")  // ← 이 주소로 연결 시도
            .setAllowedOriginPatterns("*")     // ← CORS 설정
            .withSockJS();                     // ← 브라우저 호환성
    }
    
    // 2. configureMessageBroker - 메시지 브로커 설정 - 메시지를 어디로 보낼지 경로를 설정하는 부분
    // -> 연결 성공 후 서버와 클라이언트간 메시지를 보낼 때 사용하는 경로 prefix를 임의로 설정하는 부분
    /*
    registry.enableSimpleBroker("/topic", "/queue")
        서버 -> 클라이언트에게 메시지를 보낼 때 사용하는 경로 prefix
        /topic: 여러 클라이언트에게 브로드캐스트 (단체 채팅 등)
        /queue: 특정 클라이언트에게 1:1 전송 (개인 알림)
        매칭 알림은 개인 알림이니까 /queue 사용
    registry.setApplicationDestinationPrefixes("/app")
        클라이언트 -> 서버로 메시지를 보낼 때 사용하는 경로 prefix
        컨트롤러의 @MessageMapping("/match/enter")는 실제로는 /app/match/enter로 연결됨
    */
    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // 1. 서버 → 클라이언트 메시지 경로
        registry.enableSimpleBroker("/topic", "/queue");
        
        // 2. 클라이언트 → 서버 메시지 경로
        registry.setApplicationDestinationPrefixes("/app");
    }

}


/*
====================================================================================================
🔥 WebSocket 메시지 흐름 개념 정리
====================================================================================================

【 브로커 (Broker)란? 】
- 메시지 중개인 역할
- 서버가 여러 클라이언트에게 메시지를 전달할 때 경로 기반으로 라우팅
- Simple Broker: Spring Boot에 내장된 간단한 브로커 (별도 서버 설치 불필요)
- enableSimpleBroker("/topic", "/queue"): 브로커를 활성화하고 경로 prefix 설정

【 SEND (클라이언트 → 서버) 】
- 클라이언트가 서버의 특정 메서드를 실행시키기 위해 메시지 전송
- 브로커를 거치지 않음!
- 경로: /app/... (setApplicationDestinationPrefixes 설정)

예시:
    클라이언트: stompClient.send('/app/match/enter', {}, {genderOption: 'female'})
    ↓ (브로커 안 거침, 직접 서버로)
    서버: @MessageMapping("/match/enter") 메서드 실행
    
영향 범위: 클라이언트 → 서버 메서드 (여기까지만!)

【 PUBLISH (서버 → 브로커 → 여러 클라이언트) 】
- 서버가 여러 클라이언트에게 메시지를 전달하기 위해 브로커에 발행
- 브로커를 거쳐서 구독한 클라이언트들에게 전달
- 경로: /topic/... 또는 /queue/... (enableSimpleBroker 설정)
- Spring에서는 messagingTemplate.convertAndSend() 메서드 사용

예시:
    서버: messagingTemplate.convertAndSend("/topic/room/456", message)
    ↓ (브로커에 publish)
    브로커: '/topic/room/456'를 구독한 클라이언트들 찾기
    ↓ (브로커가 전달)
    클라이언트들: subscribe('/topic/room/456', callback) 콜백 실행
    
영향 범위: 서버 → 브로커 → 구독한 모든 클라이언트

【 SUBSCRIBE (클라이언트가 메시지 받기 등록) 】
- 클라이언트가 특정 경로의 메시지를 받겠다고 미리 등록
- 서버가 그 경로로 메시지를 보내면(publish) 자동으로 받음
- 경로: /topic/... 또는 /queue/... (enableSimpleBroker 설정)

예시:
    클라이언트: stompClient.subscribe('/queue/match/123', function(message) { ... })
    → "/queue/match/123" 경로로 오는 메시지를 받겠다고 등록
    → 서버가 convertAndSend("/queue/match/123", data) 하면
    → 등록한 콜백 함수가 자동 실행됨

【 전체 흐름 예시: 채팅 시스템 】

1. 연결 (한 번만)
    클라이언트: WebSocket 연결 (ws://서버/ws/matching)

2. 메시지 받을 준비 (subscribe)
    클라이언트A: subscribe('/topic/room/456', callback)
    클라이언트B: subscribe('/topic/room/456', callback)

3. 메시지 보내기 (send)
    클라이언트A: send('/app/chat/456', {message: "안녕"})
    ↓ (브로커 안 거침)
    서버: @MessageMapping("/chat/{roomIdx}") 실행

4. 서버가 브로드캐스트 (publish)
    서버: messagingTemplate.convertAndSend("/topic/room/456", message)
    ↓ (브로커에 publish)
    브로커: '/topic/room/456' 구독한 클라이언트 찾기 (A, B)
    ↓ (브로커가 전달)
    클라이언트A, B: subscribe 콜백 실행 (둘 다 메시지 받음)

【 정리 】
- send: 클라이언트 → 서버 (브로커 안 거침, 서버 메서드 실행 목적)
- subscribe: 클라이언트가 메시지 받기 등록 (나중에 메시지 받을 준비)
- publish: 서버 → 브로커 → 여러 클라이언트 (브로드캐스트)
- 브로커: 메시지 중개인 (경로 기반 라우팅)
====================================================================================================
*/