package com.cd.controller;

import com.cd.common.Result;
import com.cd.dto.ScoreAnalyticsResponse;
import com.cd.dto.SensitiveAnalyticsResponse;
import com.cd.security.SecurityUtils;
import com.cd.service.AnalyticsService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/analytics")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    public AnalyticsController(AnalyticsService analyticsService) {
        this.analyticsService = analyticsService;
    }

    @GetMapping("/score")
    @PreAuthorize("hasAuthority('biz:analytics:score:view')")
    public ResponseEntity<Result<ScoreAnalyticsResponse>> getScoreAnalytics() {
        ScoreAnalyticsResponse data = analyticsService.getScoreAnalytics(SecurityUtils.currentUser());
        return ResponseEntity.ok(Result.success(data));
    }

    @GetMapping("/sensitive")
    @PreAuthorize("hasAuthority('biz:analytics:sensitive:view')")
    public ResponseEntity<Result<SensitiveAnalyticsResponse>> getSensitiveAnalytics() {
        SensitiveAnalyticsResponse data = analyticsService.getSensitiveAnalytics(SecurityUtils.currentUser());
        return ResponseEntity.ok(Result.success(data));
    }
}
