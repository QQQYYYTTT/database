package com.cd.service.impl;

import com.cd.dto.MaskingPolicyOptionResponse;
import com.cd.dto.MaskingRuleOptionsResponse;
import com.cd.dto.MaskingRuleUpdateRequest;
import com.cd.dto.MaskingRuleViewResponse;
import com.cd.dto.PageResponse;
import com.cd.entity.RoleEntity;
import com.cd.exception.DatabaseRoutineException;
import com.cd.mapper.MaskingRuleMapper;
import com.cd.mapper.RoleMapper;
import com.cd.security.SecurityUser;
import com.cd.security.SecurityUtils;
import com.cd.service.MaskingRuleService;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.sql.DataSource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MaskingRuleServiceImpl implements MaskingRuleService {

    private static final String POLICY_SOURCE_ROLE = "ROLE_ASSIGNMENT";
    private static final String POLICY_SOURCE_DEFAULT = "DEFAULT_POLICY";
    private static final int DEFAULT_PAGE = 1;
    private static final int DEFAULT_SIZE = 10;
    private static final int MAX_SIZE = 50;

    private final MaskingRuleMapper maskingRuleMapper;
    private final RoleMapper roleMapper;
    private final DataSource dataSource;

    public MaskingRuleServiceImpl(MaskingRuleMapper maskingRuleMapper,
                                  RoleMapper roleMapper,
                                  DataSource dataSource) {
        this.maskingRuleMapper = maskingRuleMapper;
        this.roleMapper = roleMapper;
        this.dataSource = dataSource;
    }

    @Override
    public MaskingRuleOptionsResponse findOptions() {
        MaskingRuleOptionsResponse response = new MaskingRuleOptionsResponse();
        response.setRoles(roleMapper.selectOptions());
        response.setFields(maskingRuleMapper.selectFieldOptions());
        return response;
    }

    @Override
    public PageResponse<MaskingRuleViewResponse> findRules(Long roleId, Long sensitiveFieldId, Integer page, Integer size) {
        int pageNo = normalizePage(page);
        int pageSize = normalizeSize(size);
        int offset = (pageNo - 1) * pageSize;
        Map<Long, List<MaskingPolicyOptionResponse>> policiesByField = groupPoliciesByField();
        long total = maskingRuleMapper.countMaskingRules(roleId, sensitiveFieldId);
        List<MaskingRuleViewResponse> rules = maskingRuleMapper.selectMaskingRulesPage(roleId, sensitiveFieldId, offset, pageSize);
        for (MaskingRuleViewResponse rule : rules) {
            List<MaskingPolicyOptionResponse> options = policiesByField.getOrDefault(rule.getSensitiveFieldId(), List.of());
            rule.setAvailablePolicies(new ArrayList<>(options));
            if (rule.getFieldLabel() == null || rule.getFieldLabel().isBlank()) {
                rule.setFieldLabel(rule.getTableName() + "." + rule.getColumnName());
            }
            rule.setPolicySource(rule.getAssignedPolicyId() == null ? POLICY_SOURCE_DEFAULT : POLICY_SOURCE_ROLE);
            rule.setEffectivePolicyId(rule.getAssignedPolicyId() == null ? rule.getDefaultPolicyId() : rule.getAssignedPolicyId());
            rule.setEffectiveMaskingType(rule.getAssignedPolicyId() == null ? rule.getDefaultMaskingType() : rule.getAssignedMaskingType());
            rule.setEffectiveMaskingTypeName(rule.getAssignedPolicyId() == null ? rule.getDefaultMaskingTypeName() : rule.getAssignedMaskingTypeName());
            rule.setEffectiveParams(rule.getAssignedPolicyId() == null ? rule.getDefaultParams() : rule.getAssignedParams());
        }
        PageResponse<MaskingRuleViewResponse> response = new PageResponse<>();
        response.setRecords(rules);
        response.setTotal(total);
        response.setPage(pageNo);
        response.setSize(pageSize);
        response.setTotalPages(total == 0 ? 0L : (total + pageSize - 1) / pageSize);
        return response;
    }

    @Override
    @Transactional
    public void updateRule(MaskingRuleUpdateRequest request) {
        RoleEntity role = roleMapper.selectById(request.getRoleId());
        if (role == null || Boolean.FALSE.equals(role.getEnabled())) {
            throw new IllegalArgumentException("目标角色不存在或已禁用");
        }

        Integer fieldCount = maskingRuleMapper.countEnabledSensitiveFieldById(request.getSensitiveFieldId());
        if (fieldCount == null || fieldCount <= 0) {
            throw new IllegalArgumentException("目标敏感字段不存在或已禁用");
        }

        Long policyFieldId = maskingRuleMapper.selectSensitiveFieldIdByPolicyId(request.getPolicyId());
        if (policyFieldId == null) {
            throw new IllegalArgumentException("目标脱敏策略不存在");
        }
        if (!request.getSensitiveFieldId().equals(policyFieldId)) {
            throw new IllegalArgumentException("所选脱敏策略与目标敏感字段不匹配");
        }

        SecurityUser currentUser = SecurityUtils.currentUser();
        String sql = "{CALL SP_UPDATE_MASKING_RULE(?, ?, ?, ?)}";
        try (Connection connection = dataSource.getConnection();
             CallableStatement statement = connection.prepareCall(sql)) {
            if (currentUser == null || currentUser.getUserId() == null) {
                statement.setNull(1, Types.BIGINT);
                statement.setString(2, "system");
            } else {
                statement.setLong(1, currentUser.getUserId());
                statement.setString(2, currentUser.getUsername());
            }
            statement.setLong(3, request.getRoleId());
            statement.setLong(4, request.getPolicyId());
            statement.execute();
        } catch (SQLException ex) {
            throw translateSqlException("Failed to update masking rule", ex);
        }
    }

    private Map<Long, List<MaskingPolicyOptionResponse>> groupPoliciesByField() {
        Map<Long, List<MaskingPolicyOptionResponse>> grouped = new LinkedHashMap<>();
        for (MaskingPolicyOptionResponse option : maskingRuleMapper.selectPolicyOptions()) {
            grouped.computeIfAbsent(option.getSensitiveFieldId(), key -> new ArrayList<>()).add(option);
        }
        return grouped;
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

    private DatabaseRoutineException translateSqlException(String fallbackMessage, SQLException ex) {
        String sqlState = ex.getSQLState();
        String message = ex.getMessage() == null || ex.getMessage().isBlank() ? fallbackMessage : ex.getMessage();
        int statusCode = "45000".equals(sqlState)
                ? HttpStatus.BAD_REQUEST.value()
                : HttpStatus.INTERNAL_SERVER_ERROR.value();
        return new DatabaseRoutineException(statusCode, sqlState, message, ex);
    }
}
