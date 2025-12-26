package com.teamj.dto.randomChat_dto;

import com.teamj.entity.users_entity.Users;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class WaitingUser {
    private Long userIdx;
    private Users.Gender actualGender;  // 실제 성별 (메모리에 저장)
    private MatchCriteria criteria;  // 매칭 조건
}