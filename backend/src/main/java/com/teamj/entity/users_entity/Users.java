package com.teamj.entity.users_entity;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

import com.teamj.entity.bbs_entity.BbsComments;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Table(name = "users", uniqueConstraints = {
        @UniqueConstraint(name = "sns_oauth_unique", // 제약조건 이름 (아무거나)
                columnNames = { "provider", "usersEmail" })
})
public class Users {
    // Gender Enum 값 정의 해준거임.
    public enum Gender {
        MALE, FEMALE
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long usersIdx;

    @Column(nullable = false)
    private String grade;

    @Column
    private String usersSnsId;

    @Column
    private Date birthDate;

    @Column
    private String usersName;

    @Column(unique = true, nullable = false)
    private String usersNickname;

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
    private String provider;

    @Column
    private String usersEmail;

    @OneToMany(mappedBy = "users")
    private List<BbsComments> comments = new ArrayList<>();

}
