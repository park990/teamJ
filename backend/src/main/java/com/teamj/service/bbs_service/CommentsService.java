package com.teamj.service.bbs_service;

import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.stereotype.Service;

import com.teamj.dto.bbs_dto.CommentsDTO;
import com.teamj.entity.bbs_entity.Bbs;
import com.teamj.entity.bbs_entity.BbsComments;
import com.teamj.entity.users_entity.Users;
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
        return commentsRepository.findAllByBbs_BbsIdxAndIsDeleted(bbsIdx,0, pageable).map(CommentsDTO::new);
    }

    @Transactional
    public void saveComment(CommentsDTO dto){
        Bbs bbs = bbsRepository.findById(dto.getBbsIdx()).orElseThrow(() -> new IllegalArgumentException("해당 게시글이 존재하지 않습니다."));

        Users user = userRepository.findById(dto.getUsersIdx()).orElseThrow(()->new IllegalArgumentException("해당 사용자가 존재하지 않습니다"));

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
