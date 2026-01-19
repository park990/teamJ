package com.teamj.service.chat_service;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.stereotype.Service;
// import org.springframework.transaction.annotation.Transactional;  // 나중에 MongoDB 저장 시 활성화

import com.teamj.dto.randomChat_dto.ChatMessageDto;
import com.teamj.entity.users_entity.Users;
import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * 채팅 서비스 (비즈니스 로직 담당)
 * 
 * 【 역할 】
 * - 채팅 메시지 처리 (Users 정보 조회, chatIdx 생성)
 * - ChatMessageDto 생성 및 반환
 * - 나중에 MongoDB 저장 로직 추가 예정
 * 
 * 【 책임 분리 】
 * Service:    비즈니스 로직만 (ChatMessageDto 반환)
 * Controller: 통신 담당 (ChatMessageDto 받아서 브로드캐스트)
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ChatService {

    private final UserRepository userRepository;
    // 나중에 MongoDB 저장 시 ChatMessageRepository 주입 예정

    /**
     * 메시지 전송 (비즈니스 로직만)
     * - Users 정보 조회 (nickname, profileImgUrl)
     * - chatIdx 생성 (UUID)
     * - ChatMessageDto 생성 및 반환
     * 
     * 【 확장성 】
     * - 나중에 MongoDB 저장 로직 추가 시 @Transactional 활성화
     * - 나중에 이미지 메시지 타입 추가 가능
     * 
     * @param roomIdx 채팅방 ID
     * @param userIdx 메시지 작성자 ID
     * @param content 메시지 내용
     * @return ChatMessageDto (브로드캐스트용)
     */
    // @Transactional  // 나중에 MongoDB 저장 시 활성화
    public ChatMessageDto sendMessage(Long roomIdx, Long userIdx, String content) {
        // 1. Users 정보 조회 (nickname, profileImgUrl)
        Users user = userRepository.findById(userIdx)
            .orElseThrow(() -> new RuntimeException("User not found: " + userIdx));
        
        log.debug("💬 메시지 전송 처리 - roomIdx: {}, userIdx: {}, nickname: {}", 
                roomIdx, userIdx, user.getUsersNickname());
        
        // 2. chatIdx 생성 (UUID)
        //    - 임시: UUID 사용
        //    - 나중에 MongoDB 저장 시 _id 사용
        String chatIdx = UUID.randomUUID().toString();
        
        // 3. ChatMessageDto 생성 및 반환
        ChatMessageDto chatMessageDto = ChatMessageDto.builder()
            .chatIdx(chatIdx)
            .roomIdx(roomIdx)
            .userIdx(userIdx)
            .nickname(user.getUsersNickname())
            .content(content)
            .imageUrl(null)  // 나중에 이미지 메시지 기능 추가 시 사용
            .type("TEXT")  // 기본값: 텍스트 메시지
            .createdAt(LocalDateTime.now())
            .profileImgUrl(user.getProfileImgUrl())  // Users 엔티티 필드명과 일치
            .build();
        
        log.debug("✅ ChatMessageDto 생성 완료 - chatIdx: {}, nickname: {}", 
                chatIdx, user.getUsersNickname());
        
        return chatMessageDto;
        
        // 나중에 MongoDB 저장 로직 추가 예정:
        // ChatMessage chatMessage = ChatMessage.builder()
        //     ._id(chatIdx)
        //     .roomIdx(roomIdx)
        //     .userIdx(userIdx)
        //     .content(content)
        //     .type("TEXT")
        //     .createdAt(LocalDateTime.now())
        //     .build();
        // chatMessageRepository.save(chatMessage);
    }
}
