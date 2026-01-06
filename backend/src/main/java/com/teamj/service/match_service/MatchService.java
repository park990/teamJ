package com.teamj.service.match_service;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.teamj.dto.randomChat_dto.MatchCriteria;
import com.teamj.dto.randomChat_dto.MatchData;
import com.teamj.dto.randomChat_dto.MatchPair;
import com.teamj.dto.randomChat_dto.WaitingUser;
import com.teamj.entity.doubleKey_entity.ParticipantId;
import com.teamj.entity.meet_entity.MeetRoom;
import com.teamj.entity.meet_entity.Participant;
import com.teamj.entity.users_entity.Users;
import com.teamj.repository.meet_repository.MeetRoomRepository;
import com.teamj.repository.meet_repository.ParticipantRepository;
import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * 매칭 서비스 (비즈니스 로직 담당)
 * 
 * 【 역할 】
 * - 매칭 큐 관리
 * - 매칭 알고리즘 실행
 * - 방 생성 및 DB 저장
 * - MatchPair 반환 (두 사용자의 MatchData)
 * 
 * 【 책임 분리 】
 * Service:    비즈니스 로직만 (MatchPair 반환)
 * Controller: 통신 담당 (MatchPair 받아서 각각 전송)
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class MatchService {

    private final MatchQueueManager queueManager;
    private final MeetRoomRepository roomRepository;
    private final ParticipantRepository participantRepository;
    private final UserRepository userRepository;
    // SimpMessagingTemplate 제거 (통신은 Controller가 담당)

    /**
     * 매칭 대기열 진입 (비즈니스 로직만)
     * 
     * @param userIdx 매칭 요청 사용자 ID
     * @param genderOption 희망 성별 ("male" | "female" | "random")
     * @return MatchPair (요청자용, 상대방용 MatchData 포함)
     */
    @Transactional
    public MatchPair enterQueue(Long userIdx, String genderOption) {
        // 1. 유저 정보 조회
        Users user = userRepository.findById(userIdx)
            .orElseThrow(() -> new RuntimeException("User not found: " + userIdx));

        // 2. 매칭조건 생성
        MatchCriteria criteria = MatchCriteria.builder()
            .desiredGender(genderOption)
            .build();

        // 3. WaitingUser 생성
        WaitingUser waitingUser = new WaitingUser(
            userIdx,
            user.getUsersGender(),
            criteria
        );

        // 4. 매칭 시도
        Optional<Long> matchedIdx = queueManager.tryMatch(waitingUser);

        // 5-1. 대기 중 (매칭 상대 없음)
        if (matchedIdx.isEmpty()) {
            log.info("⏳ 매칭 대기 중 - userIdx: {}, desiredGender: {}", userIdx, genderOption);
            
            // 요청자용 MatchData만 생성 (대기 중)
            MatchData requesterData = MatchData.waiting();
            
            // MatchPair 반환 (상대방 없음)
            return MatchPair.waiting(requesterData);
        }

        // 5-2. 매칭 성공 → 방 생성
        Long partnerIdx = matchedIdx.get();
        Long roomIdx = createRoom(userIdx, partnerIdx);

        log.info("🎉 매칭 성공! requestUser: {}, partner: {}, roomIdx: {}", 
                 userIdx, partnerIdx, roomIdx);

        // 6. 양쪽 MatchData 생성
        
        // 요청자 입장: 나는 userIdx, 상대는 partnerIdx
        MatchData requesterData = MatchData.matched(roomIdx, partnerIdx);
        
        // 상대방 입장: 나는 partnerIdx, 상대는 userIdx
        MatchData partnerData = MatchData.matched(roomIdx, userIdx);
        
        // 7. MatchPair로 묶어서 반환 (Controller가 각각 전송!)
        return MatchPair.matched(requesterData, partnerData);
    }

    private Long createRoom(Long userIdx1, Long userIdx2) {
        Users user1 = userRepository.findById(userIdx1).orElseThrow();
        Users user2 = userRepository.findById(userIdx2).orElseThrow();

        MeetRoom room = MeetRoom.builder()
            .roomName("랜덤채팅방")
            .roomType("RANDOM_1ON1")
            .createdAt(LocalDateTime.now())
            .max(2)
            .build();

        roomRepository.save(room); // 이때 roomIdx 생성

        Participant p1 = Participant.builder()
            .id(new ParticipantId(room.getRoomIdx(), user1.getUsersIdx()))
            .room(room)
            .user(user1)
            .usersRole("HOST")
            .build();

        Participant p2 = Participant.builder()
            .id(new ParticipantId(room.getRoomIdx(), user2.getUsersIdx()))
            .room(room)
            .user(user2)
            .usersRole("GUEST")
            .build();

        participantRepository.save(p1);
        participantRepository.save(p2);

        log.info("매칭 완료 roomIdx={}, users=[{}, {}]", room.getRoomIdx(), userIdx1, userIdx2);
        return room.getRoomIdx();
    }
}