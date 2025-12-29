package com.teamj.repository.bbs_repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.teamj.entity.bbs_entity.BbsMedia;

@Repository
public interface BbsMediaRepository extends JpaRepository<BbsMedia,Long>{
    
}
