package com.teamj.dto.randomChat_dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MatchData {
    private String status;      // "WAITING" | "MATCHED"
    private Long roomIdx;       // 매칭 성공 시 방 ID
    private Long partnerIdx;    // 매칭된 상대방 userIdx
    
    public static MatchData waiting() {
        return new MatchData("WAITING", null, null);
    }
    
    public static MatchData matched(Long roomIdx, Long partnerIdx) {
        return new MatchData("MATCHED", roomIdx, partnerIdx);
    }

    public static MatchData cancelled() {
        return new MatchData("CANCELLED", null, null);
    }
    
    public static MatchData error() {
        return new MatchData("ERROR", null, null);
    }
}