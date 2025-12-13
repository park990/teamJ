package com.teamj.service.myPage_service.oauth_servicer;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.teamj.entity.users_entity.Users;
import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;
import com.teamj.response.ApiResponse;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class OAuthService {
    private final UserRepository userRepository;

    public ResponseEntity<ApiResponse<?>> kakaoLogin(String kakaoToken){
    
        String kakaoSnsId = getSnsIdFromKakao(kakaoToken);
        Map<String,Object> data = new HashMap<>();

        if(kakaoSnsId==null){
            return ResponseEntity.badRequest().body(ApiResponse.error("카카오 토큰이 유효하지 않음"));
        }
        Users user = userRepository.findByPlatformAndUsersSnsId("KAKAO", kakaoSnsId);

        // User가 null이 아니면 기존 유저임
        if(user!=null){
            String wazzupToken="임시 JWT Token임 브랄라랄ㄹ라랄라";
            data.put("token", wazzupToken);
            return ResponseEntity.ok(ApiResponse.success(data,"로그인 성공"));
            
        }else{
            data.put("platform","KAKAO");
            data.put("userSnsId",kakaoSnsId);
            return ResponseEntity.ok(ApiResponse.register(data));
        }
    }

    private String getSnsIdFromKakao(String kakoToken){
        try{
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization","Bearer "+kakoToken);
        headers.add("Content-type", "application/x-www-form-urlencoded;charset=utf-8");

        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<Map> response = restTemplate.exchange(
            "https://kapi.kakao.com/v2/user/me",
            HttpMethod.POST,
            entity,
            Map.class
        );
        Map body = response.getBody();

        String id = String.valueOf(body.get("id"));

        return id;   
    }catch(Exception e){
        e.printStackTrace();
        return null;
    }
    }
}
