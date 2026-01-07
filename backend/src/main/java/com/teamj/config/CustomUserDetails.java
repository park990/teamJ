package com.teamj.config;

import java.security.Principal;
import java.util.Collection;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class CustomUserDetails implements UserDetails, Principal {
    
    private final Long userIdx; // 우리가 필요로 하는 핵심 정보
    private final Collection<? extends GrantedAuthority> authorities;

    // 생성자 (빌더 패턴 사용)
    public CustomUserDetails(Long userIdx, Collection<? extends GrantedAuthority> authorities) {
        this.userIdx = userIdx;
        this.authorities = authorities;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return ""; // JWT 인증이므로 비밀번호 비워두기
    }

    @Override
    public String getUsername() {
        return String.valueOf(userIdx); // 기본 username 자리에는 식별자.
    }

    // Principal 인터페이스 구현 (WebSocket에서 Principal로 사용 가능하게)
    @Override
    public String getName() {
        return String.valueOf(userIdx); // Principal의 이름으로 userIdx 반환
    }

    // 아래 계정 상태 체크는 실무에서 특별한 로직이 없다면 모두 true로 
    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return true; }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() { return true; }
}

