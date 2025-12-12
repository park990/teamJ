package com.teamj.entity.users_entity;

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
@Table(name="users")
public class Users {
    // Gender Enum 값 정의 해준거임.
    public enum Gender{
        MALE, FEMALE
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long usersIdx;
    
    @Column(nullable = false)
    private String grade;
    
    @Column
    private String usersEmail;
    
    @Column
    private String usersPwd;
    
    @Column
    private String usersName;
    
    @Column
    private String usersNickName;
    
    @Column
    @Enumerated(EnumType.STRING)
    private Gender usersGender;
    
    @Column
    private String usersAddress;
    
    @Column
    private String usersPhone;
    
    @Column
    private int usersExit;
    
    @Column
    private int isBanned;
    
    @Column
    private String platform;
    
}
