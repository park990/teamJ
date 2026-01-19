package com.teamj.dto.gathering_dto;

import java.time.LocalDateTime;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class GatheringCreateRequestDto {
    private String roomName;
    private String roomType;
    private String roomDesc;
    private LocalDateTime meetDate;
    private String meetPlace;
    private int max;
}
