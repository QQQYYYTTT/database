package com.cd.dto;

public class SensitiveCoverageItemResponse {

    private String fieldKey;
    private String fieldLabel;
    private Long filledCount;
    private Long totalCount;
    private Double coverageRate;

    public String getFieldKey() {
        return fieldKey;
    }

    public void setFieldKey(String fieldKey) {
        this.fieldKey = fieldKey;
    }

    public String getFieldLabel() {
        return fieldLabel;
    }

    public void setFieldLabel(String fieldLabel) {
        this.fieldLabel = fieldLabel;
    }

    public Long getFilledCount() {
        return filledCount;
    }

    public void setFilledCount(Long filledCount) {
        this.filledCount = filledCount;
    }

    public Long getTotalCount() {
        return totalCount;
    }

    public void setTotalCount(Long totalCount) {
        this.totalCount = totalCount;
    }

    public Double getCoverageRate() {
        return coverageRate;
    }

    public void setCoverageRate(Double coverageRate) {
        this.coverageRate = coverageRate;
    }
}
