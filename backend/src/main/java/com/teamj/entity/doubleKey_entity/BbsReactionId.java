package com.teamj.entity.doubleKey_entity;

import java.io.Serializable;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Embeddable
@NoArgsConstructor
@AllArgsConstructor
@Data
public class BbsReactionId implements Serializable {
    private Long userIdx;
    private Long bbsIdx;
}
