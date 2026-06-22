package com.cd.dto;

public class MaskingPolicyOptionResponse {

    private Long policyId;
    private Long sensitiveFieldId;
    private String maskingType;
    private String maskingTypeName;
    private String params;
    private Boolean defaultPolicy;

    public Long getPolicyId() {
        return policyId;
    }

    public void setPolicyId(Long policyId) {
        this.policyId = policyId;
    }

    public Long getSensitiveFieldId() {
        return sensitiveFieldId;
    }

    public void setSensitiveFieldId(Long sensitiveFieldId) {
        this.sensitiveFieldId = sensitiveFieldId;
    }

    public String getMaskingType() {
        return maskingType;
    }

    public void setMaskingType(String maskingType) {
        this.maskingType = maskingType;
    }

    public String getMaskingTypeName() {
        return maskingTypeName;
    }

    public void setMaskingTypeName(String maskingTypeName) {
        this.maskingTypeName = maskingTypeName;
    }

    public String getParams() {
        return params;
    }

    public void setParams(String params) {
        this.params = params;
    }

    public Boolean getDefaultPolicy() {
        return defaultPolicy;
    }

    public void setDefaultPolicy(Boolean defaultPolicy) {
        this.defaultPolicy = defaultPolicy;
    }
}
