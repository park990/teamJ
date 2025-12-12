package com.teamj.service.myPage_service.signUp_service;

import org.springframework.stereotype.Service;

import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    public Boolean existsByNickName(String nickName){
        return userRepository.existsByUsersNickName(nickName);
    }
}
