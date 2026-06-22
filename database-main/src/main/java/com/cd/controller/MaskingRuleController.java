package com.cd.controller;

import com.cd.common.Result;
import com.cd.dto.MaskingRuleOptionsResponse;
import com.cd.dto.MaskingRuleUpdateRequest;
import com.cd.dto.MaskingRuleViewResponse;
import com.cd.dto.PageResponse;
import com.cd.service.MaskingRuleService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/masking-rules")
public class MaskingRuleController {

    private final MaskingRuleService maskingRuleService;

    public MaskingRuleController(MaskingRuleService maskingRuleService) {
        this.maskingRuleService = maskingRuleService;
    }

    @GetMapping("/options")
    @PreAuthorize("hasAuthority('sys:masking-rule:view')")
    public ResponseEntity<Result<MaskingRuleOptionsResponse>> findOptions() {
        return ResponseEntity.ok(Result.success(maskingRuleService.findOptions()));
    }

    @GetMapping
    @PreAuthorize("hasAuthority('sys:masking-rule:view')")
    public ResponseEntity<Result<PageResponse<MaskingRuleViewResponse>>> findRules(
            @RequestParam(required = false) Long roleId,
            @RequestParam(required = false) Long sensitiveFieldId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        return ResponseEntity.ok(Result.success(maskingRuleService.findRules(roleId, sensitiveFieldId, page, size)));
    }

    @PutMapping
    @PreAuthorize("hasAuthority('sys:masking-rule:update')")
    public ResponseEntity<Result<Void>> updateRule(@Valid @RequestBody MaskingRuleUpdateRequest request) {
        maskingRuleService.updateRule(request);
        return ResponseEntity.ok(Result.success("脱敏规则更新成功", null));
    }
}
