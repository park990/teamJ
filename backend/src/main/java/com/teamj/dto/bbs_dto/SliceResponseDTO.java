package com.teamj.dto.bbs_dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class SliceResponseDTO<T> {
    private List<T> content;
    private boolean hasNext;
}
