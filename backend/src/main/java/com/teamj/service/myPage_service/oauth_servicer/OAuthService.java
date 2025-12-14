package com.teamj.service.myPage_service.oauth_servicer;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.teamj.dto.OAuthDTO;
import com.teamj.dto.SocialUserDTO;
import com.teamj.entity.users_entity.Users;
import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;
import com.teamj.response.ApiResponse;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class OAuthService {
    private final UserRepository userRepository;

    public ResponseEntity<ApiResponse<?>> kakaoLogin(OAuthDTO oAuthDTO){
    
        SocialUserDTO socialUser = new SocialUserDTO();

        if("KAKAO".equals(oAuthDTO.getProvider())){

            socialUser = getSnsIdFromKakao(oAuthDTO);

            if(socialUser==null){
                System.out.println("유저정보없음");
                return ResponseEntity.badRequest().body(ApiResponse.error("카카오 토큰이 유효하지 않음"));
            }

            System.out.println("여기 실행함!!!!!!!!!!!!!!!!!!!!!");
            System.out.println(socialUser.getUsersSnsId());
            System.out.println(socialUser.getProvider()+"지금 이것은 User user 객체로 받은것이고");
            System.out.println(socialUser.getUsersEmail());  
        }// 이 뒤에 네이버면 네이버 구글이면 구글 else if 로 추가로 걸어주자 

        Map<String,Object> data = new HashMap<>();

        Users isUserExist = new Users();
        isUserExist = userRepository.findByProviderAndUsersSnsId(oAuthDTO.getProvider(), socialUser.getUsersSnsId());
        
        // User가 null이 아니면 기존 유저임
        if(isUserExist!=null){
            String wazzupToken="임시 JWT Token임 브랄라랄ㄹ라랄라";
            data.put("token", wazzupToken);
            return ResponseEntity.ok(ApiResponse.success(data,"로그인 성공"));
        }else{
            data.put("user", socialUser);
            return ResponseEntity.ok(ApiResponse.register(data));
        }
    }

    private SocialUserDTO getSnsIdFromKakao(OAuthDTO dto){
        try{
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization","Bearer " +dto.getSocialToken());
        HttpEntity<String> entity = new HttpEntity<>(null, headers);

        ResponseEntity<Map> response = restTemplate.exchange(
            "https://kapi.kakao.com/v2/user/me",
            HttpMethod.POST,
            entity,
            Map.class
        );
        Map<String,Object> body = response.getBody();
        SocialUserDTO user = new SocialUserDTO();

        if (body == null || body.get("id") == null) {
         throw new IllegalStateException("카카오 응답에 id 없음");
}
        String id = String.valueOf(body.get("id"));
        user.setUsersSnsId(id);
        user.setProvider(dto.getProvider());

        Map<String,Object> kakaoAccount =(Map<String, Object>) body.get("kakao_account");
        if(kakaoAccount!=null && kakaoAccount.get("email")!=null){
            user.setUsersEmail(String.valueOf(kakaoAccount.get("email")));
        }
        
        return user;   
    }catch(Exception e){
        e.printStackTrace();
        return null;
    }
    }
}
