package com.teamj.repository.myPage_repository.signUp_repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.teamj.entity.users_entity.Users;

@Repository
public interface UserRepository extends JpaRepository<Users,Long>{
    
    // 닉네임 중복 확인
    boolean existsByUsersNickName(String nickName);

    // 현 플랫폼으로 가입을 한 기록이 있는지
    Users findByProviderAndUsersSnsId(String provider, String SnsId);
}
