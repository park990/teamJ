package com.teamj.repository.bbs_repository;


import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.teamj.entity.bbs_entity.Bbs;

@Repository
public interface BbsRepository extends JpaRepository<Bbs,Long>{
    Slice<Bbs> findByBbsTypeIdxAndIsDeletedOrderByBbsIdxDesc(Long bbsType, Integer isDeleted, Pageable pageable);
}
