package com.teamj.controller.myPage_control.signUp_control;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.teamj.dto.OAuthDTO;
import com.teamj.response.ApiResponse;
import com.teamj.service.myPage_service.oauth_servicer.OAuthService;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@RestController
@RequestMapping("api/oauth")
public class OAuthController {
    private final OAuthService oAuthService;

    @PostMapping("/kakao")
    public ResponseEntity<ApiResponse<?>> kakaoLogin(@RequestBody OAuthDTO dto){
        
        return oAuthService.kakaoLogin(dto);
    }
}
