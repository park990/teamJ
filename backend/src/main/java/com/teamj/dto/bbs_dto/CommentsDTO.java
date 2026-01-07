package com.teamj.dto.bbs_dto;

import java.time.LocalDateTime;

import com.teamj.entity.bbs_entity.BbsComments;

import lombok.Getter;

@Getter
public class CommentsDTO {
    private final Long commentIdx;
    private final Long parentIdx;
    private final Long bbsIdx;
    private final Long usersIdx;
    private final String content;
    private final LocalDateTime createdAt;

    public CommentsDTO(BbsComments entity){
        this.commentIdx = entity.getCommentIdx();
        this.parentIdx = entity.getParent() != null
                ? entity.getParent().getCommentIdx()
                : null;
        this.bbsIdx = entity.getBbs().getBbsIdx();
        this.content = entity.getContent();
        this.usersIdx = entity.getUsers().getUsersIdx();
        this.createdAt = entity.getCreatedAt();
    }
}
