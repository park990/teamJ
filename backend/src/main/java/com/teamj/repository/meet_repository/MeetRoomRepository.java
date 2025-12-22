package com.teamj.repository.meet_repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.teamj.entity.meet_entity.MeetRoom;

public interface MeetRoomRepository extends JpaRepository<MeetRoom, Long>{
    
}
