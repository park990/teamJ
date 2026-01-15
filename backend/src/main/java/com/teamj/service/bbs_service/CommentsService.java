package com.teamj.service.bbs_service;

import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.stereotype.Service;

import com.teamj.dto.bbs_dto.CommentsDTO;
import com.teamj.entity.bbs_entity.Bbs;
import com.teamj.entity.bbs_entity.BbsComments;
import com.teamj.entity.users_entity.Users;
import com.teamj.exception.bbs_error.BbsException;
import com.teamj.exception.bbs_error.CommentsErrorCode;
import com.teamj.repository.bbs_repository.BbsRepository;
import com.teamj.repository.bbs_repository.CommentsRepository;
import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CommentsService {
    private final CommentsRepository commentsRepository;
    private final BbsRepository bbsRepository;
    private final UserRepository userRepository;

    public Slice<CommentsDTO> getComments(Long bbsIdx, Pageable pageable){

        // 1. [추가] 게시글이 진짜 있는지, 삭제된 건 아닌지 먼저 확인!
        Bbs bbs = bbsRepository.findById(bbsIdx)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 게시글입니다."));

        // 삭제된 게시글이면 직접 만들어 둔 에러 던지기
        if (bbs.getIsDeleted() == 1) {
            throw new BbsException(CommentsErrorCode.POST_DELETED);
        }
        
        return commentsRepository.findAllByBbs_BbsIdxAndIsDeleted(bbsIdx,0, pageable).map(CommentsDTO::new);
    }

    @Transactional
    public void saveComment(CommentsDTO dto){
        Bbs bbs = bbsRepository.findById(dto.getBbsIdx()).orElseThrow(() -> new IllegalArgumentException("해당 게시글이 존재하지 않습니다."));


        Users user = userRepository.findById(dto.getUsersIdx()).orElseThrow(()->new IllegalArgumentException("해당 사용자가 존재하지 않습니다"));

        // 삭제된 게시글이면 직접 만들어 둔 에러 던지기
        if (bbs.getIsDeleted() == 1) {
            throw new BbsException(CommentsErrorCode.POST_DELETED);
        }
        
        BbsComments parent = null;
        if(dto.getParentIdx() !=null ){
            parent = commentsRepository.findById(dto.getParentIdx()).orElseThrow(()-> new IllegalArgumentException("부모 댓글이 존재하지 않습니다"));
        }

        BbsComments commentEntity = BbsComments.createComment(
        dto.getContent(), 
        bbs, 
        user, 
        parent
    );
        commentsRepository.save(commentEntity);
    }
}
