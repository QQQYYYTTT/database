package com.cd.security;

import com.cd.dto.RoleOptionResponse;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

@Component
public class JwtTokenService {

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    private final SecretKey signingKey;
    private final long expirationMinutes;

    public JwtTokenService(@Value("${jwt.secret}") String secret,
                           @Value("${jwt.expiration-minutes}") long expirationMinutes) {
        this.signingKey = buildKey(secret);
        this.expirationMinutes = expirationMinutes;
    }

    public String generateToken(SecurityUser user) {
        LocalDateTime expiresAt = LocalDateTime.now().plusMinutes(expirationMinutes);
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", user.getUserId());
        claims.put("username", user.getUsername());
        claims.put("superAdmin", user.isSuperAdmin());
        claims.put("roles", user.getRoles().stream().map(RoleOptionResponse::getRoleCode).toList());
        claims.put("permissions", user.getPermissionCodes());

        return Jwts.builder()
                .claims(claims)
                .subject(String.valueOf(user.getUserId()))
                .issuedAt(new Date())
                .expiration(Date.from(expiresAt.atZone(ZoneId.systemDefault()).toInstant()))
                .signWith(signingKey)
                .compact();
    }

    public Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(signingKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public boolean isValid(String token) {
        if (!StringUtils.hasText(token)) {
            return false;
        }
        try {
            parseClaims(token);
            return true;
        } catch (Exception ex) {
            return false;
        }
    }

    public Long getUserId(String token) {
        Claims claims = parseClaims(token);
        Object userId = claims.get("userId");
        if (userId instanceof Number number) {
            return number.longValue();
        }
        return Long.parseLong(String.valueOf(userId));
    }

    public String getExpirationText() {
        return LocalDateTime.now().plusMinutes(expirationMinutes).format(FORMATTER);
    }

    private SecretKey buildKey(String secret) {
        if (secret.matches("^[A-Za-z0-9+/=]+$")) {
            try {
                byte[] decoded = Decoders.BASE64.decode(secret);
                if (decoded.length >= 32) {
                    return Keys.hmacShaKeyFor(decoded);
                }
            } catch (IllegalArgumentException ignored) {
            }
        }
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }
}
