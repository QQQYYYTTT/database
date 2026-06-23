package com.cd.service;

import com.cd.dto.ScoreAnalyticsResponse;
import com.cd.dto.SensitiveAnalyticsResponse;
import com.cd.security.SecurityUser;

public interface AnalyticsService {

    ScoreAnalyticsResponse getScoreAnalytics(SecurityUser currentUser);

    SensitiveAnalyticsResponse getSensitiveAnalytics(SecurityUser currentUser);
}
