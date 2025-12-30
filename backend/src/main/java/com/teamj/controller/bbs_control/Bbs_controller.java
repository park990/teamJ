package com.teamj.controller.bbs_control;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

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
    public ResponseEntity<ApiResponse<?>> submit(@RequestPart(value = "content",required = false) String content,
        @RequestPart(value="images",required = false) List<MultipartFile> images,
        @AuthenticationPrincipal CustomUserDetails userDetails
    ){
        log.info(userDetails.getUsername());
        log.info(content);
        log.info("이미지 개수: {}", images != null ? images.size() : 0);

        bbsService.savePost(content, userDetails.getUserIdx(), images);

            return ResponseEntity.ok(ApiResponse.success("글 등록 성공"));
        
    }

    // 좋아요 토글 기능
    @PostMapping("/likeToggle")
    public ResponseEntity<ApiResponse<Boolean>> likeToggle(
        @AuthenticationPrincipal CustomUserDetails userDetails,
        @RequestBody Map<String,Long> requestBody
    ){
        if(userDetails == null){
            return ResponseEntity.status(401).body(ApiResponse.error("로그인이 필요함."));
        }

        Long bbsIdx= requestBody.get("bbsIdx");
        

        boolean isLiked = bbsService.toggleLike(bbsIdx, userDetails.getUserIdx());
        
        String message = isLiked ? "좋아요 등록 성공" : "좋아요 취소 성공";

        return ResponseEntity.ok(ApiResponse.success(isLiked, message));
    }

}
