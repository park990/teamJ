package com.teamj.controller.randomChat_control;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.teamj.response.ApiResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/random-match")
@RequiredArgsConstructor
public class RandomMatchController {

    private final RandomMatchService randomMatchService;

    @PostMapping("/enter")
    public ApiResponse<RandomMatchResponse> enterQueue(
        @RequestBody RandomMatchRequest request,
        @AuthenticationPrincipal CustomUserDetails user
    ) {
        return ApiResponse.success(
            randomMatchService.enterQueue(user.getUserId(), request)
        );
    }

    @PostMapping("/cancel")
    public ApiResponse<Void> cancelQueue(
        @AuthenticationPrincipal CustomUserDetails user
    ) {
        randomMatchService.cancelQueue(user.getUserId());
        return ApiResponse.success("취소 성공");
    }
}