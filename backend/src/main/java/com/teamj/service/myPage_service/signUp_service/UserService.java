package com.teamj.service.myPage_service.signUp_service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.teamj.dto.SocialUserDTO;
import com.teamj.entity.users_entity.Users;
import com.teamj.entity.users_entity.Users.Gender;
import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;
import com.teamj.response.ApiResponse;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

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

        Users user = new Users();
        user.setUsersName(dto.getUsersName());
        user.setUsersEmail(dto.getUsersEmail());
        user.setUsersSnsId(dto.getUsersSnsId());
        user.setUsersNickname(dto.getUsersNickname());
        user.setUsersPhone(dto.getUsersPhone());
        user.setBirthDate(dto.getBirthDate());
        if ("0".equals(dto.getUsersGender())) {
            user.setUsersGender(Gender.FEMALE);
        } else {
            user.setUsersGender(Gender.MALE);
        }
        user.setGrade("와둥이");
        user.setProvider(dto.getProvider());
        // user.setCi(dto.getCi());

        userRepository.save(user);

        //여기서 토큰 만들어서 줘야함
        // String token = jwtTokenProvider.createAccessToken();
        String wazzupToken = "신규유저 임시 JWT Token임{ADSFADSFASDFASFDAFSDAD12312F}";

        data.put("wazzupToken", wazzupToken);
        return ResponseEntity.ok(ApiResponse.success(data, "회원가입 성공"));

    }
}
