package com.cd.dto;

import java.util.ArrayList;
import java.util.List;

public class ScoreAnalyticsResponse {

    private String roleCode;
    private String roleName;
    private String granularity;
    private String scopeNote;
    private List<AnalyticsMetricResponse> summaryCards = new ArrayList<>();
    private List<AnalyticsRankingItemResponse> collegeRanking = new ArrayList<>();
    private List<AnalyticsRankingItemResponse> majorRanking = new ArrayList<>();
    private List<AnalyticsRankingItemResponse> courseRanking = new ArrayList<>();
    private List<AnalyticsDistributionItemResponse> scoreDistribution = new ArrayList<>();

    public String getRoleCode() {
        return roleCode;
    }

    public void setRoleCode(String roleCode) {
        this.roleCode = roleCode;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getGranularity() {
        return granularity;
    }

    public void setGranularity(String granularity) {
        this.granularity = granularity;
    }

    public String getScopeNote() {
        return scopeNote;
    }

    public void setScopeNote(String scopeNote) {
        this.scopeNote = scopeNote;
    }

    public List<AnalyticsMetricResponse> getSummaryCards() {
        return summaryCards;
    }

    public void setSummaryCards(List<AnalyticsMetricResponse> summaryCards) {
        this.summaryCards = summaryCards;
    }

    public List<AnalyticsRankingItemResponse> getCollegeRanking() {
        return collegeRanking;
    }

    public void setCollegeRanking(List<AnalyticsRankingItemResponse> collegeRanking) {
        this.collegeRanking = collegeRanking;
    }

    public List<AnalyticsRankingItemResponse> getMajorRanking() {
        return majorRanking;
    }

    public void setMajorRanking(List<AnalyticsRankingItemResponse> majorRanking) {
        this.majorRanking = majorRanking;
    }

    public List<AnalyticsRankingItemResponse> getCourseRanking() {
        return courseRanking;
    }

    public void setCourseRanking(List<AnalyticsRankingItemResponse> courseRanking) {
        this.courseRanking = courseRanking;
    }

    public List<AnalyticsDistributionItemResponse> getScoreDistribution() {
        return scoreDistribution;
    }

    public void setScoreDistribution(List<AnalyticsDistributionItemResponse> scoreDistribution) {
        this.scoreDistribution = scoreDistribution;
    }
}
