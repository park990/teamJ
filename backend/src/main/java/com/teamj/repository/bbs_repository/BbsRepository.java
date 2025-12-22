package com.teamj.repository.bbs_repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.teamj.entity.bbs_entity.Bbs;

@Repository
public interface BbsRepository extends JpaRepository<Bbs,Long>{
    List<Bbs> findByBbsTypeIdxAndIsDeletedOrderByBbsIdxDesc(Long bbsType, Integer isDeleted);
}
