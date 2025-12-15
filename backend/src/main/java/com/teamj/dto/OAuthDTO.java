package com.teamj.dto;

import lombok.Data;

@Data
public class OAuthDTO {
    
    private String socialToken;
    private String provider;
}
