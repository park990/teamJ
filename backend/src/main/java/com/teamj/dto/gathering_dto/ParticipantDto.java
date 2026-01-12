package com.teamj.dto.gathering_dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ParticipantDto {
    private Long userIdx;
    private String usersNickname;
    private String usersRole;
    private String profileImage;
}
