package com.cd.dto;

import java.util.ArrayList;
import java.util.List;

public class MaskingRuleViewResponse {

    private Long roleId;
    private String roleCode;
    private String roleName;
    private Long sensitiveFieldId;
    private String tableName;
    private String columnName;
    private String fieldLabel;
    private String sensitiveType;
    private String sensitiveLevel;
    private Long assignmentId;
    private Long assignedPolicyId;
    private String assignedMaskingType;
    private String assignedMaskingTypeName;
    private String assignedParams;
    private Long defaultPolicyId;
    private String defaultMaskingType;
    private String defaultMaskingTypeName;
    private String defaultParams;
    private Long effectivePolicyId;
    private String effectiveMaskingType;
    private String effectiveMaskingTypeName;
    private String effectiveParams;
    private String policySource;
    private List<MaskingPolicyOptionResponse> availablePolicies = new ArrayList<>();

    public Long getRoleId() {
        return roleId;
    }

    public void setRoleId(Long roleId) {
        this.roleId = roleId;
    }

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

    public Long getSensitiveFieldId() {
        return sensitiveFieldId;
    }

    public void setSensitiveFieldId(Long sensitiveFieldId) {
        this.sensitiveFieldId = sensitiveFieldId;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public String getColumnName() {
        return columnName;
    }

    public void setColumnName(String columnName) {
        this.columnName = columnName;
    }

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

    public Long getAssignmentId() {
        return assignmentId;
    }

    public void setAssignmentId(Long assignmentId) {
        this.assignmentId = assignmentId;
    }

    public Long getAssignedPolicyId() {
        return assignedPolicyId;
    }

    public void setAssignedPolicyId(Long assignedPolicyId) {
        this.assignedPolicyId = assignedPolicyId;
    }

    public String getAssignedMaskingType() {
        return assignedMaskingType;
    }

    public void setAssignedMaskingType(String assignedMaskingType) {
        this.assignedMaskingType = assignedMaskingType;
    }

    public String getAssignedMaskingTypeName() {
        return assignedMaskingTypeName;
    }

    public void setAssignedMaskingTypeName(String assignedMaskingTypeName) {
        this.assignedMaskingTypeName = assignedMaskingTypeName;
    }

    public String getAssignedParams() {
        return assignedParams;
    }

    public void setAssignedParams(String assignedParams) {
        this.assignedParams = assignedParams;
    }

    public Long getDefaultPolicyId() {
        return defaultPolicyId;
    }

    public void setDefaultPolicyId(Long defaultPolicyId) {
        this.defaultPolicyId = defaultPolicyId;
    }

    public String getDefaultMaskingType() {
        return defaultMaskingType;
    }

    public void setDefaultMaskingType(String defaultMaskingType) {
        this.defaultMaskingType = defaultMaskingType;
    }

    public String getDefaultMaskingTypeName() {
        return defaultMaskingTypeName;
    }

    public void setDefaultMaskingTypeName(String defaultMaskingTypeName) {
        this.defaultMaskingTypeName = defaultMaskingTypeName;
    }

    public String getDefaultParams() {
        return defaultParams;
    }

    public void setDefaultParams(String defaultParams) {
        this.defaultParams = defaultParams;
    }

    public Long getEffectivePolicyId() {
        return effectivePolicyId;
    }

    public void setEffectivePolicyId(Long effectivePolicyId) {
        this.effectivePolicyId = effectivePolicyId;
    }

    public String getEffectiveMaskingType() {
        return effectiveMaskingType;
    }

    public void setEffectiveMaskingType(String effectiveMaskingType) {
        this.effectiveMaskingType = effectiveMaskingType;
    }

    public String getEffectiveMaskingTypeName() {
        return effectiveMaskingTypeName;
    }

    public void setEffectiveMaskingTypeName(String effectiveMaskingTypeName) {
        this.effectiveMaskingTypeName = effectiveMaskingTypeName;
    }

    public String getEffectiveParams() {
        return effectiveParams;
    }

    public void setEffectiveParams(String effectiveParams) {
        this.effectiveParams = effectiveParams;
    }

    public String getPolicySource() {
        return policySource;
    }

    public void setPolicySource(String policySource) {
        this.policySource = policySource;
    }

    public List<MaskingPolicyOptionResponse> getAvailablePolicies() {
        return availablePolicies;
    }

    public void setAvailablePolicies(List<MaskingPolicyOptionResponse> availablePolicies) {
        this.availablePolicies = availablePolicies;
    }
}
