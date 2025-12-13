package com.teamj.dto;

import lombok.Data;

@Data
public class SignUpDTO {
    private String name;        
    private String nickname;
    private String phoneNumber; 
    private String birthDate;   
    private String gender;
    private String platform;
    private String ci;
}
