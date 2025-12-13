package com.teamj.controller.myPage_control.signUp_control;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.teamj.dto.SignUpDTO;
import com.teamj.response.ApiResponse;
import com.teamj.service.myPage_service.signUp_service.UserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/signUp")
public class SignUpController {
    private final UserService userService;

    // 닉네임 중복 체크
    @PostMapping("/check_nickName")
    public ResponseEntity<ApiResponse<Boolean>> checkNickname(@RequestBody Map<String, String> request) {
        String nickName = request.get("nickName");
        System.out.println("닉네임 중복 체크를 위한 " + nickName);
        boolean isDup = userService.existsByNickName(nickName);
        if (isDup) {
            // 중복임 (data: true)
            return ResponseEntity.ok(ApiResponse.success(true, "이미 사용 중인 닉네임."));
        } else {
            // 사용 가능함 (data: false)
            return ResponseEntity.ok(ApiResponse.success(false, "사용 가능한 닉네임."));
        }
    }

    // 회원 가입 DB 등록
    @PostMapping("/submit")
    public ResponseEntity<ApiResponse<Boolean>> submitSignUp(@RequestBody SignUpDTO signUpDTO) {
        System.out.println("받은 데이터" + signUpDTO);
        boolean isSuccess = userService.registerUser(signUpDTO);
        if (isSuccess) {
            // 성공
            return ResponseEntity.ok(ApiResponse.success(true, "회원가입이 완료."));
        } else {
            // 실패
            return ResponseEntity
                    .status(HttpStatus.CONFLICT)
                    .body(ApiResponse.error("이미 가입된 닉네임 존재."));
        }
    }

}
