package com.cd.controller;

import com.cd.common.Result;
import com.cd.dto.PageResponse;
import com.cd.dto.RuleChangeLogResponse;
import com.cd.service.RuleChangeLogService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/rule-change-logs")
public class RuleChangeLogController {

    private final RuleChangeLogService ruleChangeLogService;

    public RuleChangeLogController(RuleChangeLogService ruleChangeLogService) {
        this.ruleChangeLogService = ruleChangeLogService;
    }

    @GetMapping
    @PreAuthorize("hasAuthority('sys:rule-change-log:view')")
    public ResponseEntity<Result<PageResponse<RuleChangeLogResponse>>> findPage(
            @RequestParam(required = false) String operatorName,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        return ResponseEntity.ok(Result.success(ruleChangeLogService.findPage(operatorName, page, size)));
    }
}
