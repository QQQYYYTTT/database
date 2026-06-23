package com.cd.dto;

public class SensitiveFieldAnalyticsItemResponse {

    private String fieldLabel;
    private String sensitiveType;
    private String sensitiveLevel;
    private String currentPolicy;
    private String policySource;

    public String getFieldLabel() {
        return fieldLabel;
    }

    public void setFieldLabel(String fieldLabel) {
        this.fieldLabel = fieldLabel;
    }

    public String getSensitiveType() {
        return sensitiveType;
    }

    public void setSensitiveType(String sensitiveType) {
        this.sensitiveType = sensitiveType;
    }

    public String getSensitiveLevel() {
        return sensitiveLevel;
    }

    public void setSensitiveLevel(String sensitiveLevel) {
        this.sensitiveLevel = sensitiveLevel;
    }

    public String getCurrentPolicy() {
        return currentPolicy;
    }

    public void setCurrentPolicy(String currentPolicy) {
        this.currentPolicy = currentPolicy;
    }

    public String getPolicySource() {
        return policySource;
    }

    public void setPolicySource(String policySource) {
        this.policySource = policySource;
    }
}
