package com.teamj.service.bbs_service;

import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.stereotype.Service;

import com.teamj.dto.bbs_dto.CommentsDTO;
import com.teamj.repository.bbs_repository.CommentsRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CommentsService {
    private final CommentsRepository commentsRepository;

    public Slice<CommentsDTO> getComments(Long bbsIdx, Pageable pageable){
        return commentsRepository.findAllByBbs_BbsIdxAndIsDeleted(bbsIdx,0, pageable).map(CommentsDTO::new);
    }
}
