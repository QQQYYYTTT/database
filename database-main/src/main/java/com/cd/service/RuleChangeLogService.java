package com.cd.service;

public interface RuleChangeLogService {

    void record(String operatorName, String operationType, Object beforeContent, Object afterContent);
}
