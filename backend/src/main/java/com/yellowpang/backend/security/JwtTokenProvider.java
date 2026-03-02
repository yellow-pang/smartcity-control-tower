package com.yellowpang.backend.security;

import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;

/**
 * JWT 토큰 발급 및 검증
 */
@Slf4j
@Component
public class JwtTokenProvider {

    private final SecretKey key;
    private final long expirationMs;

    public JwtTokenProvider(
            @Value("${jwt.secret-key:your-secret-key-change-in-production-with-min-256bits}") String secretKey,
            @Value("${jwt.expiration-ms:86400000}") long expirationMs) {
        // 최소 256비트 필요 (32바이트)
        if (secretKey.getBytes(StandardCharsets.UTF_8).length < 32) {
            throw new IllegalArgumentException("JWT secret key must be at least 256 bits (32 bytes)");
        }
        this.key = Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));
        this.expirationMs = expirationMs;
    }

    /**
     * JWT 토큰 생성
     */
    public String generateToken(String userId, String email, String roles) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("email", email);
        claims.put("roles", roles);

        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expirationMs);

        return Jwts.builder()
                .subject(email)
                .claims(claims)
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(key)
                .compact();
    }

    /**
     * JWT 토큰 검증 및 클레임 추출
     */
    public Claims getClaims(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(key)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (JwtException | IllegalArgumentException e) {
            log.error("JWT token validation failed: {}", e.getMessage());
            throw new JwtException("Invalid JWT token", e);
        }
    }

    /**
     * 토큰에서 사용자 ID 추출
     */
    public String getUserId(String token) {
        return getClaims(token).get("userId", String.class);
    }

    /**
     * 토큰에서 이메일 추출
     */
    public String getEmail(String token) {
        return getClaims(token).getSubject();
    }

    /**
     * 토큰에서 역할 추출
     */
    public String getRoles(String token) {
        return getClaims(token).get("roles", String.class);
    }

    /**
     * 토큰 만료 여부 확인
     */
    public boolean isTokenExpired(String token) {
        try {
            getClaims(token);
            return false;
        } catch (ExpiredJwtException e) {
            log.warn("JWT token is expired");
            return true;
        }
    }

    /**
     * 토큰 유효성 확인
     */
    public boolean validateToken(String token) {
        try {
            getClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            log.error("Invalid JWT: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Authorization 헤더에서 토큰 추출
     */
    public String extractTokenFromHeader(String authorizationHeader) {
        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            return authorizationHeader.substring(7);
        }
        return null;
    }
}
