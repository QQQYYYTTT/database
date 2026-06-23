package com.cd.service.impl;

import com.cd.dto.PageResponse;
import com.cd.dto.RuleChangeLogResponse;
import com.cd.entity.RuleChangeLogEntity;
import com.cd.mapper.RuleChangeLogMapper;
import com.cd.service.RuleChangeLogService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class RuleChangeLogServiceImpl implements RuleChangeLogService {

    private static final int DEFAULT_PAGE = 1;
    private static final int DEFAULT_SIZE = 10;
    private static final int MAX_SIZE = 50;

    private final RuleChangeLogMapper ruleChangeLogMapper;
    private final ObjectMapper objectMapper;

    public RuleChangeLogServiceImpl(RuleChangeLogMapper ruleChangeLogMapper, ObjectMapper objectMapper) {
        this.ruleChangeLogMapper = ruleChangeLogMapper;
        this.objectMapper = objectMapper;
    }

    @Override
    public void record(String operatorName, String operationType, Object beforeContent, Object afterContent) {
        RuleChangeLogEntity entity = new RuleChangeLogEntity();
        entity.setPolicyId(null);
        entity.setOperatorName(operatorName);
        entity.setOperationType(operationType);
        entity.setBeforeContent(toJson(beforeContent));
        entity.setAfterContent(toJson(afterContent));
        entity.setOperateTime(LocalDateTime.now());
        ruleChangeLogMapper.insert(entity);
    }

    @Override
    public PageResponse<RuleChangeLogResponse> findPage(String operatorName, Integer page, Integer size) {
        int pageNo = normalizePage(page);
        int pageSize = normalizeSize(size);
        int offset = (pageNo - 1) * pageSize;

        long total = ruleChangeLogMapper.countRuleChanges(operatorName);
        List<RuleChangeLogResponse> records = ruleChangeLogMapper.selectRuleChangesPage(operatorName, offset, pageSize);

        PageResponse<RuleChangeLogResponse> response = new PageResponse<>();
        response.setRecords(records);
        response.setTotal(total);
        response.setPage(pageNo);
        response.setSize(pageSize);
        response.setTotalPages(total == 0 ? 0L : (total + pageSize - 1) / pageSize);
        return response;
    }

    private String toJson(Object value) {
        if (value == null) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(value);
        } catch (JsonProcessingException ex) {
            throw new IllegalStateException("Failed to serialize audit log content", ex);
        }
    }

    private int normalizePage(Integer page) {
        if (page == null || page < DEFAULT_PAGE) {
            return DEFAULT_PAGE;
        }
        return page;
    }

    private int normalizeSize(Integer size) {
        if (size == null || size < 1) {
            return DEFAULT_SIZE;
        }
        return Math.min(size, MAX_SIZE);
    }
}
