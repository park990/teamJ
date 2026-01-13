package com.teamj.service.gathering_service;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.teamj.dto.gathering_dto.GatheringActionResponseDto;
import com.teamj.dto.gathering_dto.GatheringDetailDto;
import com.teamj.dto.gathering_dto.GatheringListDto;
import com.teamj.entity.doubleKey_entity.ParticipantId;
import com.teamj.entity.meet_entity.MeetRoom;
import com.teamj.entity.meet_entity.Participant;
import com.teamj.entity.users_entity.Users;
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

    // *** 모임 세부사항 조회 ***
    @Transactional(readOnly = true)
    public GatheringDetailDto getGatheringDetail(Long roomIdx, Long userIdx) {
        //모임 조회
        Optional<MeetRoom> meetRoomOptional = meetRoomRepository
            .findById(roomIdx);

        if (meetRoomOptional.isEmpty()) {
            throw new IllegalArgumentException(
                "존재하지 않는 모임입니다. roomIdx: " + roomIdx);
        }
        MeetRoom meetRoom = meetRoomOptional.get();

        // 참여자 수 조회
        int participantCount = participantRepository
            .countByRoom_RoomIdx(roomIdx);
        log.debug("현재 참가자 수: {}/{}", participantCount, meetRoom.getMax());

        // 현재 사용자의 참가 여부 확인
        boolean isParticipating = participantRepository
            .existsByRoom_RoomIdxAndUser_UsersIdx(roomIdx, userIdx);
        log.debug("사용자 참가 여부: {}", isParticipating);

        // 정원 초과 여부 계산
        boolean isFull = participantCount >= meetRoom.getMax();

        return GatheringDetailDto.builder()
            .roomIdx(meetRoom.getRoomIdx())
            .roomName(meetRoom.getRoomName())
            .roomType(meetRoom.getRoomType())
            .roomDesc(meetRoom.getRoomDesc())
            .roomImg(meetRoom.getRoomImg())
            .meetDate(meetRoom.getMeetDate())
            .meetPlace(meetRoom.getMeetPlace())
            .max(meetRoom.getMax())
            .participantCount(participantCount)
            .isFull(isFull)
            .isParticipating(isParticipating)
            .createdAt(meetRoom.getCreatedAt())
            .build();
    }

    // *** 모임 참가 ***
    @Transactional
    @CacheEvict(value = "participantCount", allEntries = true)
    public GatheringActionResponseDto joinGathering(Long roomIdx, Long userIdx) {
        // 모임 존재 확인
        Optional<MeetRoom> meetRoomOptional = meetRoomRepository.findById(roomIdx);

        if(meetRoomOptional.isEmpty()) {
            throw new IllegalArgumentException(
                "존재하지 않는 모임입니다. roomIdx: " + roomIdx);
        }
        MeetRoom meetRoom = meetRoomOptional.get();

        boolean alreadyParticipating = participantRepository.existsByRoom_RoomIdxAndUser_UsersIdx(roomIdx, userIdx);
        
        if(alreadyParticipating) {
            log.warn("이미 참가한 모임입니다 - roomIdx: {}, userIdx: {}", roomIdx, userIdx);
            throw new IllegalArgumentException(
                "이미 참가한 모임입니다.");
        }

        // 정원 초과 확인
        int currentCount = participantRepository.countByRoom_RoomIdx(roomIdx);
        if(currentCount >= meetRoom.getMax()) {
            log.warn("정원 초과 - 현재: {}, 최대: {}", currentCount, meetRoom.getMax());
            throw new IllegalArgumentException("모임 정원이 초과되었습니다.");
        }

        // 사용자 조회
        Optional<Users> userOptional = userRepository.findById(userIdx);
        if(userOptional.isEmpty()) {
            throw new IllegalArgumentException(
                "사용자를 찾을 수 없습니다. userIdx: " + userIdx
            );
        }
        // 사용자 꺼내기
        Users user = userOptional.get();

        // 복합키 생성
        ParticipantId participantId = new ParticipantId(roomIdx, userIdx);

        // Participant 빌드
        Participant participant = Participant.builder()
            .id(participantId)
            .room(meetRoom)
            .user(user)
            .usersRole("GUEST")
            .build();

        // 참여자 저장
        participantRepository.save(participant);

        // 업데이트된 정보 조회
        int newCount = participantRepository.countByRoom_RoomIdx(roomIdx);
        boolean isFull = newCount >= meetRoom.getMax();

        // 결과 반환
        log.info("모임 참가 완료 - roomIdx: {}, 참가자: {}/{}", roomIdx, newCount);
        return GatheringActionResponseDto.builder()
            .success(true)
            .message("모임에 참가되었습니다.")
            .participantCount(newCount)
            .isFull(isFull)
            .isParticipating(true)
            .build();
    }
}
