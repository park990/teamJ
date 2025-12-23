package com.teamj.entity.bbs_entity;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

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
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "comments")
@Getter
@Setter
@NoArgsConstructor
public class BbsComments {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long commentIdx;

    private String content;

    // 부모 댓글 (어떤 댓글의 대댓글인지)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_idx")
    private BbsComments parent;

    // 자식 댓글들 (이 댓글에 달린 대댓글 목록)
    @OneToMany(mappedBy = "parent", cascade = CascadeType.ALL)
    private List<BbsComments> children = new ArrayList<>();

    // 게시글과의 연관관계
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bbs_idx")
    private Bbs bbs;

    // 작성자와의 연관관계
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "users_idx")
    private Users users;

    @Column(name = "is_deleted")
    private int isDeleted;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
