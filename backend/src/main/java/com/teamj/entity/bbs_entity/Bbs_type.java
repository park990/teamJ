package com.teamj.entity.bbs_entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
@Table(name = "Bbs_type")
public class Bbs_type {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long bbsTypeIdx;

    @Column(nullable = false)
    private String name;

    @Column
    private String description;
}
