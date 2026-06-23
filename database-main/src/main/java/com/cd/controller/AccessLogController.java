package com.cd.controller;

import com.cd.common.Result;
import com.cd.dto.AccessLogResponse;
import com.cd.dto.PageResponse;
import com.cd.service.AccessLogService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/access-logs")
public class AccessLogController {

    private final AccessLogService accessLogService;

    public AccessLogController(AccessLogService accessLogService) {
        this.accessLogService = accessLogService;
    }

    @GetMapping
    @PreAuthorize("hasAuthority('sys:access-log:view')")
    public ResponseEntity<Result<PageResponse<AccessLogResponse>>> findPage(
            @RequestParam(required = false) String userName,
            @RequestParam(required = false) String roleCode,
            @RequestParam(required = false) String operationType,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        return ResponseEntity.ok(Result.success(
                accessLogService.findPage(userName, roleCode, operationType, page, size)));
    }
}
