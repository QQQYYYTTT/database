package com.cd.controller;

import com.cd.common.Result;
import com.cd.dto.CurrentUserResponse;
import com.cd.dto.LoginResponse;
import com.cd.dto.PasswordChangeRequest;
import com.cd.dto.ProfileUpdateRequest;
import com.cd.dto.UserLoginRequest;
import com.cd.security.SecurityUtils;
import com.cd.service.AuthService;
import com.cd.service.LoginLogService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/user")
public class AuthController {

    private final AuthService authService;
    private final LoginLogService loginLogService;

    public AuthController(AuthService authService, LoginLogService loginLogService) {
        this.authService = authService;
        this.loginLogService = loginLogService;
    }

    @PostMapping("/login")
    public ResponseEntity<Result<LoginResponse>> login(@Valid @RequestBody UserLoginRequest request,
                                                       HttpServletRequest httpServletRequest) {
        String loginIp = httpServletRequest.getRemoteAddr();
        try {
            LoginResponse loginResponse = authService.login(request);
            loginLogService.record(loginResponse.getUserName(), "SUCCESS", loginIp, "登录成功");
            return ResponseEntity.ok(Result.success("登录成功", loginResponse));
        } catch (BadCredentialsException | DisabledException ex) {
            loginLogService.record(request.getUserName(), "FAIL", loginIp, ex.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Result.error(401, ex.getMessage()));
        }
    }

    @GetMapping("/me")
    public ResponseEntity<Result<CurrentUserResponse>> currentUser() {
        Long currentUserId = SecurityUtils.currentUserId();
        CurrentUserResponse currentUser = authService.currentUser(currentUserId);
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Result.error(401, "登录状态已失效"));
        }
        return ResponseEntity.ok(Result.success(currentUser));
    }

    @PutMapping("/profile")
    public ResponseEntity<Result<CurrentUserResponse>> updateProfile(
            @Valid @RequestBody ProfileUpdateRequest request) {
        Long currentUserId = SecurityUtils.currentUserId();
        CurrentUserResponse updated = authService.updateProfile(currentUserId, request);
        return ResponseEntity.ok(Result.success("个人资料更新成功", updated));
    }

    @PutMapping("/password")
    public ResponseEntity<Result<Void>> changePassword(
            @Valid @RequestBody PasswordChangeRequest request) {
        Long currentUserId = SecurityUtils.currentUserId();
        authService.changePassword(currentUserId, request);
        return ResponseEntity.ok(Result.success("密码修改成功", null));
    }

    @PostMapping("/logout")
    public ResponseEntity<Result<Void>> logout() {
        return ResponseEntity.ok(Result.success("退出登录成功", null));
    }
}
