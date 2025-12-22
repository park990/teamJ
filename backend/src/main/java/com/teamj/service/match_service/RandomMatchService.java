package com.teamj.service.match_service;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
public class RandomMatchService {

    private final MatchQueueManager matchQueueManager;
    private final MeetRoomRepository meetRoomRepository;
    private final ParticipantRepository participantRepository;
    private final UserRepository userRepository;

    @Transactional
    public Optional<Long> enterQueue(Long userIdx) {

        Optional<Long> matchedUserIdx = matchQueueManager.tryMatch(userIdx, null);

        // 아직 매칭 안 됨
        if (matchedUserIdx.isEmpty()) {
            log.info("매칭 대기중 userIdx={}", userIdx);
            return Optional.empty();
        }

        Long partnerIdx = matchedUserIdx.get();

        // 1️⃣ 방 생성
        MeetRoom room = MeetRoom.builder()
            .roomName("랜덤채팅방")
            .roomType("RANDOM_1ON1")
            .createAt(LocalDateTime.now())
            .max(2)
            .build();

        meetRoomRepository.save(room);

        // 2️⃣ 유저 조회
        Users user1 = userRepository.findById(userIdx).get();
        Users user2 = userRepository.findById(partnerIdx).get();

        // 3️⃣ 참여자 생성
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

        log.info("매칭 완료 roomIdx={}, users=[{}, {}]",room.getRoomIdx(), userIdx, partnerIdx);

        return Optional.of(room.getRoomIdx());
    }
}