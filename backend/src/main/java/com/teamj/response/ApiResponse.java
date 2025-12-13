package com.teamj.response;
import lombok.AllArgsConstructor;
import lombok.Getter;

// 앞으로 데이터를 프론트로 보낼 때는 이 객체로 통일해서 보내도록..

@Getter
@AllArgsConstructor
public class ApiResponse<T> {
    
    private String result;  // "success" 또는 "fail"
    private String message; // 프론트에 띄울 알림 메시지
    private T data;         // 진짜 데이터 (null일 수도 있음)

    // 1. 성공했을 때 쓸 메서드 (데이터 있음)
    public static <T> ApiResponse<T> success(T data, String message) {
        return new ApiResponse<>("success", message, data);
    }
    
    // 2. 성공했지만 줄 데이터는 없을 때 (예: 로그아웃 성공)
    public static <T> ApiResponse<T> success(String message) {
        return new ApiResponse<>("success", message, null);
    }

    // 3. 실패했을 때 쓸 메서드
    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>("fail", message, null);
    }

    // 처음 회원가입을 했을 때
    public static <T> ApiResponse<T> register(T data) {
        return new ApiResponse<>("register", "회원가입이 필요한 유저입니다.", data);

    }


}