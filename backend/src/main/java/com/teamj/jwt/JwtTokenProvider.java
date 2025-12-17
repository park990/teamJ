package com.teamj.jwt;

import java.security.Key;
import java.util.Collections;
import java.util.Date;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.UnsupportedJwtException;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class JwtTokenProvider {
    private final Key key;
    private final Long accessTokenValidTime;
    private final Long refreshTokenValidTime;

    // yml파일이 env랑 연결해줌
    public JwtTokenProvider(@Value("${jwt.secret}") String secretKey,
            @Value("${jwt.access-token-valid-in-seconds}") Long accessTokenTime,
            @Value("${jwt.refresh-token-valid-in-seconds}") Long refreshTokenTime) {
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        this.key = Keys.hmacShaKeyFor(keyBytes);
        this.accessTokenValidTime = accessTokenTime * 1000;
        this.refreshTokenValidTime = refreshTokenTime * 1000;
    }

    // ACCESS 토큰 생성
    public String createAccessToken(Long userIdx) {
        Claims claims = Jwts.claims().setSubject(String.valueOf(userIdx));
        Date now = new Date();
        Date valid = new Date(now.getTime() + accessTokenValidTime);

        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(now)
                .setExpiration(valid)
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    // Refresh 토큰 생성
    public String createRefreshToken() {
        Date now = new Date();
        Date valid = new Date(now.getTime() + refreshTokenValidTime); // 7일 수정할거면 => yml

        return Jwts.builder()
                .setIssuedAt(now)
                .setExpiration(valid)
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    // 토큰에서 userIdx Get
    public Long getuserIdx(String token) {
        return Long.parseLong(
                Jwts.parserBuilder()
                        .setSigningKey(key)
                        .build()
                        // 서명이 존재하는 토큰을 열때 Jws
                        .parseClaimsJws(token)
                        .getBody() // payload 전체
                        .getSubject() // payload 전체에서 userIdx만
        );
    }

    // 토큰에서 인증객체 꺼내기
    public Authentication getAuthentication(String token) {
        Long userIdx = getuserIdx(token);

        // DB를 들르지 않고 임시 유저객체 생성
        UserDetails userDetails = new User(String.valueOf(userIdx), "",
                Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER"))); // 권한.

        return new UsernamePasswordAuthenticationToken(userDetails, "", userDetails.getAuthorities());
    }

    // 토큰 검증
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
            return true;
        } catch (io.jsonwebtoken.security.SecurityException | MalformedJwtException e) {
            log.info("잘못된 JWT 서명입니다.");
        } catch (ExpiredJwtException e) {
            log.info("만료된 JWT 토큰입니다.");
        } catch (UnsupportedJwtException e) {
            log.info("지원되지 않는 JWT 토큰입니다.");
        } catch (IllegalArgumentException e) {
            log.info("JWT 토큰이 잘못되었습니다.");
        }
        return false;
    }
}
