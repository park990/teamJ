package com.teamj.dto.gathering_dto;

import java.time.LocalDateTime;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class GatheringDetailDto {
    private Long roomIdx;
    private String roomName;
    private String roomType;
    private String roomDesc;
    private String roomImg;
    private LocalDateTime meetDate;
    private String meetPlace;
    private int max;
    private int participantCount;
    private Boolean isFull;
    private Boolean isParticipating;
    private LocalDateTime createdAt;
}
