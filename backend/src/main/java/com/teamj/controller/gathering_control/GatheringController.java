package com.teamj.controller.gathering_control;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.teamj.service.gathering_service.GatheringService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
        return gatheringService.getHotGatheringList();
    }
    // 새로운 모임 목록
    @GetMapping("/newList")
    public ResponseEntity<?> getNewList() {
        return gatheringService.getNewGatheringList();
    }
    
}
