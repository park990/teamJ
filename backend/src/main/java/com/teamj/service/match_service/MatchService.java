package com.teamj.service.match_service;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import org.springframework.messaging.simp.SimpMessagingTemplate;

import com.teamj.dto.randomChat_dto.MatchCriteria;
import com.teamj.dto.randomChat_dto.MatchData;
import com.teamj.dto.randomChat_dto.WaitingUser;
import com.teamj.dto.response.WebSocketResponse;
import com.teamj.entity.doubleKey_entity.ParticipantId;
import com.teamj.entity.meet_entity.MeetRoom;
import com.teamj.entity.meet_entity.Participant;
import com.teamj.entity.users_entity.Users;
import com.teamj.repository.meet_repository.MeetRoomRepository;
import com.teamj.repository.meet_repository.ParticipantRepository;
import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class MatchService {

    private final MatchQueueManager queueManager;
    private final MeetRoomRepository roomRepository;
    private final ParticipantRepository participantRepository;
    private final UserRepository userRepository;
    private final SimpMessagingTemplate messagingTemplate;  // WebSocket 메시지 전송용

    @Transactional
    public WebSocketResponse<MatchData> enterQueue(Long userIdx, String genderOption) {
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

        if (matchedIdx.isEmpty()) {
            log.info("매칭 대기 중 userIdx={}, desiredGender={}", userIdx, genderOption);
            MatchData matchData = MatchData.waiting();
            return WebSocketResponse.success("MATCH", matchData);
        }

        // 5. 매칭 성공 → 방 생성
        Long partnerIdx = matchedIdx.get();
        Long roomIdx = createRoom(userIdx, partnerIdx);

        log.info("🎉 매칭 성공! user1={}, user2={}, roomIdx={}", userIdx, partnerIdx, roomIdx);

        // 6. 상대방(먼저 대기하던 사람)에게 매칭 완료 알림 전송
        //    partnerIdx가 먼저 대기하던 사람이고, userIdx가 나중에 들어온 사람
        MatchData partnerMatchData = MatchData.matched(roomIdx, userIdx);  // 상대방 입장에서는 내가 partner
        WebSocketResponse<MatchData> partnerResponse = WebSocketResponse.success("MATCH", partnerMatchData);
        messagingTemplate.convertAndSend("/queue/match/" + partnerIdx, partnerResponse);
        log.info("✅ 상대방에게 매칭 알림 전송 완료 - partnerIdx: {}", partnerIdx);

        // 7. 요청자에게 응답 (Controller에서 전송할 데이터)
        MatchData matchData = MatchData.matched(roomIdx, partnerIdx);
        return WebSocketResponse.success("MATCH", matchData);
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