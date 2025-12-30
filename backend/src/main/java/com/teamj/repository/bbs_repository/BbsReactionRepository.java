package com.teamj.repository.bbs_repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.teamj.entity.bbs_entity.Bbs;
import com.teamj.entity.bbs_entity.BbsReaction;
import com.teamj.entity.doubleKey_entity.BbsReactionId;

@Repository
public interface BbsReactionRepository extends JpaRepository<BbsReaction,BbsReactionId>{
    int countcountBy(Bbs bbs);
}
