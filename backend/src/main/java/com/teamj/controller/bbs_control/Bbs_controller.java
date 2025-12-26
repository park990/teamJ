package com.teamj.controller.bbs_control;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import com.teamj.config.CustomUserDetails;
import com.teamj.dto.PostDTO;
import com.teamj.response.ApiResponse;
import com.teamj.service.bbs_service.BbsService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequiredArgsConstructor
@Controller
@RequestMapping("/api/post")
@Slf4j
public class Bbs_controller {
    private final BbsService bbsService;


    // 게시글  전부 불러오기(삭제된거 제외)
    @GetMapping("/getList")
    public ResponseEntity<ApiResponse<List<PostDTO>>> getList(){//@pathVariable Long typeIdx){
        List<PostDTO> list = bbsService.findActivePost();
        return ResponseEntity.ok(ApiResponse.success(list,"조회 성공"));
    }


    // 게시글 등록
    @PostMapping("/submit")
    public ResponseEntity<ApiResponse<Boolean>> submit(@RequestBody PostDTO dto,
        @AuthenticationPrincipal CustomUserDetails userDetails
    ){
        log.info(userDetails.getUsername());
        log.info(dto.getContent());
        Boolean isSuccess = bbsService.savePost(dto, userDetails.getUserIdx());

        if(isSuccess){
            return ResponseEntity.ok(ApiResponse.success("글 등록 성공"));
        }
        else{
            return ResponseEntity.status(500).body(ApiResponse.error("글 등록 실패"));
        }
    }



}
