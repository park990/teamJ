package com.teamj.controller.gathering_control;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.teamj.dto.gathering_dto.GatheringListDto;
import com.teamj.dto.response.ApiResponse;
import com.teamj.service.gathering_service.GatheringService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/gathering")
@Slf4j
public class GatheringController {
    private final GatheringService gatheringService;

    // 핫한 모임 호출
    @GetMapping("/hotList")
    public ResponseEntity<?> getHotList() {
        List<GatheringListDto> list = gatheringService.getHotGatheringHotList();
        //return gatheringService.getHotGatheringList();
        return ResponseEntity.ok(ApiResponse.success(list, "핫한 모임 목록 조회 성공"));
    }
    // 새로운 모임 목록
    @GetMapping("/newList")
    public ResponseEntity<?> getNewList() {
        List<GatheringListDto> list = gatheringService.getNewGatheringList();
        return ResponseEntity.ok(ApiResponse.success(list, "새로운 모임 목록 조회 성공"));
    }
    
}
