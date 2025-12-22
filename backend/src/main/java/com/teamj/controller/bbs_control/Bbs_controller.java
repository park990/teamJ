package com.teamj.controller.bbs_control;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import com.teamj.config.CustomUserDetails;
import com.teamj.dto.PostDTO;
import com.teamj.repository.bbs_repository.BbsService;
import com.teamj.response.ApiResponse;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequiredArgsConstructor
@Controller
@RequestMapping("/api/post")
@Slf4j
public class Bbs_controller {
    private final BbsService bbsService;

    @PostMapping("/submit")
    public ResponseEntity<ApiResponse<Boolean>> submit(@RequestBody PostDTO dto,
        @AuthenticationPrincipal CustomUserDetails userDetails
    ){
        log.info(userDetails.getUsername());
    
        return null;
    }
}
