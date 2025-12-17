package com.teamj.controller.myPage_control.signUp_control;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
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

    // 로그아웃
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Object>> logout(@RequestHeader("Authorization") String bearerToken){
        String accessToken = bearerToken.substring(7);
        oAuthService.logout(accessToken);

        return ResponseEntity.ok(ApiResponse.success("로그아웃 승인"));
    }

    // 카카오 로그인
    @PostMapping("/kakao")
    public ResponseEntity<ApiResponse<?>> kakaoLogin(@RequestBody OAuthDTO dto){
        
        return oAuthService.socialLogin(dto);
    }

    // 토큰 재발급
    @PostMapping("/reissue")
    public ResponseEntity<ApiResponse<?>> reissue (@RequestBody Map<String,String> request){
        String refreshToken = request.get("refreshToken");

        return oAuthService.reissueAccessToken(refreshToken);
    }
    
}
