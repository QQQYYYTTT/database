package com.cd.dto;

public class SensitiveVisibilitySampleResponse {

    private String fieldLabel;
    private String maskedValue;
    private String maskingTypeName;
    private String policySource;

    public String getFieldLabel() {
        return fieldLabel;
    }

    public void setFieldLabel(String fieldLabel) {
        this.fieldLabel = fieldLabel;
    }

    public String getMaskedValue() {
        return maskedValue;
    }

    public void setMaskedValue(String maskedValue) {
        this.maskedValue = maskedValue;
    }

    public String getMaskingTypeName() {
        return maskingTypeName;
    }

    public void setMaskingTypeName(String maskingTypeName) {
        this.maskingTypeName = maskingTypeName;
    }

    public String getPolicySource() {
        return policySource;
    }

    public void setPolicySource(String policySource) {
        this.policySource = policySource;
    }
}
