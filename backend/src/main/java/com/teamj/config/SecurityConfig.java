package com.teamj.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // 1. 모바일 앱은 보통 csrf를 끔
            .csrf(csrf -> csrf.disable()) 
            
            // 2. 주소별 권한 설정
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/signUp/**").permitAll() 
                
                // 나머지는 다 로그인해야 들어올 수 있다
                .anyRequest().authenticated()
            );
            
        return http.build();
    }
}
