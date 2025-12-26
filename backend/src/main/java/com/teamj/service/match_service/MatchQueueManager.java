package com.teamj.service.match_service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Queue;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

import org.springframework.stereotype.Component;

import com.teamj.dto.randomChat_dto.MatchCriteria;
import com.teamj.dto.randomChat_dto.WaitingUser;
import com.teamj.entity.users_entity.Users;

@Component
public class MatchQueueManager {

    /**
     * 🔥 랜덤 매칭 대기열
     *
     * - 아직 상대를 못 만난 유저들이 들어가는 곳
     * - FIFO (먼저 들어온 사람이 먼저 나감)
     * - 서버 메모리에 존재
     */
    // 성별만으로 큐 분리
    private final Map<String, Queue<WaitingUser>> waitingQueues = new ConcurrentHashMap<>();

    /**
     * 매칭 조건에 맞는 큐 가져오기 (없으면 생성)
     */
    private Queue<WaitingUser> getQueue(String desiredGender) {
        String key = desiredGender != null ? desiredGender : "random";
        Queue<WaitingUser> queue = waitingQueues.get(key);
        // 조건에 맞는 큐가 없으면 새로 만들어서 반환
        if (queue == null) {
            queue = new ConcurrentLinkedQueue<>();
            waitingQueues.put(key, queue);
        }
        
        return queue;
    }

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
        // 매칭조건에 맞는 큐 가져오기
        Queue<WaitingUser> targetQueue = getQueue(desiredGender);

        // 큐에서 한 명씩 확인
        List<WaitingUser> checkedUsers = new ArrayList<>();
        WaitingUser matchedUser = null;

        while (!targetQueue.isEmpty()) {
            WaitingUser candidate = targetQueue.poll(); // poll: 큐에서 하나 꺼내기
            checkedUsers.add(candidate); // 확인한 사람 리스트에 추가

            // 양방향 검증
            if (isMatch(me, candidate)) {
                matchedUser = candidate;
                break;
            }
        }

        // 매칭 실패한 사람들 다시 큐에 넣기
        for (WaitingUser user : checkedUsers) {
            if (user != matchedUser) {
                targetQueue.offer(user); // offer: 큐에 하나 추가
            }
        }

        // 매칭 성공 → 상대 유저 인덱스 반환
        if (matchedUser != null) {
            return Optional.of(matchedUser.getUserIdx());
        }

        // 매칭 실패 → 나도 큐에 추가
        targetQueue.offer(me);
        return Optional.empty();
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
    public synchronized void cancel(Long userIdx, String desiredGender) {
        Queue<WaitingUser> queue = getQueue(desiredGender);
        queue.removeIf(waitingUser -> waitingUser.getUserIdx().equals(userIdx));
    }
}