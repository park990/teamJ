package com.teamj.dto;

import java.time.LocalDateTime;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostDTO {
private Long bbsIdx;
    private Long bbsTypeIdx;
    private Long usersIdx;
    private String content;
    private String usersNickname; // 작성자 닉네임 (Join 결과)
    private Integer viewCount;
    private LocalDateTime createdAt;
    private List<String> imgUrls;     
    private Integer likeCount;    // 좋아요 수 (Reaction 테이블 집계)
    private Integer commentCount; // 댓글 수 (comment 테이블 집계)
}
