package com.cd.service.impl;

import com.cd.dto.CurrentUserResponse;
import com.cd.dto.LoginResponse;
import com.cd.dto.PasswordChangeRequest;
import com.cd.dto.ProfileUpdateRequest;
import com.cd.dto.UserLoginRequest;
import com.cd.entity.UserEntity;
import com.cd.mapper.UserMapper;
import com.cd.security.JwtTokenService;
import com.cd.security.SecurityUser;
import com.cd.security.SecurityUserService;
import com.cd.service.AuthService;
import com.cd.util.Md5Utils;
import java.time.LocalDateTime;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class AuthServiceImpl implements AuthService {

    private final SecurityUserService securityUserService;
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenService jwtTokenService;

    public AuthServiceImpl(SecurityUserService securityUserService,
                           UserMapper userMapper,
                           PasswordEncoder passwordEncoder,
                           JwtTokenService jwtTokenService) {
        this.securityUserService = securityUserService;
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenService = jwtTokenService;
    }

    @Override
    public LoginResponse login(UserLoginRequest request) {
        SecurityUser securityUser = securityUserService.loadSecurityUserByUsername(request.getUserName());
        if (securityUser == null) {
            throw new BadCredentialsException("用户名或密码错误");
        }
        if (!securityUser.isEnabled()) {
            throw new DisabledException("账号已被禁用");
        }
        if (!matchesPassword(request.getUserPwd(), securityUser)) {
            throw new BadCredentialsException("用户名或密码错误");
        }

        if (isLegacyMd5Hash(securityUser.getPassword())) {
            userMapper.updatePasswordById(securityUser.getUserId(), passwordEncoder.encode(request.getUserPwd()));
            securityUser = securityUserService.loadSecurityUserByUserId(securityUser.getUserId());
        }

        userMapper.updateLastLoginTime(securityUser.getUserId(), LocalDateTime.now());
        String token = jwtTokenService.generateToken(securityUser);

        LoginResponse response = new LoginResponse();
        response.setToken(token);
        response.setUserId(securityUser.getUserId());
        response.setUserName(securityUser.getUsername());
        response.setExpiresAt(jwtTokenService.getExpirationText());
        return response;
    }

    @Override
    public CurrentUserResponse currentUser(Long userId) {
        return securityUserService.buildCurrentUserResponse(userId);
    }

    @Override
    public CurrentUserResponse updateProfile(Long userId, ProfileUpdateRequest request) {
        UserEntity user = requireUser(userId);
        user.setUserName(request.getUserName().trim());
        user.setUserHeader(emptyToNull(request.getUserHeader()));
        user.setUserPhonenum(emptyToNull(request.getUserPhonenum()));
        user.setUserEmail(emptyToNull(request.getUserEmail()));
        userMapper.updateById(user);
        return currentUser(userId);
    }

    @Override
    public void changePassword(Long userId, PasswordChangeRequest request) {
        UserEntity user = requireUser(userId);
        SecurityUser securityUser = securityUserService.loadSecurityUserByUserId(userId);
        if (securityUser == null) {
            throw new BadCredentialsException("登录状态已失效");
        }
        if (!matchesPassword(request.getOldPassword(), securityUser)) {
            throw new BadCredentialsException("旧密码不正确");
        }
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new IllegalArgumentException("两次输入的新密码不一致");
        }
        if (request.getOldPassword().equals(request.getNewPassword())) {
            throw new IllegalArgumentException("新密码不能与旧密码相同");
        }
        userMapper.updatePasswordById(user.getId(), passwordEncoder.encode(request.getNewPassword()));
    }

    private UserEntity requireUser(Long userId) {
        UserEntity user = userMapper.selectEntityById(userId);
        if (user == null) {
            throw new BadCredentialsException("登录状态已失效");
        }
        return user;
    }

    private boolean matchesPassword(String rawPassword, SecurityUser securityUser) {
        String storedPassword = securityUser.getPassword();
        if (isLegacyMd5Hash(storedPassword)) {
            return storedPassword.equalsIgnoreCase(Md5Utils.encrypt(rawPassword));
        }
        return passwordEncoder.matches(rawPassword, storedPassword);
    }

    private boolean isLegacyMd5Hash(String password) {
        return password != null && password.matches("^[a-fA-F0-9]{32}$");
    }

    private String emptyToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }
}
