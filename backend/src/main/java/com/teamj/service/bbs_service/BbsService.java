package com.teamj.service.bbs_service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.teamj.dto.PostDTO;
import com.teamj.entity.bbs_entity.Bbs;
import com.teamj.repository.bbs_repository.BbsRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class BbsService {
    private final BbsRepository bbsRepository;

    // 게시글 저장
    @Transactional 
    public boolean savePost(PostDTO dto, Long userIdx){


        try{
            Bbs bbs = new Bbs();
            bbs.setUsersIdx(userIdx);
            bbs.setTitle(dto.getTitle());
            bbs.setContent(dto.getContent());
            bbs.setBbsTypeIdx(1L);
            bbsRepository.save(bbs);
            return true;
        }catch(Exception e){
            log.error("글 저장 중 오류발생: {} ",e.getMessage());
            return false;
        }
    }

    // 게시글 전부 갖고오기 자유게시판(bbsType) = 1, 삭제 안된것(isDelted) = 0
    @Transactional
    public List<PostDTO> findActivePost(){
       List<Bbs> bbsList = bbsRepository.findByBbsTypeIdxAndIsDeletedOrderByBbsIdxDesc(1L, 0);
        return bbsList.stream().map(bbs -> {

               return PostDTO.builder()
                    .bbsIdx(bbs.getBbsIdx())
                    .bbsTypeIdx(bbs.getBbsType().getBbsTypeIdx())
                    .usersIdx(bbs.getUsersIdx())
                    .title(bbs.getTitle())
                    .content(bbs.getContent())
                    .usersNickname(bbs.getUser().getUsersNickname()) 
                    .viewCount(bbs.getViewCount())
                    .createdAt(bbs.getCreatedAt())
                    .likeCount(bbs.getLikeCount())    
                    .commentCount(bbs.getCommentCount()) //
                    .build();
        }).collect(Collectors.toList());
    }     
}
