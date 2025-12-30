package com.teamj.service.myPage_service.oauth_service;
import java.util.concurrent.TimeUnit;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import com.teamj.dto.OAuthDTO;
import com.teamj.dto.SocialUserDTO;
import com.teamj.dto.UserDTO;
import com.teamj.dto.WazzupTokenDTO;
import com.teamj.dto.response.ApiResponse;
import com.teamj.entity.users_entity.Users;
import com.teamj.jwt.JwtTokenProvider;
import com.teamj.repository.myPage_repository.signUp_repository.UserRepository;
import com.teamj.service.myPage_service.oauth_service.social.GetFromSocialService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {
    private final UserRepository userRepository;
    private final JwtTokenProvider jwtTokenProvider;
    private final StringRedisTemplate redisTemplate;
    private final GetFromSocialService getFromSocialService;



    // 자동로그인 때 토큰으로 유저정보 얻어오기
    public ResponseEntity<ApiResponse<?>> getUserMe(Long userIdx) {
        try {
            // 1. DB에서 유저 정보 조회
            Users user = userRepository.findById(userIdx)
                    .orElseThrow(() -> new RuntimeException("존재하지 않는 유저입니다."));

            // 2. 응답용 DTO 생성 (토큰을 제외한 순수 정보만)
            UserDTO userInfo = UserDTO.builder()
                    .usersIdx(user.getUsersIdx())
                    .usersNickname(user.getUsersNickname())
                    .grade(user.getGrade())
                    .build();
            
            log.info("front상태 저장위해 user {} 정보 전달",userInfo.getUsersNickname());

            // 3. ApiResponse.success로 감싸서 반환
            return ResponseEntity.ok(ApiResponse.success(userInfo, "유저 정보 조회 성공"));

        } catch (Exception e) {
            log.error("유저 정보 조회 에러: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("인증 정보가 유효하지 않습니다."));
        }
    }



    public ResponseEntity<ApiResponse<?>> socialLogin(OAuthDTO oAuthDTO) {
        SocialUserDTO socialUser = new SocialUserDTO();
        
        // 카카오 api 요청 유저 정보 얻어오기
        if ("KAKAO".equals(oAuthDTO.getProvider())) {
            
            socialUser = getFromSocialService.getFromKakao(oAuthDTO);
            
            // 카카오 유저정보 요청 불가
            if (socialUser == null) {
                System.out.println("유저정보없음");
                return ResponseEntity.badRequest().body(ApiResponse.error("카카오 토큰이 유효하지 않음"));
            }
            
        } // 이 뒤에 네이버면 네이버 구글이면 구글 else if 로 추가로 걸어주자
        
        // 이 유저가 기존유저인지 신규 유저인지 일단 DB를 들름.
        Users isUserExist = new Users();
        isUserExist = userRepository.findByProviderAndUsersEmail(oAuthDTO.getProvider(), socialUser.getUsersEmail());

        // User가 null이 아니면 기존 유저임
        if (isUserExist != null) {

            // accessToken 생성
            String accessToken = jwtTokenProvider.createAccessToken(isUserExist.getUsersIdx());

            // refreshToken 생성
            String refreshToken = jwtTokenProvider.createRefreshToken(isUserExist.getUsersIdx());
            
            // 레디스에 리프레쉬 토큰 저장
            redisTemplate.opsForValue().set(
                    "RT:" + isUserExist.getUsersIdx(),
                    refreshToken,
                    7,
                    TimeUnit.DAYS);
            
            // 기존유저는 토큰과 함꼐 유저의 간단한 정보 전달(닉네임이나 idx는 상시로 필요로 함으로 전달해서 프론트에 넣어두자.)
            WazzupTokenDTO tokenDTO = WazzupTokenDTO.builder()
                    .wazzupToken(accessToken)
                    .refreshToken(refreshToken)
                    .usersIdx(isUserExist.getUsersIdx())
                    .usersNickname(isUserExist.getUsersNickname())
                    .grade(isUserExist.getGrade())
                    .build();

            return ResponseEntity.ok(ApiResponse.success(tokenDTO, "로그인 성공"));
        } else {
            return ResponseEntity.ok(ApiResponse.register(socialUser));
        }
    }


    // 로그아웃
    public void logout(String accessToken) {
        Long userIdx = jwtTokenProvider.getuserIdx(accessToken);

        String key = "RT:" + userIdx;

        if (redisTemplate.opsForValue().get(key) != null) {
            redisTemplate.delete(key);
            log.info("유저 {}의 refresh토큰(RT) 삭제 완료, 로그아웃 완료", userIdx);
        } else {
            log.info("유저 {}의 refresh토큰 없거나 만료.", userIdx);
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
        log.info("토큰 재발급 완료");

        return ResponseEntity.ok(ApiResponse.success(tokenDTO, "토큰 재발급 성공"));
    }
}
