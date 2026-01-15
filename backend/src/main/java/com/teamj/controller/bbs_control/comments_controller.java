package com.teamj.controller.bbs_control;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Slice;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.teamj.config.CustomUserDetails;
import com.teamj.dto.bbs_dto.CommentsDTO;
import com.teamj.dto.bbs_dto.SliceResponseDTO;
import com.teamj.dto.response.ApiResponse;
import com.teamj.service.bbs_service.CommentsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/comments")
@Slf4j
public class comments_controller {
    private final CommentsService commentsService;

    @GetMapping("/{bbsIdx}")
    public ResponseEntity<ApiResponse<SliceResponseDTO<CommentsDTO>>> getComments(
        @PathVariable(value = "bbsIdx") Long bbsIdx,
        @RequestParam(value = "page", defaultValue ="0") int page,
        @RequestParam(value = "size", defaultValue = "15") int size
    ){
        PageRequest pageRequest = PageRequest.of(page,size,Sort.by("commentIdx").descending());
        Slice<CommentsDTO> sliceDto = commentsService.getComments(bbsIdx, pageRequest);

        SliceResponseDTO<CommentsDTO> response = new SliceResponseDTO<>(sliceDto.getContent(), sliceDto.hasNext());

        return ResponseEntity.ok(ApiResponse.success(response, "댓글 paging get 성공"));
    }

    @PostMapping("/submit")
    public ResponseEntity<ApiResponse<Void>> saveComment(@RequestBody CommentsDTO commentsDTO,
        @AuthenticationPrincipal CustomUserDetails userDetails
    ){
        System.out.println("데이터 도착"+commentsDTO.getContent());
        if(userDetails == null){
            return ResponseEntity.badRequest().body(ApiResponse.error("인증 정보 없음"));
        }
        
        System.out.println("유저정보는 바로 "+userDetails.getUserIdx());
        
        commentsDTO.setUsersIdx((userDetails.getUserIdx()));
        commentsService.saveComment(commentsDTO);

        return ResponseEntity.ok(ApiResponse.success(null,"댓글 등록 완료"));
    }
}
