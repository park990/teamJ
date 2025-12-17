package com.teamj.service.myPage_service.oauth_servicer;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.teamj.dto.OAuthDTO;
import com.teamj.dto.SocialUserDTO;
import com.teamj.dto.WazzupTokenDTO;
import com.teamj.entity.users_entity.Users;
import com.teamj.jwt.JwtTokenProvider;
import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;
import com.teamj.response.ApiResponse;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class OAuthService {
    private final UserRepository userRepository;
    private final JwtTokenProvider jwtTokenProvider;
    private final StringRedisTemplate redisTemplate;

    public ResponseEntity<ApiResponse<?>> socialLogin(OAuthDTO oAuthDTO) {

        SocialUserDTO socialUser = new SocialUserDTO();

        // 이 유저가 기존유저인지 신규 유저인지 일단 DB를 들름.
        if ("KAKAO".equals(oAuthDTO.getProvider())) {

            socialUser = getFromKakao(oAuthDTO);

            if (socialUser == null) {
                System.out.println("유저정보없음");
                return ResponseEntity.badRequest().body(ApiResponse.error("카카오 토큰이 유효하지 않음"));
            }

        } // 이 뒤에 네이버면 네이버 구글이면 구글 else if 로 추가로 걸어주자

        Users isUserExist = new Users();
        isUserExist = userRepository.findByProviderAndUsersEmail(oAuthDTO.getProvider(), socialUser.getUsersEmail());

        // User가 null이 아니면 기존 유저임
        if (isUserExist != null) {

            // accessToken 생성
            String accessToken = jwtTokenProvider.createAccessToken(isUserExist.getUsersIdx());

            // refreshToken 생성
            String refreshToken = jwtTokenProvider.createRefreshToken(isUserExist.getUsersIdx());

            redisTemplate.opsForValue().set(
                    "RT:" + isUserExist.getUsersIdx(),
                    refreshToken,
                    7,
                    TimeUnit.DAYS);

            WazzupTokenDTO tokenDTO = WazzupTokenDTO.builder()
                    .wazzupToken(accessToken)
                    .refreshToken(refreshToken)
                    .build();

            return ResponseEntity.ok(ApiResponse.success(tokenDTO, "로그인 성공"));
        } else {
            return ResponseEntity.ok(ApiResponse.register(socialUser));
        }
    }

    // 소셜 토큰으로 카카오 정보 갖고오기
    private SocialUserDTO getFromKakao(OAuthDTO dto) {
        try {
            RestTemplate restTemplate = new RestTemplate();

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

    // 로그아웃
    public void logout(String accessToken) {
        Long userIdx = jwtTokenProvider.getuserIdx(accessToken);

        String key = "RT:" + userIdx;

        if (redisTemplate.opsForValue().get(key) != null) {
            redisTemplate.delete(key);
            log.info("유자 {}의 refresh토큰(RT) 삭제 완료, 로그아웃 완료", userIdx);
        } else {
            log.info("유자 {}의 refresh토큰 없거나 만료.", userIdx);
        }
    }

    // 토큰 재발급
    public ResponseEntity<ApiResponse<?>> reissueAccessToken(String refreshToken) {
        if (!jwtTokenProvider.validateToken(refreshToken)) {
            return ResponseEntity.status(401).body(ApiResponse.error("RefreshToken이 만료되었거나 유효하지 않습니다"));
        }

        // 구형 리프레쉬 토큰으로 사용자 정보 갖고오기
        Authentication authentication = jwtTokenProvider.getAuthentication(refreshToken);
        String userIdx = authentication.getName();

        // 사용자 정보로 레디스에서 리프레쉬 토큰 뽑기
        String redisKey = "RT:" + userIdx;
        String savedRefreshToken = redisTemplate.opsForValue().get(redisKey);

        // 사용자 정보로된 리프레쉬 토큰 없으면 오류 리턴
        if (savedRefreshToken == null || !savedRefreshToken.equals(refreshToken)) {
            return ResponseEntity.status(401).body(ApiResponse.error("RefreshToken이 일치하지 않거나 이미 삭제되었음"));
        }

        // 사용자 정보로 다시 토큰 생성
        String newAccessToken = jwtTokenProvider.createAccessToken(Long.parseLong(userIdx));
        String newRefreshToken = jwtTokenProvider.createRefreshToken(Long.parseLong(userIdx));

        // 다시 레디스에 리프레쉬만 저장
        redisTemplate.opsForValue().set(redisKey, newRefreshToken, 7, TimeUnit.DAYS);

        // 토큰 dto에 set해준 후 프론트에 전달
        WazzupTokenDTO tokenDTO = WazzupTokenDTO.builder()
                .wazzupToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .build();

        return ResponseEntity.ok(ApiResponse.success(tokenDTO, "토큰 재발급 성공"));
    }
}
