package com.teamj.dto;

import java.sql.Date;


import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class SocialUserDTO {
    private Long usersIdx;
    private String grade;
    private String usersSnsId;
    private String usersPwd;
    private String usersName;
    private String usersNickName;
    private String usersGender;
    private String usersAddress;
    private String usersPhone;
    private int usersExit;
    private int isBanned;
    private String provider;
    private String usersEmail;
    private String ci;
    private Date birthDate;
}
