package com.teamj.controller.bbs_control;

import java.util.List;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Slice;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.teamj.dto.bbs_dto.CommentsDTO;
import com.teamj.dto.bbs_dto.SliceResponseDTO;
import com.teamj.dto.response.ApiResponse;
import com.teamj.entity.bbs_entity.BbsComments;
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
        @PathVariable Long bbsIdx,
        @RequestParam(defaultValue ="0") int page,    
        @RequestParam(defaultValue = "15") int size
    ){
        PageRequest pageRequest = PageRequest.of(page,size,Sort.by("commentIdx").descending());
        Slice<CommentsDTO> sliceDto = commentsService.getComments(bbsIdx, pageRequest);

        SliceResponseDTO<CommentsDTO> response = new SliceResponseDTO<>(sliceDto.getContent(), sliceDto.hasNext());

        return ResponseEntity.ok(ApiResponse.success(response, "댓글 paging get 성공"));
    }
}
