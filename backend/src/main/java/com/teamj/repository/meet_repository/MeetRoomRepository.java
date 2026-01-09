package com.teamj.repository.meet_repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.teamj.entity.meet_entity.MeetRoom;

public interface MeetRoomRepository extends JpaRepository<MeetRoom, Long>{
    // 핫한 모임(5개)
    //List<MeetRoom> findTop5ByOrderByCreatedAtDesc();
    // 핫한 모임(RANDOM_1ON1 모임 제외)
    List<MeetRoom> findTop5ByRoomTypeNotOrderByCreatedAtDesc(String roomType);
    // 최신 모임(전부)
    List<MeetRoom> findAllByOrderByCreatedAtDesc();
}
