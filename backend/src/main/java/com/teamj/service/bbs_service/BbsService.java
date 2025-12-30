package com.teamj.service.bbs_service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.teamj.dto.PostDTO;
import com.teamj.entity.bbs_entity.Bbs;
import com.teamj.entity.bbs_entity.BbsMedia;
import com.teamj.entity.bbs_entity.BbsMedia.MediaType;
import com.teamj.repository.bbs_repository.BbsRepository;
import com.teamj.util.S3Uploader;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class BbsService {
    private final BbsRepository bbsRepository;
    private final S3Uploader s3Uploader;

    // 게시글 저장
    @Transactional 
    public void savePost(String content, Long userIdx,List<MultipartFile> images){
        
            Bbs bbs = Bbs.create(content, userIdx);
            
            if(images!=null && !images.isEmpty()){
                for(MultipartFile image:images){
                    String imageUrl = s3Uploader.upload(image,"post");
                    log.info("S3에 저장된 이미지 URL: {}", imageUrl);
                    
                    BbsMedia media = BbsMedia.create(null, imageUrl, MediaType.IMAGE);
                    
                    bbs.addMedia(media);
                }
            }
            bbsRepository.save(bbs);
    }

    // 게시글 전부 갖고오기 자유게시판(bbsType) = 1, 삭제 안된것(isDelted) = 0
    @Transactional
    public List<PostDTO> findActivePost(){
       List<Bbs> bbsList = bbsRepository.findByBbsTypeIdxAndIsDeletedOrderByBbsIdxDesc(1L, 0);
        return bbsList.stream().map(bbs -> {
                List<String> imageUrls = bbs.getMedias().stream()
                    //"BbsMedia 클래스 안에 있는 getImageUrl 기능을 갖다 써라"
                    .map(BbsMedia::getImageUrl)
                    .collect(Collectors.toList());

               return PostDTO.builder()
                    .bbsIdx(bbs.getBbsIdx())
                    .bbsTypeIdx(bbs.getBbsType().getBbsTypeIdx())
                    .usersIdx(bbs.getUsersIdx())
                    .content(bbs.getContent())
                    .usersNickname(bbs.getUser().getUsersNickname()) 
                    .viewCount(bbs.getViewCount())
                    .createdAt(bbs.getCreatedAt())
                    .likeCount(bbs.getLikeCount())
                    .commentCount(bbs.getCommentCount())

                    .imgUrls(imageUrls)
                    .build();
                    
        }).collect(Collectors.toList());
    }     
}
