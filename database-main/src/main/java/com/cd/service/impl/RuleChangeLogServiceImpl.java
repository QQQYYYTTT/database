package com.cd.service.impl;

import com.cd.entity.RuleChangeLogEntity;
import com.cd.mapper.RuleChangeLogMapper;
import com.cd.service.RuleChangeLogService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.LocalDateTime;
import org.springframework.stereotype.Service;

@Service
public class RuleChangeLogServiceImpl implements RuleChangeLogService {

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
}
