package com.cd.service.impl;

import com.cd.dto.CurrentUserResponse;
import com.cd.dto.LoginResponse;
import com.cd.dto.PasswordChangeRequest;
import com.cd.dto.ProfileUpdateRequest;
import com.cd.dto.StudentSelfProfileResponse;
import com.cd.dto.UserLoginRequest;
import com.cd.entity.UserEntity;
import com.cd.mapper.StudentAdminMapper;
import com.cd.mapper.UserMapper;
import com.cd.security.JwtTokenService;
import com.cd.security.SecurityUser;
import com.cd.security.SecurityUserService;
import com.cd.service.AuthService;
import com.cd.service.RuleChangeLogService;
import com.cd.util.Md5Utils;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class AuthServiceImpl implements AuthService {

    private final SecurityUserService securityUserService;
    private final UserMapper userMapper;
    private final StudentAdminMapper studentAdminMapper;
    private final RuleChangeLogService ruleChangeLogService;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenService jwtTokenService;

    public AuthServiceImpl(SecurityUserService securityUserService,
                           UserMapper userMapper,
                           StudentAdminMapper studentAdminMapper,
                           RuleChangeLogService ruleChangeLogService,
                           PasswordEncoder passwordEncoder,
                           JwtTokenService jwtTokenService) {
        this.securityUserService = securityUserService;
        this.userMapper = userMapper;
        this.studentAdminMapper = studentAdminMapper;
        this.ruleChangeLogService = ruleChangeLogService;
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
        Long linkedStudentId = studentAdminMapper.selectLinkedStudentIdByUserId(userId);
        Map<String, Object> beforeSnapshot = buildProfileAuditSnapshot(user, studentAdminMapper.selectCurrentStudentProfile(userId));
        if (linkedStudentId == null) {
            user.setUserName(request.getUserName().trim());
        }
        user.setUserHeader(emptyToNull(request.getUserHeader()));
        user.setUserPhonenum(emptyToNull(request.getUserPhonenum()));
        user.setUserEmail(emptyToNull(request.getUserEmail()));
        userMapper.updateById(user);
        if (linkedStudentId != null) {
            studentAdminMapper.upsertStudentSensitive(
                    linkedStudentId,
                    emptyToNull(request.getUserPhonenum()),
                    emptyToNull(request.getUserEmail()),
                    emptyToNull(request.getAddress())
            );
        }
        CurrentUserResponse updated = currentUser(userId);
        ruleChangeLogService.record(user.getUserName(), "UPDATE_PROFILE", beforeSnapshot, buildProfileAuditSnapshot(updated));
        return updated;
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
        ruleChangeLogService.record(user.getUserName(), "CHANGE_PASSWORD", null, Map.of("passwordChanged", true));
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

    private Map<String, Object> buildProfileAuditSnapshot(UserEntity user, StudentSelfProfileResponse studentProfile) {
        Map<String, Object> snapshot = new LinkedHashMap<>();
        snapshot.put("userId", user.getId());
        snapshot.put("userName", user.getUserName());
        snapshot.put("userHeader", user.getUserHeader());
        snapshot.put("userPhonenum", user.getUserPhonenum());
        snapshot.put("userEmail", user.getUserEmail());
        if (studentProfile != null) {
            snapshot.put("studentProfile", studentProfile);
        }
        return snapshot;
    }

    private Map<String, Object> buildProfileAuditSnapshot(CurrentUserResponse currentUserResponse) {
        Map<String, Object> snapshot = new LinkedHashMap<>();
        snapshot.put("userId", currentUserResponse.getId());
        snapshot.put("userName", currentUserResponse.getUserName());
        snapshot.put("userHeader", currentUserResponse.getUserHeader());
        snapshot.put("userPhonenum", currentUserResponse.getUserPhonenum());
        snapshot.put("userEmail", currentUserResponse.getUserEmail());
        snapshot.put("studentProfile", currentUserResponse.getStudentProfile());
        return snapshot;
    }
}
