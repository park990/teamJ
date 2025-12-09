package com.teamj.entity.user_entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
@Table(name="User")
public class User {
    // Gender Enum 값 정의 해준거임.
    public enum Gender{
        MALE, FEMALE
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long userIdx;
    
    @Column(nullable = false)
    private String grade;
    
    @Column
    private String userEmail;
    
    @Column
    private String userPwd;
    
    @Column
    private String userName;
    
    @Column
    private String userNickName;
    
    @Column
    @Enumerated(EnumType.STRING)
    private Gender userGender;
    
    @Column
    private String userAddress;
    
    @Column
    private String userPhone;
    
    @Column
    private int userExit;
    
    @Column
    private int isBanned;
    
    @Column
    private String platform;
    
}
