package com.teamj.dto.gathering_dto;

import java.time.LocalDateTime;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class GatheringHotListDto {
    private Long roomIdx;
    private String roomName;
    private String roomType;
    private LocalDateTime createdAt;
    private LocalDateTime meetDate;
    private String meetPlace;
    private int max;
    private String roomImg;
    private String roomDesc;
}