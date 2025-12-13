package com.teamj.service.myPage_service.signUp_service;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.teamj.dto.SignUpDTO;
import com.teamj.entity.users_entity.Users;
import com.teamj.entity.users_entity.Users.Gender;
import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    // 회원가입 닉네임 중복 체크
    public Boolean existsByNickName(String nickName){
        return userRepository.existsByUsersNickName(nickName);
    }

    // 회원가입 db 저장
    @Transactional
    public boolean registerUser(SignUpDTO dto){
        Users user = new Users();
        user.setUsersName(dto.getName());
        user.setUsersNickName(dto.getNickname());
        user.setUsersPhone(dto.getPhoneNumber());
        // user.setUserbirth(dto.getBirthDate());
        if("0".equals(dto.getGender())){
            user.setUsersGender(Gender.FEMALE);
        }else{
            user.setUsersGender(Gender.MALE);
        }
        user.setGrade("와둥이");
        // user.setPlatform(dto.getPlatform());
        // user.setCi(dto.getCi());

        try{
            userRepository.save(user);
            return true;
        }catch(DataIntegrityViolationException e){
            System.out.println("중복된 닉네임이 들어옴");
            return false;
        }
    }
}
