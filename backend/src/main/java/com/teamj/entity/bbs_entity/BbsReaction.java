package com.teamj.entity.bbs_entity;

import com.teamj.entity.doubleKey_entity.BbsReactionId;
import com.teamj.entity.users_entity.Users;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@NoArgsConstructor
@Getter
@Table(name = "bbs_reaction")
public class BbsReaction {
    
    @EmbeddedId
    private BbsReactionId id = new BbsReactionId();

    @MapsId("userIdx")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="users_idx")
    private Users user;

    @MapsId("bbsIdx")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bbs_idx")
    private Bbs bbs;

    @Column
    private int reactionType;
    
}
