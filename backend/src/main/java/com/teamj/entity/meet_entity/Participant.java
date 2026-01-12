package com.teamj.entity.meet_entity;

import com.teamj.entity.doubleKey_entity.ParticipantId;
import com.teamj.entity.users_entity.Users;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Table(name = "participant")
public class Participant {
    
    @EmbeddedId
    @Builder.Default
    private ParticipantId id = new ParticipantId();

    @MapsId("roomIdx")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="room_idx")
    private MeetRoom room;

    @MapsId("usersIdx")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "users_idx")
    private Users user;

    @Column
    private String usersRole;
    
    @Column
    private String isOuted;
}
