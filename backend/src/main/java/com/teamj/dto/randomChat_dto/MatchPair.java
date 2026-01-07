package com.teamj.dto.randomChat_dto;

import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 매칭 결과를 담는 래퍼 클래스 (Service → Controller 전달용)
 * 
 * 【 역할 】
 * Service가 Controller에게 두 사용자의 MatchData를 동시에 전달
 * 
 * 【 필요한 이유 】
 * Java는 메서드가 하나의 값만 반환 가능
 * → 두 개의 MatchData를 반환하려면 래퍼 클래스 필요!
 * 
 * 【 흐름 】
 * Service:
 *   1. 매칭 로직 실행
 *   2. 요청자용 MatchData 생성
 *   3. 상대방용 MatchData 생성
 *   4. MatchPair로 묶어서 반환
 *   
 * Controller:
 *   1. MatchPair 받기
 *   2. requesterData 추출 → 요청자에게 전송
 *   3. partnerData 추출 → 상대방에게 전송
 *   
 * 【 예시 】
 * User A (100)와 User B (200)가 매칭:
 * 
 * Service:
 *   requesterData = MatchData.matched(456, 200)  // A 입장: 상대는 200
 *   partnerData = MatchData.matched(456, 100)    // B 입장: 상대는 100
 *   return new MatchPair(requesterData, partnerData);
 *   
 * Controller:
 *   pair.getRequesterData() → A에게 전송
 *   pair.getPartnerData() → B에게 전송
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MatchPair {
    
    /**
     * 요청자(매칭 요청한 사람)용 MatchData
     * - 항상 존재 (대기 중이든 매칭 성공이든)
     */
    @NonNull
    private MatchData requesterData;
    
    /**
     * 상대방(먼저 대기하던 사람)용 MatchData
     * - 매칭 성공 시에만 존재
     * - 대기 중일 때는 null
     */
    @Nullable
    private MatchData partnerData;
    
    // ================================
    // 정적 팩토리 메서드
    // ================================
    
    /**
     * 대기 중 상태 생성
     * (상대방 없음)
     * 
     * @param requesterData 요청자용 MatchData (대기 중)
     * @return 대기 중 MatchPair
     */
    public static MatchPair waiting(@NonNull MatchData requesterData) {
        return new MatchPair(requesterData, null);
    }
    
    /**
     * 매칭 성공 상태 생성
     * (양쪽 데이터 모두 존재)
     * 
     * @param requesterData 요청자용 MatchData
     * @param partnerData 상대방용 MatchData
     * @return 매칭 성공 MatchPair
     */
    public static MatchPair matched(@NonNull MatchData requesterData, @NonNull MatchData partnerData) {
        return new MatchPair(requesterData, partnerData);
    }
    
    // ================================
    // 편의 메서드
    // ================================
    
    /**
     * 매칭 성공 여부 확인
     * 
     * @return 매칭 성공이면 true, 대기 중이면 false
     */
    public boolean isMatched() {
        return partnerData != null;
    }
}

