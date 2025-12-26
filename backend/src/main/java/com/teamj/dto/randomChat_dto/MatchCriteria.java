package com.teamj.dto.randomChat_dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class MatchCriteria {
    private String desiredGender;
    private String ageRange;
    private String region;
    // private String interestOption;
    // private String personalityOption;
    // private String hobbyOption;
    
}
