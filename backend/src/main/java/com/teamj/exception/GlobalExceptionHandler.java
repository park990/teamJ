package com.teamj.exception;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import com.teamj.dto.response.ApiResponse; // 사용자님의 ApiResponse 패키지 경로에 맞게 수정
import lombok.extern.slf4j.Slf4j;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    // 모든 에러를 그냥 하나로 퉁쳐서 처리합니다.
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Object>> handleAll(Exception e) {
        log.error("에러 발생: ", e);
        return ResponseEntity.status(500)
            .body(ApiResponse.error("서버 오류가 발생했습니다."));
    }
}