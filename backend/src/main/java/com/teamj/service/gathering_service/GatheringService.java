package com.teamj.service.gathering_service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.teamj.dto.gathering_dto.GatheringActionResponseDto;
import com.teamj.dto.gathering_dto.GatheringCreateRequestDto;
import com.teamj.dto.gathering_dto.GatheringDetailDto;
import com.teamj.dto.gathering_dto.GatheringListDto;
import com.teamj.entity.doubleKey_entity.ParticipantId;
import com.teamj.entity.meet_entity.MeetRoom;
import com.teamj.entity.meet_entity.Participant;
import com.teamj.entity.users_entity.Users;
import com.teamj.enums.ParticipantRole;
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

// 캐시 저장
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

    /**
     * 핫한 모임 목록 조회 (최신 5개)
     * todo: 핫한 모임 기준 잡기 - 활발히 활동하는 모임을 어떻게 판단할지?
     */
    @Transactional(readOnly = true)
    public List<GatheringListDto> getHotGatheringList() {
        // 1. 모임 목록 조회 (랜덤채팅 제외)
        List<MeetRoom> entities = meetRoomRepository
            .findTop5ByRoomTypeNotOrderByCreatedAtDesc("RANDOM_1ON1");

        // 2. roomIdx 추출 → 참여자 수 일괄 조회용
        List<Long> roomIdxList = entities.stream()
            .map(MeetRoom::getRoomIdx)
            .collect(Collectors.toList());

        // 3. 참여자 수 Map 조회 (DB 쿼리 1번으로 전체 조회)
        Map<Long, Integer> countMap = getParticipantCountMap(roomIdxList);

        // 4. Entity → DTO 변환
        return entities.stream()
                .map(meetRoom -> buildGatheringListDto(meetRoom, countMap))
                .collect(Collectors.toList());
    }

    /**
     * 새로운 모임 목록 조회 (전체, 최신순)
     */
    @Transactional(readOnly = true)
    public List<GatheringListDto> getNewGatheringList() {
        // 1. 모임 목록 조회 (랜덤채팅 제외)
        List<MeetRoom> newList = meetRoomRepository
            .findAllByRoomTypeNotOrderByCreatedAtDesc("RANDOM_1ON1");

        // 2. roomIdx 추출 → 참여자 수 일괄 조회용
        List<Long> roomIdxList = newList.stream()
            .map(MeetRoom::getRoomIdx)
            .collect(Collectors.toList());

        // 3. 참여자 수 Map 조회 (DB 쿼리 1번으로 전체 조회)
        Map<Long, Integer> countMap = getParticipantCountMap(roomIdxList);

        // 4. Entity → DTO 변환
        return newList.stream()
                .map(meetRoom -> buildGatheringListDto(meetRoom, countMap))
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
        MeetRoom meetRoom = findMeetRoomOrThrow(roomIdx);

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
        MeetRoom meetRoom = findMeetRoomOrThrow(roomIdx);

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
        Users user = findUserOrThrow(userIdx);

        // 복합키 생성
        ParticipantId participantId = new ParticipantId(roomIdx, userIdx);

        // Participant 빌드
        Participant participant = Participant.builder()
            .id(participantId)
            .room(meetRoom)
            .user(user)
            .usersRole(ParticipantRole.GUEST.getValue())
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

    // *** 모임 나가기 ***
    @Transactional
    @CacheEvict(value = "participantCount", allEntries = true)
    public GatheringActionResponseDto leaveGathering(Long roomIdx, Long userIdx) {
        // 모임 존재 확인
        MeetRoom meetRoom = findMeetRoomOrThrow(roomIdx);

        // 복합키로 참여자 조회
        ParticipantId participantId = new ParticipantId(roomIdx, userIdx);
        Optional<Participant> participantOptional = participantRepository.findById(participantId);

        if(participantOptional.isEmpty()) {
            log.warn("참가하지 않은 모임입니다 - roomIdx: {}, userIdx: {}", roomIdx, userIdx);
            throw new IllegalArgumentException(
                "참가하지 않은 모임입니다."
            );
        }

        Participant participant = participantOptional.get();

        // HOST 검증 - 방장은 나갈 수 없음 (모임/채팅방 삭제만 가능)
        if(ParticipantRole.HOST.getValue().equals(participant.getUsersRole())) {
            log.warn("HOST는 나가기 불가 - roomIdx: {}, userIdx: {}", roomIdx, userIdx);
            throw new IllegalArgumentException(
                "방장은 모임을 나갈 수 없습니다. 모임을 삭제해주세요."
            );
        }

        // 참여자 삭제 (GUEST만 가능)
        participantRepository.delete(participant);
        log.info("참가자 삭제 완료 - roomIdx: {}, userIdx: {}", roomIdx, userIdx);

        // 업데이트된 정보 조회
        int newCount = participantRepository.countByRoom_RoomIdx(roomIdx);
        boolean isFull = newCount >= meetRoom.getMax();

        // 결과 반환
        log.info("모임 나가기 완료 - roomIdx: {}, 남은 참가자: {}/{}", roomIdx, newCount, meetRoom.getMax());
        return GatheringActionResponseDto.builder()
            .success(true)
            .message("모임에서 나갔습니다.")
            .participantCount(newCount)
            .isFull(isFull)
            .isParticipating(false)
            .build();
    }

    // *** 모임 생성 ***
    @Transactional
    // 캐시 삭제 - 참여자 변경 시
    @CacheEvict(value = "participantCount", allEntries = true)
    public GatheringActionResponseDto createGathering(
        GatheringCreateRequestDto request,
        MultipartFile image,
        Long userIdx
    ) {
        
        // 사용자 검증
        Users user = findUserOrThrow(userIdx);
        // 이미지 업로드
        String imageUrl = null;
        if(image != null && !image.isEmpty()) {
            imageUrl = s3Uploader.upload(image, imageUrl);
        }
        // MeetRoom 생성 및 저장
        MeetRoom meetRoom = MeetRoom.builder()
            .roomName(request.getRoomName())
            .roomType(request.getRoomType())
            .roomDesc(request.getRoomDesc())
            .meetDate(request.getMeetDate())
            .meetPlace(request.getMeetPlace())
            .max(request.getMax())
            .roomImg(imageUrl)
            .createdAt(LocalDateTime.now())
            .build();
        MeetRoom savedRoom = meetRoomRepository.save(meetRoom);

        // 모임 생성자를 HOST로 저장
        ParticipantId participantId = new ParticipantId(
            savedRoom.getRoomIdx(),
            userIdx
        );
        Participant participant = Participant.builder()
            .id(participantId)
            .room(savedRoom)
            .user(user)
            .usersRole(ParticipantRole.HOST.getValue())
            .build();
        
        participantRepository.save(participant);
        // 결과 반환
        return GatheringActionResponseDto.builder()
            .success(true)
            .message("모임이 생성되었습니다.")
            .participantCount(1) // 생성자 1명
            .isFull(false)
            .isParticipating(true)
            .build();
    }

    /**
    * 모임 조회 헬퍼 - 없으면 예외 발생
    * (Helper Method: 반복되는 조회+예외처리를 한 곳에서 관리)
    */
    private MeetRoom findMeetRoomOrThrow(Long roomIdx) {
        return meetRoomRepository.findById(roomIdx)
            .orElseThrow(() -> new IllegalArgumentException(
                "존재하지 않는 모임입니다. roomIdx: " + roomIdx
            )
        );
    }

    /**
    * 사용자 조회 헬퍼 - 없으면 예외 발생
    * (Helper Method: 반복되는 조회+예외처리를 한 곳에서 관리)
    */
    private Users findUserOrThrow(Long userIdx) {
        return userRepository.findById(userIdx)
            .orElseThrow(() -> new IllegalArgumentException(
                "존재하지 않는 사용자입니다. userIdx: " + userIdx
            )
        );
    }
}
