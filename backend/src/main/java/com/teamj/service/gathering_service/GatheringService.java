package com.teamj.service.gathering_service;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import com.teamj.dto.response.ApiResponse;
import com.teamj.entity.meet_entity.MeetRoom;
import com.teamj.repository.meet_repository.MeetRoomRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class GatheringService {
    // repository 연결
    private final MeetRoomRepository meetRoomRepository;
    
    // 핫한 모임(top5) 가져오기
    public ResponseEntity<?> getHotGatheringList() {
        List<MeetRoom> hotList = meetRoomRepository.findTop5ByOrderByCreatedAtDesc();
        return ResponseEntity
            .ok(ApiResponse
                .success(hotList, "핫한 모임 목록 조회 성공"));
    }

    // 새로운 모임 목록 가져오기
    public ResponseEntity<?> getNewGatheringList() {
        List<MeetRoom> newList = meetRoomRepository.findAllByOrderByCreatedAtDesc();
        return ResponseEntity
            .ok(ApiResponse
                .success(newList, "새로운 모임 목록 조회 성공"));
    }
}
