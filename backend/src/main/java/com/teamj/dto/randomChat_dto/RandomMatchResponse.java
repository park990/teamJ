package com.teamj.dto.randomChat_dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class RandomMatchResponse {
    private boolean matched; // 매칭 성공 여부
    private Long roomIdx;    // 매칭되면 값 있음, 아니면 null
}