package com.teamj.dto.randomChat_dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class MatchResult {
    private boolean matched; // 매칭 성공 여부
    private Long roomIdx;    // 매칭되면 값 있음, 아니면 null
    private Long partnerIdx;  // 매칭된 상대방 userIdx (있는 경우)

    public static MatchResult waiting() {
        return new MatchResult(false, null, null);
    }
    
    public static MatchResult matched(Long roomIdx, Long partnerIdx) {
        return new MatchResult(true, roomIdx, partnerIdx);
    }
}