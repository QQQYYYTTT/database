package com.cd.dto;

import java.util.ArrayList;
import java.util.List;

public class DataImportResultResponse {

    private String importType;
    private Integer totalRows;
    private Integer successCount;
    private Integer failureCount;
    private List<DataImportErrorResponse> errors = new ArrayList<>();

    public String getImportType() {
        return importType;
    }

    public void setImportType(String importType) {
        this.importType = importType;
    }

    public Integer getTotalRows() {
        return totalRows;
    }

    public void setTotalRows(Integer totalRows) {
        this.totalRows = totalRows;
    }

    public Integer getSuccessCount() {
        return successCount;
    }

    public void setSuccessCount(Integer successCount) {
        this.successCount = successCount;
    }

    public Integer getFailureCount() {
        return failureCount;
    }

    public void setFailureCount(Integer failureCount) {
        this.failureCount = failureCount;
    }

    public List<DataImportErrorResponse> getErrors() {
        return errors;
    }

    public void setErrors(List<DataImportErrorResponse> errors) {
        this.errors = errors;
    }
}
