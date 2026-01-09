package com.teamj.repository.meet_repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.teamj.entity.doubleKey_entity.ParticipantId;
import com.teamj.entity.meet_entity.Participant;

import io.lettuce.core.dynamic.annotation.Param;

public interface ParticipantRepository extends JpaRepository<Participant, ParticipantId>{
    // 이미 참가 중인지 체크
    boolean existsByRoom_RoomIdxAndUser_UsersIdx(Long roomIdx, Long userIdx);
    
    // 참여자 카운트
    int countByRoom_RoomIdx(Long roomIdx);

    // 여러 모임 참가자 수 한번에 조회
    // JQPL 사용
    @Query("SELECT p.room.roomIdx, COUNT(p) " +
            "FROM Participant p " +
            "WHERE p.room.roomIdx IN :roomIdxList " +
            "GROUP BY p.room.roomIdx")
    List<Object[]> countByRoomIdxList(@Param("roomIdxList") List<Long> roomIdxList);
    
    // 특정 참가자 정보 조회
    Optional<Participant> findByRoom_RoomIdxAndUser_UsersIdx(Long roomIdx, Long userIdx);
    
    // 특정 모임의 모든 참가자 조회
    List<Participant> findAllByRoom_RoomIdx(Long roomIdx);
    
    // 참가자 삭제
    void deleteByRoom_RoomIdxAndUser_UsersIdx(Long roomIdx, Long userIdx);
}