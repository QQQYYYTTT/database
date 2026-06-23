package com.cd.dto;

import java.util.ArrayList;
import java.util.List;

public class SensitiveAnalyticsResponse {

    private String roleCode;
    private String roleName;
    private String granularity;
    private String scopeNote;
    private List<AnalyticsMetricResponse> summaryCards = new ArrayList<>();
    private List<SensitiveLevelCountResponse> levelDistribution = new ArrayList<>();
    private List<SensitiveCoverageItemResponse> coverage = new ArrayList<>();
    private List<SensitiveFieldAnalyticsItemResponse> fieldCatalog = new ArrayList<>();
    private List<SensitiveVisibilitySampleResponse> visibilitySamples = new ArrayList<>();

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

    public List<SensitiveLevelCountResponse> getLevelDistribution() {
        return levelDistribution;
    }

    public void setLevelDistribution(List<SensitiveLevelCountResponse> levelDistribution) {
        this.levelDistribution = levelDistribution;
    }

    public List<SensitiveCoverageItemResponse> getCoverage() {
        return coverage;
    }

    public void setCoverage(List<SensitiveCoverageItemResponse> coverage) {
        this.coverage = coverage;
    }

    public List<SensitiveFieldAnalyticsItemResponse> getFieldCatalog() {
        return fieldCatalog;
    }

    public void setFieldCatalog(List<SensitiveFieldAnalyticsItemResponse> fieldCatalog) {
        this.fieldCatalog = fieldCatalog;
    }

    public List<SensitiveVisibilitySampleResponse> getVisibilitySamples() {
        return visibilitySamples;
    }

    public void setVisibilitySamples(List<SensitiveVisibilitySampleResponse> visibilitySamples) {
        this.visibilitySamples = visibilitySamples;
    }
}
