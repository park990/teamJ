package com.teamj.service.randomChat_service;

import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.teamj.dto.randomChat_dto.RandomMatchResponse;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RandomMatchService {

    private final MatchQueueManager matchQueueManager;
    private final MeetRoomRepository meetRoomRepository;

    @Transactional
    public RandomMatchResponse enterQueue(Long userIdx, String genderOption) {

        // 1️⃣ 큐에 넣기
        Optional<Long> matchedUserIdx =
            matchQueueManager.tryMatch(userIdx, genderOption);

        // 2️⃣ 아직 매칭 안 됨
        if (matchedUserIdx.isEmpty()) {
            return new RandomMatchResponse(false, null);
        }

        // 3️⃣ 매칭 성공 → 채팅방 생성
        MeetRoom room = new MeetRoom();
        room.setUserA(userIdx);
        room.setUserB(matchedUserIdx.get());

        MeetRoom saved = meetRoomRepository.save(room);

        return new RandomMatchResponse(true, saved.getRoomIdx());
    }
}