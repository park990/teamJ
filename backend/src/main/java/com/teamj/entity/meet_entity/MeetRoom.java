package com.teamj.entity.meet_entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name="meet_room")
public class MeetRoom {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // 자동증가
    private Long roomIdx;

    @Column(nullable = false)
    private String roomName;

    @Column(nullable = false)
    private String roomType;

    @Column
    private LocalDateTime createdAt;

    @Column
    private LocalDateTime meetDate;

    @Column
    private String meetPlace;

    @Column
    private int max;

    @Column
    private String roomImg;

    @Column(columnDefinition = "TEXT")
    private String roomDesc;

}
