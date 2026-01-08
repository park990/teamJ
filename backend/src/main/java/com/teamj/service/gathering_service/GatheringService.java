package com.teamj.service.gathering_service;

import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.teamj.dto.gathering_dto.GatheringListDto;
import com.teamj.entity.meet_entity.MeetRoom;
import com.teamj.repository.meet_repository.MeetRoomRepository;
import com.teamj.util.S3Uploader;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
@Service
@RequiredArgsConstructor
@Slf4j
public class GatheringService {

    // S3 Uploader 주입(모임 생성시 필요)
    private final S3Uploader s3Uploader;
    // repository 연결
    private final MeetRoomRepository meetRoomRepository;

    // 모임 생성 시 이미지를 업로드 및 URL을 DB에 저장하는 로직
    //todo: 로직 추가

    // 목록 조회 시 DB에서 URL을 꺼내 DTO에 담기
    // 핫한 모임 목록 조회(이미지)
    @Transactional(readOnly = true)
    public List<GatheringListDto> getHotGatheringHotList() {
        // DB에서 핫한 모임 조건으로 조회(내림차순)
        List<MeetRoom> entities = meetRoomRepository.findTop5ByOrderByCreatedAtDesc();

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
}
