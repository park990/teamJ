package com.teamj.exception;

import lombok.Getter;

@Getter
public enum ErrorCode {
    // 모임 관련 에러
    GATHERING_NOT_FOUND(404, "GATHERING_NOT_FOUND", "존재하지않는 모임입니다."),
    ALREADY_PARTIVIPATED(409, "ALREADY_PARTIVIPATED", "이미 참가한 모임입니다."),
    GATHERING_FULL(400, "GATHERING_FULL", "모임 정원이 모두 찼습니다."),
    NOT_PARTICIPATED(400, "NOT_PARTICIPATED", "참가하지 않은 모임입니다."),
    CANNOT_LEAVE_HOST(403, "CANNOT_LEAVE_HOST", "방장은 모임을 탈퇴할 수 없습니다."),

    // 사용자 관련 에러
    USER_NOT_FOUND(404, "USER_NOT_FOUND", "사용자를 찾을 수 없습니다."),
    UNAUTHORIZED(401, "UNAUTHORIZED", "인증이 필요합니다."),
    FORBIDDEN(403, "FORBIDDEN", "서버 오류가 발생했습니다."),

    // 일반 에러
    INVALID_INPUT(400, "INVALID_INPUT", "잘못된 입력값입니다."),
    INTERNAL_ERROR(500, "INTERNAL_ERROR", "서버 오류가 발생했습니다.");

    private final int status;
    private final String code;
    private final String message;

    ErrorCode(int status, String code, String message) {
        this.status = status;
        this.code = code;
        this.message = message;
    }
}
