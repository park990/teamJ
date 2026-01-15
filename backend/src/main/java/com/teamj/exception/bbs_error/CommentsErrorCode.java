package com.teamj.exception.bbs_error;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum CommentsErrorCode {

    POST_DELETED("P001", "삭제된 게시글입니다.");

    private final String code;
    private final String message;
}
