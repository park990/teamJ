package com.teamj.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class OAuthDTO {
    
    private String socialToken;
    private String provider;
}
