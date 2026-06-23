package com.cd.dto;

import java.time.LocalDateTime;

public class AccessLogResponse {

    private Long id;
    private Long userId;
    private String userName;
    private String roleCode;
    private String operationType;
    private String tableName;
    private String sensitiveColumns;
    private Integer maskingApplied;
    private LocalDateTime accessTime;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getRoleCode() {
        return roleCode;
    }

    public void setRoleCode(String roleCode) {
        this.roleCode = roleCode;
    }

    public String getOperationType() {
        return operationType;
    }

    public void setOperationType(String operationType) {
        this.operationType = operationType;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public String getSensitiveColumns() {
        return sensitiveColumns;
    }

    public void setSensitiveColumns(String sensitiveColumns) {
        this.sensitiveColumns = sensitiveColumns;
    }

    public Integer getMaskingApplied() {
        return maskingApplied;
    }

    public void setMaskingApplied(Integer maskingApplied) {
        this.maskingApplied = maskingApplied;
    }

    public LocalDateTime getAccessTime() {
        return accessTime;
    }

    public void setAccessTime(LocalDateTime accessTime) {
        this.accessTime = accessTime;
    }
}
