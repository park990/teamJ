package com.teamj.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@Builder
@RequiredArgsConstructor
public class UserDTO {

    private final Long usersIdx;

    private final String usersNickname;
    
    // private final  String profileImageUrl;

    private final String grade;
}
