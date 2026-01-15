package com.teamj.exception;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import com.teamj.dto.response.ApiResponse;
import com.teamj.exception.bbs_error.BbsException;

import lombok.extern.slf4j.Slf4j;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
    
    // 게시글이 삭제되었을때 뱉어주는 에러
    @ExceptionHandler(BbsException.class)
    public ResponseEntity<ApiResponse<Object>> handleBbsException(BbsException e) {

        var commentsError = e.getCommentsError();

        log.warn("BbsException 발생: {} - {}", commentsError.getCode(), commentsError.getMessage());

        // 아까 ApiResponse에 만들어둔 fail 메서드를 사용해 P001 코드로 응답합니다.
        return ResponseEntity.status(400)
            .body(ApiResponse.fail(commentsError));
    }


    // 1. [기존 유지] 일반적인 실수 (IllegalArgumentException)
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiResponse<Object>> handleIllegalArgument(IllegalArgumentException e) {
        log.warn("잘못된 요청: {}", e.getMessage());
        // 이건 커스텀 코드가 없으므로 그냥 "fail"로 나갑니다.
        return ResponseEntity.badRequest()
            .body(ApiResponse.error(e.getMessage()));
    }

    // 2. [기존 유지] 최후의 보루 (Exception)
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Object>> handleAll(Exception e) {
        log.error("알 수 없는 에러 발생: ", e);
        return ResponseEntity.status(500)
            .body(ApiResponse.error("서버 내부 오류가 발생했습니다. 관리자에게 문의하세요."));
    }
}