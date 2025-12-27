package com.teamj.service.myPage_service.oauth_service.social;

import java.util.Map;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.teamj.dto.OAuthDTO;
import com.teamj.dto.SocialUserDTO;

@Service
public class GetFromSocialService {
    
    private final RestTemplate restTemplate = new RestTemplate();

    public SocialUserDTO getFromKakao(OAuthDTO dto) {
        try {

            HttpHeaders headers = new HttpHeaders();
            headers.add("Authorization", "Bearer " + dto.getSocialToken());
            HttpEntity<String> entity = new HttpEntity<>(null, headers);

            ResponseEntity<Map> response = restTemplate.exchange(
                    "https://kapi.kakao.com/v2/user/me",
                    HttpMethod.POST,
                    entity,
                    Map.class);
            Map<String, Object> body = response.getBody();
            SocialUserDTO user = new SocialUserDTO();

            if (body == null || body.get("id") == null) {
                throw new IllegalStateException("카카오 응답에 id 없음");
            }
            String id = String.valueOf(body.get("id"));
            user.setUsersSnsId(id);
            user.setProvider(dto.getProvider());

            Map<String, Object> kakaoAccount = (Map<String, Object>) body.get("kakao_account");
            if (kakaoAccount != null && kakaoAccount.get("email") != null) {
                user.setUsersEmail(String.valueOf(kakaoAccount.get("email")));
            }

            return user;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
