package com.teamj.dto.bbs_dto;


import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class LikeToggleDTO {

    // 이건 프론트에서 liked로받았음 is를 빼도 jsonProperty 로 명시해서 보내도 희안하게 여건 liked로 
    private boolean isLiked;

    private int likeCount;
}
