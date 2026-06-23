package com.cd.service;

import com.cd.dto.PageResponse;
import com.cd.dto.RuleChangeLogResponse;

public interface RuleChangeLogService {

    void record(String operatorName, String operationType, Object beforeContent, Object afterContent);

    PageResponse<RuleChangeLogResponse> findPage(String operatorName, Integer page, Integer size);
}
