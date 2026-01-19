package com.teamj.controller.gathering_control;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.teamj.config.CustomUserDetails;
import com.teamj.dto.gathering_dto.GatheringActionResponseDto;
import com.teamj.dto.gathering_dto.GatheringCreateRequestDto;
import com.teamj.dto.gathering_dto.GatheringDetailDto;
import com.teamj.dto.gathering_dto.GatheringListDto;
import com.teamj.dto.response.ApiResponse;
import com.teamj.service.gathering_service.GatheringService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/gathering")
@Slf4j
public class GatheringController {
    private final GatheringService gatheringService;

    // 핫한 모임 호출
    @GetMapping("/hotList")
    public ResponseEntity<?> getHotList() {
        List<GatheringListDto> list = gatheringService.getHotGatheringList();
        return ResponseEntity.ok(ApiResponse.success(list, "핫한 모임 목록 조회 성공"));
    }
    // 새로운 모임 목록
    @GetMapping("/newList")
    public ResponseEntity<?> getNewList() {
        List<GatheringListDto> list = gatheringService.getNewGatheringList();
        return ResponseEntity.ok(ApiResponse.success(list, "새로운 모임 목록 조회 성공"));
    }
    // 모임 상세 조회
    @GetMapping("/{roomIdx}")
    public ResponseEntity<?> getGatheringDetail(
        @PathVariable("roomIdx") Long roomIdx,
        @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        Long userIdx = userDetails.getUserIdx();
        GatheringDetailDto detail = gatheringService.getGatheringDetail(roomIdx, userIdx);
        return ResponseEntity.ok(ApiResponse.success(detail, "모임 상세 조회 성공"));
    }
    // 모임 참가
    @PostMapping("/{roomIdx}/join")
    public ResponseEntity<?> joinGathering(
        @PathVariable("roomIdx") Long roomIdx,
        @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        Long userIdx = userDetails.getUserIdx();
        GatheringActionResponseDto result = gatheringService.joinGathering(roomIdx, userIdx);
        return ResponseEntity.ok(ApiResponse.success(result, "모임 참가 성공"));
    }
    // 모임 나가기
    @PostMapping("{roomIdx}/leave")
    public ResponseEntity<?> leaveGathering(
        @PathVariable Long roomIdx,
        @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        Long userIdx = userDetails.getUserIdx();
        GatheringActionResponseDto result = gatheringService.leaveGathering(roomIdx, userIdx);
        return ResponseEntity.ok(ApiResponse.success(result, "모임 나가기 성공"));
    }

    // 모임(채팅방 X) 생성
    @PostMapping("/create")
    public ResponseEntity<?> createGathering(
        @RequestPart("data") GatheringCreateRequestDto request,
        @RequestPart(value = "image", required = false) MultipartFile image,
        @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        GatheringActionResponseDto result = gatheringService.createGathering(request, image, userDetails.getUserIdx());
        return ResponseEntity.ok(ApiResponse.success(result, "모임 생성 성공"));
    }
}
