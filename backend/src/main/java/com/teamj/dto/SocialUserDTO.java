package com.teamj.dto;

import java.sql.Date;

import com.teamj.entity.users_entity.Users;
import com.teamj.entity.users_entity.Users.Gender;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class SocialUserDTO {
    private Long usersIdx;
    private String grade;
    private String usersSnsId;
    private String usersName;
    private String usersNickname;
    private String usersGender;
    private String usersAddress;
    private String usersPhone;
    private int usersExit;
    private int isBanned;
    private String provider;
    private String usersEmail;
    private String ci;
    private Date birthDate;

    // 이건 회원가입할때 Service에서 한방에 넣어주기 위한 메서드
    public Users toEntity() {
        Users user = new Users();
        user.setUsersName(this.usersName);
        user.setUsersEmail(this.usersEmail);
        user.setUsersSnsId(this.usersSnsId);
        user.setUsersNickname(this.usersNickname);
        user.setUsersPhone(this.usersPhone);
        user.setBirthDate(this.birthDate);

        // 성별
        if ("0".equals(this.usersGender)) {
            user.setUsersGender(Gender.FEMALE);
        } else {
            user.setUsersGender(Gender.MALE);
        }

        // 등급 
        user.setGrade("와둥이");
        user.setProvider(this.provider);


        // 나중에 핸드폰 인증 CI
        // user.setCi(dto.getCi());

        return user;
    }
}
