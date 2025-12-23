package com.teamj.entity.bbs_entity;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.hibernate.annotations.Formula;
import org.springframework.data.annotation.CreatedDate;
import com.teamj.entity.users_entity.Users;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Table(name = "bbs")
public class Bbs {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // 자동증가
    private Long bbsIdx;

    @Column(name = "users_idx", nullable = false)
    private Long usersIdx;

    // User와 조인
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "users_idx", insertable = false, updatable = false)
    private Users user;

    @Column(name = "bbs_type_idx", nullable = false)
    private Long bbsTypeIdx;

    // 게시판 종류 조인 읽기전용
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bbs_type_idx", insertable = false, updatable = false)
    private BbsType bbsType;

    // 좋아요 및 싫어요 조인
    @OneToMany(mappedBy = "bbs", fetch = FetchType.LAZY)
    private List<BbsReaction> reactions = new ArrayList<>();

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(columnDefinition = "integer default 0")
    private Integer viewCount = 0;

    @Column(nullable = false)
    private int isDeleted;

    @CreatedDate // 생성 시 자동 저장
    @Column(updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    // 날짜 자동
    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now(); // 수정일만 현재 시간으로 갱신
    }

    @OneToMany(mappedBy = "bbs", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("createdAt ASC") // 댓글을 작성순으로 정렬
    private List<BbsComments> comments = new ArrayList<>();


    // 댓글 갯수 가져오기
    @Formula("(SELECT COUNT(*) FROM comments c WHERE c.bbs_idx = bbs_idx AND c.is_deleted = 0)")
    private int commentCount;

    // 좋아요 갯수 가져오기
    @Formula("(SELECT COUNT(*) FROM bbs_reaction r WHERE r.bbs_idx = bbs_idx AND r.reaction_type = 1)")
    private int likeCount;

}
