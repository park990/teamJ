package com.teamj.config;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import com.teamj.jwt.JwtAuthenticationFilter;
import com.teamj.jwt.JwtTokenProvider;
import lombok.RequiredArgsConstructor;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {


    private final JwtTokenProvider jwtTokenProvider;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // 1. 모바일 앱은 보통 csrf를 끔
            .csrf(csrf -> csrf.disable())
            
            // CORS 설정 (다른 컴퓨터에서 접근 허용)
            // 당장은 앱에서만 접근하는거라 cors 설정 삭제해도 상관 X 걍 이미 쓴거 지우기 아까워서 냅둠ㅁㄴㅇ
            .cors(cors -> cors.configurationSource(request -> {
                var corsConfig = new org.springframework.web.cors.CorsConfiguration();
                corsConfig.setAllowedOriginPatterns(java.util.List.of("*"));  // 모든 도메인 허용 (개발용)
                corsConfig.setAllowedMethods(java.util.List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
                corsConfig.setAllowedHeaders(java.util.List.of("*"));
                corsConfig.setAllowCredentials(true);
                return corsConfig;
            }))
            
            // 로그인 안되어있으면 html 던지고 user/me로 이동하는거 막음
            .formLogin(AbstractHttpConfigurer::disable)
            // http basic 인증 비활성화 ( 토큰 방식이랑 규격 안맞음)
            .httpBasic(AbstractHttpConfigurer::disable)

            // 세션 끄기 (JWT->Stateless니까 세션 안씀 꺼도된다.)
            .sessionManagement(session ->session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            
            // 2. 주소별 권한 설정
            .authorizeHttpRequests(auth -> auth

                // 로그아웃은 필터를 거치도록 하지만 어차피 로그아웃이라 안거쳐도 문제는 없지만 일단 거치도록 하자.
                .requestMatchers(
                    "/api/auth/logout",
                                  "/api/auth/me"
                ).authenticated()

                .requestMatchers(
                     "/api/signUp/**",
                                  "/api/auth/**",
                                  "/api/post/getList",
                                  "/api/gathering/newList",
                                  "/api/gathering/hotList",
                                  "/ws/**"  // ← WebSocket HTTP 연결 허용 (STOMP 인증은 JwtChannelInterceptor에서)
                ).permitAll() 


                // 나머지는 다 로그인해야 들어올 수 있다
                .anyRequest().authenticated()
            )
            // JWt 필터 등록
            // 스프링 시큐리티 기본인증 처리단계보다 앞서 JWT필터 먼저 동작
            .addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider),
            UsernamePasswordAuthenticationFilter.class);// 아이디 비번 검사보다 앞을 정의한거지만 우리는 모든 로그인 처리 소셜에 맡김으로 단지 표지판 역할임 
            
            
        return http.build();
    }
}
