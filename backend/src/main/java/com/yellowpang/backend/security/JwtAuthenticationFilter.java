package com.yellowpang.backend.security;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * JWT 인증 필터
 * Authorization 헤더에서 토큰을 추출하고 검증한 후 Spring Security에 등록
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        try {
            // Authorization 헤더에서 토큰 추출
            String token = extractToken(request);

            if (token != null && jwtTokenProvider.validateToken(token)) {
                // 토큰에서 사용자 정보 추출
                String userEmail = jwtTokenProvider.getEmail(token);
                String userId = jwtTokenProvider.getUserId(token);
                String rolesStr = jwtTokenProvider.getRoles(token);

                // 역할을 권한으로 변환
                List<SimpleGrantedAuthority> authorities = parseRoles(rolesStr);

                // Spring Security에 인증 정보 설정
                UsernamePasswordAuthenticationToken auth =
                        new UsernamePasswordAuthenticationToken(userEmail, userId, authorities);
                auth.setDetails(userId);
                SecurityContextHolder.getContext().setAuthentication(auth);

                log.debug("JWT Authentication set for user: {}", userEmail);
            }
        } catch (Exception e) {
            log.error("JWT filter error: {}", e.getMessage());
            SecurityContextHolder.clearContext();
        }

        filterChain.doFilter(request, response);
    }

    /**
     * Authorization 헤더에서 JWT 토큰 추출
     */
    private String extractToken(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        return jwtTokenProvider.extractTokenFromHeader(authHeader);
    }

    /**
     * 역할 문자열을 권한 리스트로 변환
     * 예: "ROLE_ADMIN,ROLE_USER" -> [SimpleGrantedAuthority("ROLE_ADMIN"), ...]
     */
    private List<SimpleGrantedAuthority> parseRoles(String rolesStr) {
        if (rolesStr == null || rolesStr.isEmpty()) {
            return List.of();
        }
        return Arrays.stream(rolesStr.split(","))
                .map(String::trim)
                .map(role -> new SimpleGrantedAuthority(role.startsWith("ROLE_") ? role : "ROLE_" + role))
                .toList();
    }
}
