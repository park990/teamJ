package com.teamj.repository.meet_repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.teamj.entity.doubleKey_entity.ParticipantId;
import com.teamj.entity.meet_entity.Participant;

public interface ParticipantRepository extends JpaRepository<Participant, ParticipantId>{
    // 이미 참가 중인지 체크
    boolean existsByRoom_RoomIdxAndUser_UsersIdx(Long roomIdx, Long userIdx);
}