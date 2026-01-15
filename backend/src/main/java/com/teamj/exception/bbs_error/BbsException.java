package com.teamj.exception.bbs_error;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public class BbsException extends RuntimeException{
  private final CommentsErrorCode commentsError;
}
