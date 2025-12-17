package com.teamj.service.myPage_service.signUp_service;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.teamj.dto.SocialUserDTO;
import com.teamj.entity.users_entity.Users;
import com.teamj.jwt.JwtTokenProvider;
import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;
import com.teamj.response.ApiResponse;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final JwtTokenProvider jwtTokenProvider;
    private final StringRedisTemplate redisTemplate;

    // 회원가입 닉네임 중복 체크
    public Boolean existsByNickName(String nickName) {
        return userRepository.existsByUsersNickname(nickName);
    }

    // 회원가입 db 저장
    @Transactional
    public ResponseEntity<ApiResponse<Map<String, Object>>> registerUser(SocialUserDTO dto) {
        Map<String,Object> data = new HashMap<>();

        // 1. 중복 체크 (서비스에서 바로 409 에러 리턴)
        if (userRepository.existsByUsersNickname(dto.getUsersNickname())) {
            return ResponseEntity
                    .status(HttpStatus.CONFLICT)
                    .body(ApiResponse.error("이미 사용중인 닉네임입니다."));
        }

        // SocialUserDTO에 한방에 넣는거 정의 해둠
        Users user = dto.toEntity();

        Users savedUser = userRepository.save(user);

        // 여기서 토큰 만들어서 줘야함
        String accessToken = jwtTokenProvider.createAccessToken(savedUser.getUsersIdx());
        String refreshToken = jwtTokenProvider.createRefreshToken();

        redisTemplate.opsForValue().set(
            "RT:"+savedUser.getUsersIdx(),
            refreshToken,
            7,
            TimeUnit.DAYS
        );

        data.put("wazzupToken", accessToken);
        data.put("refreshToken", refreshToken);

        return ResponseEntity.ok(ApiResponse.success(data, "회원가입 성공"));

    }
}
