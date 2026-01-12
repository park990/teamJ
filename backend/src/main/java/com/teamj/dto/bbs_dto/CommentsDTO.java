package com.teamj.dto.bbs_dto;

import java.time.LocalDateTime;

import com.teamj.entity.bbs_entity.BbsComments;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CommentsDTO {
    private Long commentIdx;
    private Long parentIdx;
    private Long bbsIdx;
    private Long usersIdx;
    private String nickName;
    private String content;
    private LocalDateTime createdAt;

    public CommentsDTO(BbsComments entity){
        this.commentIdx = entity.getCommentIdx();
        this.parentIdx = entity.getParent() != null
                ? entity.getParent().getCommentIdx()
                : null;
        this.bbsIdx = entity.getBbs().getBbsIdx();
        this.content = entity.getContent();
        this.usersIdx = entity.getUsers().getUsersIdx();
        this.nickName = entity.getUsers().getUsersNickname();
        this.createdAt = entity.getCreatedAt();
    }
}
