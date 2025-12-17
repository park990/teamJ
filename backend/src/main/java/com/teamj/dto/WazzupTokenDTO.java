package com.teamj.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@Builder
@RequiredArgsConstructor
public class WazzupTokenDTO {
    
    // Wazzup 토큰 (Access Token)
    private final String wazzupToken; 
    
    // 리프레시 토큰
    private final String refreshToken;
}
