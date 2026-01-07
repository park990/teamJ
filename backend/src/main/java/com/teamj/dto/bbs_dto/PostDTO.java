package com.teamj.dto.bbs_dto;

import java.time.LocalDateTime;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;

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

    // Spring boot에서는 isLiked로 set 하게 된다면 is 를 짤라서 프론트로 보냄 즉 Liked로 받을수 있는거임 프론트에서 하지만 이것을 방지하기 위해서 이름을 isLiked라고 명시해주자.
    @JsonProperty("isLiked")
    private boolean isLiked;
}
