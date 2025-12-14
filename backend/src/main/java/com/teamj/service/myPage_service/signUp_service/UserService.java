package com.teamj.service.myPage_service.signUp_service;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.teamj.dto.SocialUserDTO;
import com.teamj.entity.users_entity.Users;
import com.teamj.entity.users_entity.Users.Gender;
import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    // 회원가입 닉네임 중복 체크
    public Boolean existsByNickName(String nickName) {
        return userRepository.existsByUsersNickName(nickName);
    }

    // 회원가입 db 저장
    @Transactional
    public boolean registerUser(SocialUserDTO dto) {

        if (userRepository.existsByUsersNickName(dto.getUsersNickName())) {
            return false; // "응, 중복
        }
        Users user = new Users();
        user.setUsersName(dto.getUsersName());
        user.setUsersNickName(dto.getUsersNickName());
        user.setUsersPhone(dto.getUsersPhone());
        // user.setUserbirth(dto.getBirthDate());
        if ("0".equals(dto.getUsersGender())) {
            user.setUsersGender(Gender.FEMALE);
        } else {
            user.setUsersGender(Gender.MALE);
        }
        user.setGrade("와둥이");
        // user.setPlatform(dto.getPlatform());
        // user.setCi(dto.getCi());

        userRepository.save(user);
        return true;

    }
}
