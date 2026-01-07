package com.teamj.repository.bbs_repository;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.teamj.entity.bbs_entity.BbsComments;

@Repository
public interface CommentsRepository extends JpaRepository<BbsComments,Long> {
    Slice<BbsComments> findAllByBbsIdxAndIsDeleted(Long bbsIdx,int isDeleted, Pageable Pageable);
}
