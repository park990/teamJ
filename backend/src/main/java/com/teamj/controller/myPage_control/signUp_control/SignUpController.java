package com.teamj.controller.myPage_control.signUp_control;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import com.teamj.service.myPage_service.signUp_service.UserService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/api/signUp")
public class SignUpController {
    private final UserService userService;
    
    @PostMapping("/check_nickName")
        public ResponseEntity<Boolean> checkNickname(@RequestBody Map<String,String> request){
            String nickName = request.get("nickName");
            System.out.println("닉네임 중복을 위한 "+ nickName);
            boolean isDup = userService.existsByNickName(nickName);
            return ResponseEntity.ok(isDup);
        }
    
}
