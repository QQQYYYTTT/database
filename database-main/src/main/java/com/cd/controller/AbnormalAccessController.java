package com.cd.controller;

import com.cd.common.Result;
import com.cd.dto.AbnormalAccessResponse;
import com.cd.dto.PageResponse;
import com.cd.security.SecurityUtils;
import com.cd.service.AbnormalAccessService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/abnormal-access")
public class AbnormalAccessController {

    private final AbnormalAccessService abnormalAccessService;

    public AbnormalAccessController(AbnormalAccessService abnormalAccessService) {
        this.abnormalAccessService = abnormalAccessService;
    }

    @GetMapping
    @PreAuthorize("hasAuthority('sys:abnormal-access:view')")
    public ResponseEntity<Result<PageResponse<AbnormalAccessResponse>>> findPage(
            @RequestParam(required = false) String userName,
            @RequestParam(required = false) String ruleName,
            @RequestParam(required = false) String severity,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        return ResponseEntity.ok(Result.success(
                abnormalAccessService.findPage(userName, ruleName, severity, page, size)));
    }

    @PostMapping("/detect")
    @PreAuthorize("hasAuthority('sys:abnormal-access:detect')")
    public ResponseEntity<Result<Void>> detect() {
        abnormalAccessService.detect(SecurityUtils.currentUserId());
        return ResponseEntity.ok(Result.success("异常访问检测执行完成", null));
    }
}
