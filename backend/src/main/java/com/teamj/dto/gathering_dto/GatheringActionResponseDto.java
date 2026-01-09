package com.teamj.dto.gathering_dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class GatheringActionResponseDto {
    private Boolean success;
    private String message;
    private int participantCount;
    private Boolean isFull;
    private Boolean isParticipating;
}
