package com.teamj.controller.randomChat_control;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.teamj.dto.randomChat_dto.RandomMatchRequest;
import com.teamj.dto.randomChat_dto.RandomMatchResponse;
import com.teamj.response.ApiResponse;
import com.teamj.service.randomChat_service.RandomMatchService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/random-match")
@RequiredArgsConstructor
public class RandomMatchController {

    private final RandomMatchService randomMatchService;

    @PostMapping("/enter")
    public ApiResponse<RandomMatchResponse> enterQueue(
        @AuthenticationPrincipal UserDetails userDetails,
        @RequestBody RandomMatchRequest request
    ) {
        // 🔑 JWT에서 나온 userIdx
        Long userIdx = Long.parseLong(userDetails.getUsername());

        RandomMatchResponse response =
            randomMatchService.enterQueue(userIdx, request.getGenderOption());

        return ApiResponse.success(response, "매칭 요청 성공");
    }

    @PostMapping("/cancel")
    public ApiResponse<Void> cancelQueue(
        @AuthenticationPrincipal UserDetails userDetails
    ) {
        Long userIdx = Long.parseLong(userDetails.getUsername());
        randomMatchService.cancelQueue(userIdx);
        return ApiResponse.success("취소 성공");
    }
}