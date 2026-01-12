package com.teamj.service.gathering_service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.teamj.dto.gathering_dto.GatheringListDto;
import com.teamj.entity.meet_entity.MeetRoom;
import com.teamj.repository.meet_repository.MeetRoomRepository;
import com.teamj.repository.meet_repository.ParticipantRepository;
import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;
import com.teamj.util.S3Uploader;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
@Service
@RequiredArgsConstructor
@Slf4j
public class GatheringService {
    // UserRepository 주입
    private final UserRepository userRepository;

    // ParticipantRepository 주입
    private final ParticipantRepository participantRepository;
    // S3 Uploader 주입(모임 생성시 필요)
    private final S3Uploader s3Uploader;
    // repository 연결
    private final MeetRoomRepository meetRoomRepository;

@Cacheable(
    value = "participantCount", // 캐시 이름
    key = "#roomIdxList.toString()", // [1,2,3,4,5] 형태
    unless = "#result == null || #result.isEmpty()" // 빈 결과는 캐싱 안함
)
public Map<Long, Integer> getParticipantCountMap(List<Long> roomIdxList) {
    // 빈 리스트 체크
    if(roomIdxList == null || roomIdxList.isEmpty()) {
        log.warn("빈 roomIdxList 요청");
        return Map.of();
    }

    // 캐시 미스 로그
    log.debug("캐시 미스 발생 - DB 조회 시작");
    log.debug("조회 대상 모임: {}", roomIdxList);

    // DB 조회 (JPQL)
    long startTime = System.currentTimeMillis();
    List<Object[]> results = participantRepository.countByRoomIdxList(roomIdxList);
    long endTime = System.currentTimeMillis();

    log.debug("DB 조회 완료 - 소요시간: {}ms, 결과 개수: {}",
                endTime - startTime, results.size());
    // Map 변환
    Map<Long, Integer> countMap = results.stream()
        .collect(Collectors.toMap(
            row -> (Long) row[0], //roomIdx
            row -> ((Long) row[1]).intValue() //count (Long -> int 변환)
        ));
    log.debug("변환된 Map: {}", countMap);

    return countMap;

}

    // 모임 생성 시 이미지를 업로드 및 URL을 DB에 저장하는 로직
    //todo: 로직 추가

    // 목록 조회 시 DB에서 URL을 꺼내 DTO에 담기
    // 핫한 모임 목록 조회(이미지)
    @Transactional(readOnly = true)
    public List<GatheringListDto> getHotGatheringHotList() {
        // DB에서 핫한 모임 조회(RANDOM_1ON1 모임 제외)
        List<MeetRoom> entities = meetRoomRepository.findTop5ByRoomTypeNotOrderByCreatedAtDesc("RANDOM_1ON1");

        // 모든 roomIdx 추출
        List<Long> roomIdxList = entities.stream()
            .map(MeetRoom::getRoomIdx)
            .collect(Collectors.toList());
        // 엔티티 -> DTO 변환
        // 이때 DB에 저장된 URL을 그대로 DTO에 넣어줌
        return entities.stream()
                .map(meetRoom -> GatheringListDto.builder()
                    .roomIdx(meetRoom.getRoomIdx())
                    .roomName(meetRoom.getRoomName())
                    .roomType(meetRoom.getRoomType())
                    .createdAt(meetRoom.getCreatedAt())
                    .meetDate(meetRoom.getMeetDate())
                    .max(meetRoom.getMax())
                    .roomImg(meetRoom.getRoomImg())
                    .roomDesc(meetRoom.getRoomDesc())
                    .build())
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<GatheringListDto> getNewGatheringList() {
        // DB 조회
        List<MeetRoom> newList = meetRoomRepository.findAllByOrderByCreatedAtDesc();

        // Entity -> DTO 변환
        return newList.stream()
                .map(meetRoom -> GatheringListDto.builder()
                    .roomIdx(meetRoom.getRoomIdx())
                    .roomName(meetRoom.getRoomName())
                    .roomType(meetRoom.getRoomType())
                    .createdAt(meetRoom.getCreatedAt())
                    .meetDate(meetRoom.getMeetDate())
                    .max(meetRoom.getMax())
                    .roomImg(meetRoom.getRoomImg())
                    .roomDesc(meetRoom.getRoomDesc())
                    .build())
                .collect(Collectors.toList());
    }

    private GatheringListDto buildGatheringListDto(
        MeetRoom meetRoom,
        Map<Long, Integer> participantCountMap
    ) {
        int participantCount = participantCountMap.getOrDefault(
            meetRoom.getRoomIdx(),
            0
        );

        return GatheringListDto.builder()
            .roomIdx(meetRoom.getRoomIdx())
            .roomName(meetRoom.getRoomName())
            .roomType(meetRoom.getRoomType())
            .createdAt(meetRoom.getCreatedAt())
            .meetDate(meetRoom.getMeetDate())
            .meetPlace(meetRoom.getMeetPlace())
            .max(meetRoom.getMax())
            .roomImg(meetRoom.getRoomImg())
            .roomDesc(meetRoom.getRoomDesc())
            .participantCount(participantCount)
            .isFull(participantCount >= meetRoom.getMax())
            .build();
    }

    // @Transactional(readOnly = true)
    // public GatheringListDto getGatheringDetail(Long roomIdx, Long userIdx) {
    //     meetRoomRepository.findById(roomIdx)
    //         .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 모임입니다."));
    //     participantRepository.countByRoom_RoomIdx(roomIdx);
        
    // }
}
