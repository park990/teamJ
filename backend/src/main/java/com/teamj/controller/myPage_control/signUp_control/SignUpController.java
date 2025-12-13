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
import com.teamj.service.myPage_service.signUp_service.UserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/signUp")
public class SignUpController {
    private final UserService userService;
    
    // 닉네임 중복 체크
    @PostMapping("/check_nickName")
        public ResponseEntity<Boolean> checkNickname(@RequestBody Map<String,String> request){
            String nickName = request.get("nickName");
            System.out.println("닉네임 중복을 위한 "+ nickName);
            boolean isDup = userService.existsByNickName(nickName);
            return ResponseEntity.ok(isDup);
        }

    // 회원 가입 DB 등록
    @PostMapping("/submit")
        public ResponseEntity<Boolean> submitSignUp(@RequestBody SignUpDTO signUpDTO){
            System.out.println("받은 데이터"+signUpDTO);
            boolean isSuccess = userService.registerUser(signUpDTO);
            if(isSuccess==true){
                System.out.println("DB등록 성공");
                return ResponseEntity.ok(isSuccess);
            }else{
                System.out.println("닉네임 중복");
                return ResponseEntity.status(HttpStatus.CONFLICT).body(false);
            }
        }
    
}
