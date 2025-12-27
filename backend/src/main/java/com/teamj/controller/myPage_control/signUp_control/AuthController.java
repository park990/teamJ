package com.teamj.controller.myPage_control.signUp_control;

import java.util.Map;

import org.apache.catalina.connector.Response;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.teamj.config.CustomUserDetails;
import com.teamj.dto.OAuthDTO;
import com.teamj.response.ApiResponse;
import com.teamj.service.myPage_service.oauth_service.AuthService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/auth")
@Slf4j
public class AuthController {
    private final AuthService oAuthService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<?>> getMyInfo(@AuthenticationPrincipal CustomUserDetails userDetails){
        log.info("내 정보 조회 실행 유저IDX:{}",userDetails.getUserIdx());
        
        return oAuthService.getUserMe(userDetails.getUserIdx());
    }

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
        log.info("로그인 실행");
        return oAuthService.socialLogin(dto);
    }

    // 토큰 재발급
    @PostMapping("/reissue")
    public ResponseEntity<ApiResponse<?>> reissue (@RequestBody Map<String,String> request){
        String refreshToken = request.get("refreshToken");
        log.info("토큰 재발급 실행");
        return oAuthService.reissueAccessToken(refreshToken);
    }
    
}
