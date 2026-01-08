package com.teamj.jwt;

import java.io.IOException;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    private final JwtTokenProvider jwtTokenProvider;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

    // Bearer 없는 토큰
        String token = resolveToken(request);

        if (token != null && jwtTokenProvider.validateToken(token)) {

            // JWTProvider에서 정의한 securityConfig가 읽을 수 있는 인증객체를 만든 후
            Authentication authentication = jwtTokenProvider.getAuthentication(token);

            // 세큐리티 필터에 검문 승인 등록
            SecurityContextHolder.getContext().setAuthentication(authentication);

            log.info("Security Context에 '{}' 인증정보 저장 완료", authentication);
        }

        // 컨트롤러로 넘기기
        filterChain.doFilter(request, response);
    }

    // front에서 Bearer 넣고 보낸 토큰 분리 해주기
    private String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }

}
