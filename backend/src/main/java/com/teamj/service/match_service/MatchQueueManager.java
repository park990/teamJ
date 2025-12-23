package com.teamj.service.match_service;

import java.util.Map;
import java.util.Optional;
import java.util.Queue;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

import org.springframework.stereotype.Component;

@Component
public class MatchQueueManager {

    /**
     * 🔥 랜덤 매칭 대기열
     *
     * - 아직 상대를 못 만난 유저들이 들어가는 곳
     * - FIFO (먼저 들어온 사람이 먼저 나감)
     * - 서버 메모리에 존재
     */
    // 성별 옵션별로 큐 분리
    private final Map<String, Queue<Long>> waitingQueues = new ConcurrentHashMap<>();

    // 성별 옵션별로 큐 가져오기, 없으면 새로 만들기
    private Queue<Long> getQueue(String genderOption) {
        String key = genderOption != null ? genderOption : "random";
        
        Queue<Long> queue = waitingQueues.get(key);
        if (queue == null) {
            queue = new ConcurrentLinkedQueue<>();
            waitingQueues.put(key, queue);
        }
        return queue;
    }

    /**
     * 랜덤 매칭 시도
     *
     * @param userIdx 현재 매칭을 요청한 유저
     * @param genderOption 추후 성별 매칭용 (지금은 사용 안 함)
     *
     * @return
     *  - Optional.of(상대 userIdx) → 매칭 성공
     *  - Optional.empty() → 아직 대기
     */
    public synchronized Optional<Long> tryMatch(
        Long userIdx,
        String genderOption
    ) {
        /**
         * synchronized 사용 이유
         * ------------------
         * 동시에 여러 요청이 들어오면
         * - 두 명이 동시에 queue.peek()
         * - 같은 유저를 매칭해버리는 문제 발생
         *
         * 👉 한 번에 한 스레드만 매칭 로직 실행
         */

        // genderOption에 맞는 큐 가져오기
        Queue<Long> targetQueue = getQueue(genderOption);

        // 1️⃣ 이미 대기 중인 사람이 있는지 확인
        Long waitingUser = targetQueue.poll();

        if (waitingUser != null) {
            /**
             * 큐에 누군가 있었다
             * → 그 사람은 이제 대기열에서 빠지고
             * → 현재 userIdx와 매칭됨
             */
            return Optional.of(waitingUser);
        }

        /**
         * 2️⃣ 대기 중인 사람이 없었다
         * → 현재 유저를 큐에 넣고 대기 상태로 전환
         */
        targetQueue.offer(userIdx);

        return Optional.empty();
    }

    /**
     * 매칭 취소 (뒤로가기 / 앱 종료 등)
     */
    public synchronized void cancel(Long userIdx, String genderOption) {
        Queue<Long> queue = getQueue(genderOption);
        queue.remove(userIdx);
    }
}