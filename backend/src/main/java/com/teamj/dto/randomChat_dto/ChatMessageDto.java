package com.teamj.dto.randomChat_dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * WebSocket 메시지 전송용 DTO
 * 
 * 【 역할 】
 * - 채팅 메시지를 WebSocket으로 브로드캐스트할 때 사용
 * - Users 테이블에서 최신 nickname, profileImgUrl 조회 후 포함
 * 
 * 【 확장성 】
 * - 나중에 MongoDB 저장 시 ChatMessage 엔티티 → DTO 변환 메서드 추가 가능
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageDto {
    
    /**
     * 채팅 메시지 고유 ID
     * - 임시: UUID 또는 타임스탬프 기반 생성
     * - 나중에 MongoDB 저장 시 _id 사용
     */
    private String chatIdx;
    
    /**
     * 채팅방 ID
     */
    private Long roomIdx;
    
    /**
     * 메시지 작성자 userIdx
     */
    private Long userIdx;
    
    /**
     * 메시지 작성자 닉네임 (Users 테이블에서 조회)
     * - 항상 최신 정보 반영
     */
    private String nickname;
    
    /**
     * 메시지 내용
     */
    private String content;
    
    /**
     * 이미지 URL (이미지 메시지인 경우)
     * - 나중에 이미지 전송 기능 추가 시 사용
     */
    private String imageUrl;
    
    /**
     * 메시지 타입
     * - "TEXT": 일반 텍스트 메시지
     * - "IMAGE": 이미지 메시지
     * - 나중에 확장 가능
     */
    private String type;
    
    /**
     * 메시지 작성 시간
     */
    private LocalDateTime createdAt;
    
    /**
     * 메시지 작성자 프로필 이미지 URL (Users 테이블에서 조회)
     * - 항상 최신 정보 반영
     * - Users.profileImgUrl 필드와 매핑
     */
    private String profileImgUrl;
}
