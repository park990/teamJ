package com.teamj.controller.bbs_control;

import java.util.List;
import java.util.Map;

import org.springframework.data.domain.Slice;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.teamj.config.CustomUserDetails;
import com.teamj.dto.bbs_dto.PostDTO;
import com.teamj.dto.bbs_dto.LikeToggleDTO;
import com.teamj.dto.response.ApiResponse;
import com.teamj.service.bbs_service.BbsService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/post")
@Slf4j
public class Bbs_controller {
    private final BbsService bbsService;


    // 게시글  전부 불러오기(삭제된거 제외)
    @GetMapping("/getList")
    public ResponseEntity<ApiResponse<Slice<PostDTO>>> getList(
        @AuthenticationPrincipal CustomUserDetails userDetails,
        @RequestParam(value = "page", defaultValue = "0") int page,   // 클라이언트가 보낸 페이지 번호
        @RequestParam(value = "size", defaultValue = "10") int size
    ){//@pathVariable Long typeIdx){
        Long userIdx = (userDetails != null) ? userDetails.getUserIdx() : null;

        Slice<PostDTO> sliceList = bbsService.findActivePost(userIdx,page,size);
        
        // Slice는 content라는 포장지 안에 쌓여져 있따 data->content 그리고 data->hasNext라든지 존재하고 있음.
        return ResponseEntity.ok(ApiResponse.success(sliceList, "조회 성공"));
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

    @PostMapping("/delete")
    public ResponseEntity<ApiResponse<Boolean>> deletePost(
        @AuthenticationPrincipal CustomUserDetails userDetails,
        @RequestBody Map<String,Long> requestBody
    ){
         if(userDetails == null){
            return ResponseEntity.status(401).body(ApiResponse.error("로그인이 필요함."));
        }
        Long userIdx = userDetails.getUserIdx();
        Long postIdx= requestBody.get("postIdx");
        System.out.println("userIdx = "+userIdx + "입니다. 삭제할 게시글은 "+postIdx+"번 게시글");
        
        // 여기서 에러가 터지면 -> GlobalExceptionHandler의 handleIllegalArgument가 잡아서 처리해줌
        bbsService.deletePost(Long.valueOf(postIdx), userIdx); 

        return ResponseEntity.ok(ApiResponse.success(true, "게시글 삭제 성공"));
    }

    // 좋아요 토글 기능
    @PostMapping("/likeToggle")
    public ResponseEntity<ApiResponse<LikeToggleDTO>> likeToggle(
        @AuthenticationPrincipal CustomUserDetails userDetails,
        @RequestBody Map<String,Long> requestBody
    ){
        if(userDetails == null){
            return ResponseEntity.status(401).body(ApiResponse.error("로그인이 필요함."));
        }

        Long bbsIdx= requestBody.get("bbsIdx");
        

        LikeToggleDTO dto  = bbsService.toggleLike(bbsIdx, userDetails.getUserIdx());
        
        String message = dto.isLiked() ? "좋아요 등록 성공" : "좋아요 취소 성공";

        return ResponseEntity.ok(ApiResponse.success(dto, message));
    }

}
