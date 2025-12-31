package com.teamj.repository.bbs_repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.teamj.entity.bbs_entity.BbsReaction;
import com.teamj.entity.doubleKey_entity.BbsReactionId;

@Repository
public interface BbsReactionRepository extends JpaRepository<BbsReaction,BbsReactionId>{

    // 복합키 userReaction테이블에 user_idx와 bbs_idx를 통해 찾는 메서드.
    boolean existsById(BbsReactionId id);
}
