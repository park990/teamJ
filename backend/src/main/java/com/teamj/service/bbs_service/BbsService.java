package com.teamj.service.bbs_service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.teamj.dto.bbs_dto.PostDTO;
import com.teamj.dto.bbs_dto.LikeToggleDTO;
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
    public void savePost(String content, Long userIdx, List<MultipartFile> images) {

        Bbs bbs = Bbs.create(content, userIdx);

        if (images != null && !images.isEmpty()) {
            for (MultipartFile image : images) {
                String imageUrl = s3Uploader.upload(image, "post");
                log.info("S3에 저장된 이미지 URL: {}", imageUrl);

                BbsMedia media = BbsMedia.create(null, imageUrl, MediaType.IMAGE);

                bbs.addMedia(media);
            }
        }
        bbsRepository.save(bbs);
    }

    // 게시글 전부 갖고오기 자유게시판(bbsType) = 1, 삭제 안된것(isDelted) = 0
    @Transactional
    public Slice<PostDTO> findActivePost(Long userIdx, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Slice<Bbs> bbsSlice = bbsRepository.findByBbsTypeIdxAndIsDeletedOrderByBbsIdxDesc(1L, 0,pageable);
        return bbsSlice.map(bbs -> {
            List<String> imageUrls = bbs.getMedias().stream()
                    // "BbsMedia 클래스 안에 있는 getImageUrl 기능을 갖다 써라"
                    .map(BbsMedia::getImageUrl)
                    .collect(Collectors.toList());

            boolean isLiked = false;
            if (userIdx != null) {
                BbsReactionId reactionId = new BbsReactionId(userIdx, bbs.getBbsIdx());

                // 존재 하면 true 존재 안하면 false
                isLiked = bbsReactionRepository.existsById(reactionId);
                // System.out.println(bbs.getBbsIdx()+"글에 대한" +userIdx+"님의 좋아요 여부에 관해
                // "+isLiked);
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

        });
    }

    // 좋아요 토글 기능
    @Transactional
    public LikeToggleDTO toggleLike(Long bbsIdx, Long userIdx) {

        BbsReactionId reactionId = new BbsReactionId(userIdx, bbsIdx);
        Optional<BbsReaction> existReaction = bbsReactionRepository.findById(reactionId);

        Bbs bbs = bbsRepository.findById(bbsIdx)
                .orElseThrow(() -> new IllegalArgumentException("게시글 없음"));

        boolean isLiked;

        if (existReaction.isPresent()) {
            bbsReactionRepository.delete(existReaction.get());
            bbs.decreaseLikeCount();
            isLiked = false;
        } else {
            Users user = userRepository.getReferenceById(userIdx);
            BbsReaction newReaction = new BbsReaction(user, bbs, 1);
            bbsReactionRepository.save(newReaction);
            bbs.increaseLikeCount();
            isLiked = true;
        }

        return new LikeToggleDTO(
                isLiked,
                bbs.getLikeCount());
    }

    @Transactional
    public boolean deletePost(Long postIdx, Long userIdx){
        Bbs bbs = bbsRepository.findById(postIdx)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 게시글입니다."));
        
        // 2. 권한 확인 (작성자와 요청자가 같은지)
        if(!bbs.getUsersIdx().equals(userIdx)){
            // 권한이 없으면 false 반환하거나 예외를 던짐
            throw new IllegalArgumentException("본인의 게시글만 삭제할 수 있습니다.");
        }
        bbs.changeDeletionState();
        return true;
    }
}
