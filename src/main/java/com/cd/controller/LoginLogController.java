package com.cd.controller;

import com.cd.common.Result;
import com.cd.dto.LoginLogResponse;
import com.cd.dto.PageResponse;
import com.cd.service.LoginLogService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/login-logs")
public class LoginLogController {

    private final LoginLogService loginLogService;

    public LoginLogController(LoginLogService loginLogService) {
        this.loginLogService = loginLogService;
    }

    @GetMapping
    @PreAuthorize("hasAuthority('sys:log:view')")
    public ResponseEntity<Result<PageResponse<LoginLogResponse>>> findPage(
            @RequestParam(required = false) String userName,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        return ResponseEntity.ok(Result.success(loginLogService.findPage(userName, page, size)));
    }
}
