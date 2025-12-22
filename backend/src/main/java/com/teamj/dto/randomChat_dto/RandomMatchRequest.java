package com.teamj.dto.randomChat_dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class RandomMatchRequest {
    private String genderOption; // "male" | "female" | "random"
}