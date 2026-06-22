package com.cd.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public class MaskingRuleUpdateRequest {

    @NotNull(message = "角色不能为空")
    @Positive(message = "角色参数不合法")
    private Long roleId;

    @NotNull(message = "敏感字段不能为空")
    @Positive(message = "敏感字段参数不合法")
    private Long sensitiveFieldId;

    @NotNull(message = "脱敏策略不能为空")
    @Positive(message = "脱敏策略参数不合法")
    private Long policyId;

    public Long getRoleId() {
        return roleId;
    }

    public void setRoleId(Long roleId) {
        this.roleId = roleId;
    }

    public Long getSensitiveFieldId() {
        return sensitiveFieldId;
    }

    public void setSensitiveFieldId(Long sensitiveFieldId) {
        this.sensitiveFieldId = sensitiveFieldId;
    }

    public Long getPolicyId() {
        return policyId;
    }

    public void setPolicyId(Long policyId) {
        this.policyId = policyId;
    }
}
