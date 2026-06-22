package com.cd.dto;

public class MaskingRuleFieldOptionResponse {

    private Long sensitiveFieldId;
    private String tableName;
    private String columnName;
    private String sensitiveType;
    private String sensitiveLevel;
    private String fieldLabel;

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

    public String getFieldLabel() {
        return fieldLabel;
    }

    public void setFieldLabel(String fieldLabel) {
        this.fieldLabel = fieldLabel;
    }
}
