package com.teamj.service.bbs_service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.teamj.dto.PostDTO;
import com.teamj.entity.bbs_entity.Bbs;
import com.teamj.entity.bbs_entity.BbsMedia;
import com.teamj.entity.bbs_entity.BbsReaction;
import com.teamj.entity.bbs_entity.BbsMedia.MediaType;
import com.teamj.entity.doubleKey_entity.BbsReactionId;
import com.teamj.entity.users_entity.Users;
import com.teamj.repository.bbs_repository.BbsReactionRepository;
import com.teamj.repository.bbs_repository.BbsRepository;
import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;
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
    private final BbsReactionRepository bbsReactionRepository;
    private final UserRepository userRepository;

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
    public List<PostDTO> findActivePost(Long userIdx){
       List<Bbs> bbsList = bbsRepository.findByBbsTypeIdxAndIsDeletedOrderByBbsIdxDesc(1L, 0);
        return bbsList.stream().map(bbs -> {
                List<String> imageUrls = bbs.getMedias().stream()
                    //"BbsMedia 클래스 안에 있는 getImageUrl 기능을 갖다 써라"
                    .map(BbsMedia::getImageUrl)
                    .collect(Collectors.toList());
                
                boolean isLiked = false;
                if(userIdx != null){
                    BbsReactionId reactionId = new BbsReactionId(userIdx, bbs.getBbsIdx());

                    //존재 하면 true 존재 안하면 false
                    isLiked = bbsReactionRepository.existsById(reactionId);
                    System.out.println(bbs.getBbsIdx()+"글에 대한" +userIdx+"님의 좋아요 여부에 관해 "+isLiked);
                }


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

                    // 지금 이사용자가 불러오는 게시글에 좋아요를 눌렀는지 안눌렀는지 확인하기 위함.
                    .isLiked(isLiked)
                    .build();
                    
        }).collect(Collectors.toList());
    }
    
    // 좋아요 토글 기능
    @Transactional
    public boolean toggleLike(Long bbsIdx, Long userIdx){
        System.out.println("bbsIdx는"+bbsIdx+"그리고 userIdx는"+userIdx);
        // 복합키 객체 생성
        BbsReactionId reactionId = new BbsReactionId(userIdx, bbsIdx); 

        // DB조회
        Optional<BbsReaction> existReation = bbsReactionRepository.findById(reactionId);

        //bbs 게시글 리스트 불러올때 전체 카운트 다시 들고 오기 위해서
        Bbs bbs = bbsRepository.findById(bbsIdx).orElseThrow( () -> new IllegalArgumentException("게시글 없음"));

        if(existReation.isPresent()){
            bbsReactionRepository.delete(existReation.get());
            
            // like 감소 로직이 있어야 하나??
            bbs.decreaseLikeCount();

            return false;
        }else{

            // BbsReaction 안에 User라는 객체로 저장해놔서 user라는 객체로 넣어줘야함. 단 refrenceBy로 들고와서 DB를 들렀다오는게 아님, 임시 user객체임.
            Users user = userRepository.getReferenceById(userIdx);
            
            // BbsReaction 안에 setter를 정의 안해놨기 때문에 생성자 정의 해둔것으로 넣어둠.
            BbsReaction newReaction = new BbsReaction(user, bbs, 1);
            bbsReactionRepository.save(newReaction);
            
            // likeCount 증가 로직 있어야 하나??
            bbs.increaseLikeCount();
            
            return true;
        }

    }
}
