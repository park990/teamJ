package com.teamj.entity.bbs_entity; // 패키지 경로는 상황에 맞게 수정

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
@Table(name = "bbs_media")
public class BbsMedia {

    public enum MediaType {
        IMAGE,
        VIDEO
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "media_idx")
    private Long mediaIdx;

    
    @Column(name = "image_url", nullable = false, columnDefinition = "TEXT")
    private String imageUrl;
    
    @Enumerated(EnumType.STRING) // DB에 'IMAGE', 'VIDEO' 문자열로 저장됨
    @Column(name = "image_type", columnDefinition = "ENUM('VIDEO', 'IMAGE')") 
    private MediaType imageType;
    
    public static BbsMedia create(Bbs bbs, String imageUrl, MediaType imageType) {
        if (imageUrl == null || imageUrl.isBlank()) {
            throw new IllegalArgumentException("이미지 URL은 필수입니다.");
        }
        
        BbsMedia bbsMedia = new BbsMedia();
        bbsMedia.bbs=bbs;
        bbsMedia.imageUrl=imageUrl;
        bbsMedia.imageType=imageType;
        // 생성자를 호출해서 반환
        return bbsMedia;
    }
    
    // Bbs와 연결 (FK: bbs_idx)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bbs_idx", nullable = false)
    private Bbs bbs;

    public void setBbs(Bbs bbs){
        this.bbs=bbs;
    }
}