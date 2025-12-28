package com.teamj.service.match_service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.teamj.dto.randomChat_dto.MatchCriteria;
import com.teamj.dto.randomChat_dto.WaitingUser;
import com.teamj.entity.users_entity.Users;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class MatchQueueManager {

    private final StringRedisTemplate redisTemplate;
    private final ObjectMapper objectMapper;

    private static final String QUEUE_KEY_PREFIX = "match:queue:";

    private String getQueueKey(Users.Gender actualGender) {
        // actualGender가 null일 수 없어야 함 (필수 정보)
        return QUEUE_KEY_PREFIX + actualGender.name();  // "MALE" 또는 "FEMALE"
    }

    /**
     * WaitingUser를 JSON 문자열로 변환
     */
    private String toJson(WaitingUser user) {
        try {
            return objectMapper.writeValueAsString(user);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("WaitingUser JSON 변환 실패", e);
        }
    }

    /**
     * JSON 문자열을 WaitingUser로 변환
     */
    private WaitingUser fromJson(String json) {
        try {
            return objectMapper.readValue(json, WaitingUser.class);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("WaitingUser JSON 파싱 실패", e);
        }
    }

    /**
     * 🔥 랜덤 매칭 대기열
     *
     * - 아직 상대를 못 만난 유저들이 들어가는 곳
     * - FIFO (먼저 들어온 사람이 먼저 나감)
     * - Redis에 저장 (서버 재시작 후에도 유지)
     */

    /**
     * 매칭 시도
     *
     * 로직:
     * 1. 내가 원하는 성별 큐에서 상대 찾기
     * 2. 양방향 검증 (내가 원하는 성별 = 상대 실제 성별 && 상대가 원하는 성별 = 내 실제 성별)
     * 3. 맞으면 매칭, 안 맞으면 내가 큐에 대기
     */
    public synchronized Optional<Long> tryMatch(WaitingUser me) {

        /**
         * synchronized 사용 이유
         * ------------------
         * 동시에 여러 요청이 들어오면
         * - 두 명이 동시에 queue.peek()
         * - 같은 유저를 매칭해버리는 문제 발생
         *
         * 👉 한 번에 한 스레드만 매칭 로직 실행
         */

        // 매칭조건을 WaitingUser에서 가져옴
        String desiredGender = me.getCriteria().getDesiredGender();

        // 내 실제 성별
        Users.Gender myActualGender = me.getActualGender();

        // 매칭 성공 → 상대 유저
        WaitingUser matchedUser = null;
        String matchedQueueKey = null;  // 매칭된 큐 추적용
    
        if ("random".equals(desiredGender)) {
            // Random 선택 → MALE 큐와 FEMALE 큐 둘 다 확인
            
            // 1. MALE 큐 확인
            matchedUser = findMatchInQueue(me, Users.Gender.MALE);
            if (matchedUser != null) {
                matchedQueueKey = getQueueKey(Users.Gender.MALE);
            } else {
                // 2. FEMALE 큐 확인
                matchedUser = findMatchInQueue(me, Users.Gender.FEMALE);
                if (matchedUser != null) {
                    matchedQueueKey = getQueueKey(Users.Gender.FEMALE);
                }
            }
        } else {
            // 특정 성별 원함
            Users.Gender targetGender = "female".equals(desiredGender) 
                ? Users.Gender.FEMALE 
                : Users.Gender.MALE;
            
            matchedUser = findMatchInQueue(me, targetGender);
            if (matchedUser != null) {
                matchedQueueKey = getQueueKey(targetGender);
            }
        }
        
        if (matchedUser != null) {
            return Optional.of(matchedUser.getUserIdx()); // Optional.of: 값이 있는 Optional 객체 생성
        }
        
        // 매칭 실패 → 내 실제 성별 큐에 추가
        String myQueueKey = getQueueKey(myActualGender);
        redisTemplate.opsForList().rightPush(myQueueKey, toJson(me));
        return Optional.empty();
    }
    
    /**
     * 특정 큐에서 매칭 가능한 상대 찾기
     */
    private WaitingUser findMatchInQueue(WaitingUser me, Users.Gender targetGender) {
        String queueKey = getQueueKey(targetGender);
        List<WaitingUser> checkedUsers = new ArrayList<>();
        WaitingUser matchedUser = null;
        
        while (true) {
            String candidateJson = redisTemplate.opsForList().leftPop(queueKey);
            if (candidateJson == null) break;
            
            WaitingUser candidate = fromJson(candidateJson);
            checkedUsers.add(candidate);
            
            if (isMatch(me, candidate)) {
                matchedUser = candidate;
                break;
            }
        }
        
        // 매칭 실패한 사람들 다시 큐에 넣기 (역순으로)
        for (int i = checkedUsers.size() - 1; i >= 0; i--) {
            WaitingUser user = checkedUsers.get(i);
            if (user != matchedUser) {
                redisTemplate.opsForList().leftPush(queueKey, toJson(user));
            }
        }
        
        return matchedUser;  // 매칭된 사람 반환, 없으면 null
    }

    /**
     * 양방향 매칭 검증
     */
    private boolean isMatch(WaitingUser me, WaitingUser other) {
        MatchCriteria myCriteria = me.getCriteria();
        MatchCriteria otherCriteria = other.getCriteria();

        // 1. 성별 검증 (양방향)
        boolean genderMatch = 
            matchesGender(myCriteria.getDesiredGender(), other.getActualGender()) &&
            matchesGender(otherCriteria.getDesiredGender(), me.getActualGender());

        if (!genderMatch) return false;

        // 2. 나머지 조건 검증 (양방향)
        // 예: 나이대가 둘 다 null이 아니면 일치해야 함
        boolean ageMatch = matchesCondition(
            myCriteria.getAgeRange(), 
            otherCriteria.getAgeRange()
        );
        
        boolean regionMatch = matchesCondition(
            myCriteria.getRegion(),
            otherCriteria.getRegion()
        );

        // 모든 조건이 맞아야 매칭
        return ageMatch && regionMatch;
    }

    /**
     * 조건 매칭 (null이면 무시, 값이 있으면 일치해야 함)
     */
    private boolean matchesCondition(String myCondition, String otherCondition) {
        // 둘 다 null → 매칭 OK
        if (myCondition == null && otherCondition == null) return true;
        
        // 하나만 null → 매칭 OK (선택 조건이므로)
        if (myCondition == null || otherCondition == null) return true;
        
        // 둘 다 값이 있으면 → 일치해야 함
        return myCondition.equals(otherCondition);
    }
    
    private boolean matchesGender(String desired, Users.Gender actual) {
        if ("random".equals(desired)) return true;
        if ("female".equals(desired)) return actual == Users.Gender.FEMALE;
        if ("male".equals(desired)) return actual == Users.Gender.MALE;
        return false;
    }

    /**
     * 매칭 취소 (뒤로가기 / 앱 종료 등)
     */
    public synchronized void cancel(Long userIdx, Users.Gender actualGender) {

        // 매칭조건에 맞는 큐 키 생성
        String queueKey = getQueueKey(actualGender);
        
        // 큐에 있는 모든 사람 리스트
        List<WaitingUser> allUsers = new ArrayList<>();
        
        // 큐에 있는 모든 사람 확인
        while (true) {
            String userJson = redisTemplate.opsForList().leftPop(queueKey); // 큐에서 왼쪽(앞)에서 하나 꺼내기
            if (userJson == null) break; // 큐가 비었으면 종료
            allUsers.add(fromJson(userJson)); // 확인한 사람 리스트에 추가
        }
        
        // 큐에 있는 모든 사람 다시 넣기 (역순으로)
        for (int i = allUsers.size() - 1; i >= 0; i--) {
            WaitingUser user = allUsers.get(i);
            if (!user.getUserIdx().equals(userIdx)) { // 취소한 사람은 큐에 넣지 않음
                // opsForList().rightPush: 큐에 오른쪽(뒤)에 하나 추가
                redisTemplate.opsForList().rightPush(queueKey, toJson(user));
            }
        }
    }
}