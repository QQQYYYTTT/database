package com.cd.service.impl;

import com.cd.dto.AnalyticsMetricResponse;
import com.cd.dto.AnalyticsRankingItemResponse;
import com.cd.dto.MaskingRuleViewResponse;
import com.cd.dto.RoleOptionResponse;
import com.cd.dto.ScoreAnalyticsOverviewResponse;
import com.cd.dto.ScoreAnalyticsResponse;
import com.cd.dto.SensitiveAnalyticsResponse;
import com.cd.dto.SensitiveCoverageItemResponse;
import com.cd.dto.SensitiveFieldAnalyticsItemResponse;
import com.cd.dto.SensitiveLevelCountResponse;
import com.cd.dto.SensitiveVisibilitySampleResponse;
import com.cd.entity.RoleEntity;
import com.cd.mapper.AnalyticsMapper;
import com.cd.mapper.MaskingRuleMapper;
import com.cd.mapper.RoleMapper;
import com.cd.security.SecurityUser;
import com.cd.service.AnalyticsService;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AnalyticsServiceImpl implements AnalyticsService {

    private static final String ROLE_SUPER_ADMIN = "SUPER_ADMIN";
    private static final String ROLE_DATA_ADMIN = "DATA_ADMIN";
    private static final String ROLE_TEACHER = "TEACHER";
    private static final String ROLE_ANALYST = "ANALYST";
    private static final String ROLE_NORMAL = "NORMAL";
    private static final String ROLE_STUDENT = "STUDENT";

    private final AnalyticsMapper analyticsMapper;
    private final MaskingRuleMapper maskingRuleMapper;
    private final RoleMapper roleMapper;

    public AnalyticsServiceImpl(AnalyticsMapper analyticsMapper,
                                MaskingRuleMapper maskingRuleMapper,
                                RoleMapper roleMapper) {
        this.analyticsMapper = analyticsMapper;
        this.maskingRuleMapper = maskingRuleMapper;
        this.roleMapper = roleMapper;
    }

    @Override
    public ScoreAnalyticsResponse getScoreAnalytics(SecurityUser currentUser) {
        SecurityUser user = requireCurrentUser(currentUser);
        RoleAnalyticsProfile profile = buildRoleProfile(user);
        int rankingLimit = resolveRankingLimit(profile.roleCode());

        ScoreAnalyticsOverviewResponse overview = analyticsMapper.selectScoreOverview();
        ScoreAnalyticsResponse response = new ScoreAnalyticsResponse();
        response.setRoleCode(profile.roleCode());
        response.setRoleName(profile.roleName());
        response.setGranularity(profile.scoreGranularity());
        response.setScopeNote(profile.scoreScopeNote());
        response.setSummaryCards(buildScoreSummaryCards(overview));
        response.setCollegeRanking(analyticsMapper.selectCollegeAverageRanking(rankingLimit));
        response.setMajorRanking(analyticsMapper.selectMajorAverageRanking(rankingLimit));
        response.setCourseRanking(analyticsMapper.selectCourseAverageRanking(rankingLimit));
        response.setScoreDistribution(analyticsMapper.selectScoreDistribution());
        return response;
    }

    @Override
    public SensitiveAnalyticsResponse getSensitiveAnalytics(SecurityUser currentUser) {
        SecurityUser user = requireCurrentUser(currentUser);
        RoleAnalyticsProfile profile = buildRoleProfile(user);
        Long effectiveRoleId = profile.roleId();
        if (effectiveRoleId == null) {
            RoleEntity role = roleMapper.selectByCode(profile.roleCode());
            effectiveRoleId = role == null ? null : role.getId();
        }
        if (effectiveRoleId == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "当前角色未配置脱敏规则上下文");
        }

        List<MaskingRuleViewResponse> rules = maskingRuleMapper.selectMaskingRules(effectiveRoleId, null);
        List<SensitiveCoverageItemResponse> coverage = analyticsMapper.selectSensitiveCoverage();

        SensitiveAnalyticsResponse response = new SensitiveAnalyticsResponse();
        response.setRoleCode(profile.roleCode());
        response.setRoleName(profile.roleName());
        response.setGranularity(profile.sensitiveGranularity());
        response.setScopeNote(profile.sensitiveScopeNote());
        response.setFieldCatalog(buildFieldCatalog(rules));
        response.setCoverage(coverage);
        response.setLevelDistribution(buildLevelDistribution(rules));
        response.setSummaryCards(buildSensitiveSummaryCards(rules, coverage, profile));
        response.setVisibilitySamples(analyticsMapper.selectSensitiveVisibilitySamples(effectiveRoleId));
        return response;
    }

    private SecurityUser requireCurrentUser(SecurityUser currentUser) {
        if (currentUser == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "登录状态已失效");
        }
        return currentUser;
    }

    private RoleAnalyticsProfile buildRoleProfile(SecurityUser currentUser) {
        String roleCode = resolveRoleCode(currentUser);
        if (ROLE_SUPER_ADMIN.equals(roleCode)) {
            return new RoleAnalyticsProfile(null, roleCode, "超级管理员",
                    "全局统计视角", "展示全量聚合统计结果，不返回敏感明细记录。",
                    "策略全景视角", "展示敏感字段目录、覆盖率和当前角色实际脱敏效果。");
        }

        for (RoleOptionResponse role : currentUser.getRoles()) {
            if (roleCode.equals(role.getRoleCode())) {
                return new RoleAnalyticsProfile(role.getId(), roleCode, role.getRoleName(),
                        resolveScoreGranularity(roleCode), resolveScoreScopeNote(roleCode),
                        resolveSensitiveGranularity(roleCode), resolveSensitiveScopeNote(roleCode));
            }
        }

        return new RoleAnalyticsProfile(null, roleCode, roleCode,
                resolveScoreGranularity(roleCode), resolveScoreScopeNote(roleCode),
                resolveSensitiveGranularity(roleCode), resolveSensitiveScopeNote(roleCode));
    }

    private String resolveRoleCode(SecurityUser currentUser) {
        if (currentUser.isSuperAdmin()) {
            return ROLE_SUPER_ADMIN;
        }

        List<String> roleCodes = currentUser.getRoles().stream()
                .map(RoleOptionResponse::getRoleCode)
                .toList();

        if (roleCodes.contains(ROLE_STUDENT)) {
            return ROLE_STUDENT;
        }
        if (roleCodes.contains(ROLE_DATA_ADMIN)) {
            return ROLE_DATA_ADMIN;
        }
        if (roleCodes.contains(ROLE_TEACHER)) {
            return ROLE_TEACHER;
        }
        if (roleCodes.contains(ROLE_ANALYST)) {
            return ROLE_ANALYST;
        }
        if (roleCodes.contains(ROLE_NORMAL)) {
            return ROLE_NORMAL;
        }
        return roleCodes.isEmpty() ? ROLE_NORMAL : roleCodes.get(0);
    }

    private int resolveRankingLimit(String roleCode) {
        if (ROLE_SUPER_ADMIN.equals(roleCode) || ROLE_DATA_ADMIN.equals(roleCode)) {
            return 8;
        }
        if (ROLE_TEACHER.equals(roleCode)) {
            return 6;
        }
        if (ROLE_ANALYST.equals(roleCode)) {
            return 6;
        }
        return 5;
    }

    private String resolveScoreGranularity(String roleCode) {
        if (ROLE_TEACHER.equals(roleCode)) {
            return "教学统计视角";
        }
        if (ROLE_ANALYST.equals(roleCode)) {
            return "聚合分析视角";
        }
        return "全局统计视角";
    }

    private String resolveScoreScopeNote(String roleCode) {
        if (ROLE_TEACHER.equals(roleCode)) {
            return "教师角色仅展示业务允许范围内的聚合统计结果，不返回学生敏感明细。";
        }
        if (ROLE_ANALYST.equals(roleCode)) {
            return "分析角色强调聚合结果与分布趋势，不返回任何学生级敏感明细。";
        }
        return "页面展示全局聚合统计结果，不影响现有成绩查询与脱敏逻辑。";
    }

    private String resolveSensitiveGranularity(String roleCode) {
        if (ROLE_ANALYST.equals(roleCode)) {
            return "聚合脱敏视角";
        }
        if (ROLE_TEACHER.equals(roleCode)) {
            return "教学可见视角";
        }
        return "策略全景视角";
    }

    private String resolveSensitiveScopeNote(String roleCode) {
        if (ROLE_ANALYST.equals(roleCode)) {
            return "分析角色重点查看字段覆盖率、策略分布和当前角色的脱敏可见效果。";
        }
        if (ROLE_TEACHER.equals(roleCode)) {
            return "教师角色仅查看敏感字段聚合统计和实际脱敏效果，不展示敏感明细。";
        }
        return "页面直接复用现有脱敏规则与数据库函数，展示当前角色的真实可见效果。";
    }

    private List<AnalyticsMetricResponse> buildScoreSummaryCards(ScoreAnalyticsOverviewResponse overview) {
        ScoreAnalyticsOverviewResponse safeOverview = overview == null ? new ScoreAnalyticsOverviewResponse() : overview;
        List<AnalyticsMetricResponse> cards = new ArrayList<>();
        cards.add(metric("成绩记录数", formatInteger(safeOverview.getTotalScoreRecords()), "用于衡量当前成绩分析样本规模。"));
        cards.add(metric("覆盖学生数", formatInteger(safeOverview.getTotalStudents()), "按学生成绩记录去重统计。"));
        cards.add(metric("覆盖学期数", formatInteger(safeOverview.getSemesterCount()), "复用 semester_info 统计当前分析覆盖的学期范围。"));
        cards.add(metric("平均成绩", formatDecimal(safeOverview.getAverageScore()), "基于全部成绩记录计算平均值。"));
        cards.add(metric("及格率", formatPercent(safeOverview.getPassRate()), "统计成绩大于等于 60 分的记录占比。"));
        return cards;
    }

    private List<SensitiveFieldAnalyticsItemResponse> buildFieldCatalog(List<MaskingRuleViewResponse> rules) {
        List<SensitiveFieldAnalyticsItemResponse> items = new ArrayList<>();
        for (MaskingRuleViewResponse rule : rules) {
            SensitiveFieldAnalyticsItemResponse item = new SensitiveFieldAnalyticsItemResponse();
            item.setFieldLabel(resolveFieldLabel(rule.getColumnName(), rule.getFieldLabel()));
            item.setSensitiveType(rule.getSensitiveType());
            item.setSensitiveLevel(rule.getSensitiveLevel());
            item.setCurrentPolicy(resolvePolicyDisplay(rule));
            item.setPolicySource(rule.getAssignedPolicyId() == null ? "默认策略" : "角色策略");
            items.add(item);
        }
        items.sort(Comparator.comparing(SensitiveFieldAnalyticsItemResponse::getSensitiveLevel,
                Comparator.nullsLast(this::compareSensitiveLevel))
                .thenComparing(SensitiveFieldAnalyticsItemResponse::getFieldLabel, Comparator.nullsLast(String::compareTo)));
        return items;
    }

    private List<SensitiveLevelCountResponse> buildLevelDistribution(List<MaskingRuleViewResponse> rules) {
        Map<String, Long> grouped = new LinkedHashMap<>();
        grouped.put("HIGH", 0L);
        grouped.put("MEDIUM", 0L);
        grouped.put("LOW", 0L);
        for (MaskingRuleViewResponse rule : rules) {
            String level = rule.getSensitiveLevel() == null ? "UNKNOWN" : rule.getSensitiveLevel().toUpperCase(Locale.ROOT);
            grouped.put(level, grouped.getOrDefault(level, 0L) + 1L);
        }

        List<SensitiveLevelCountResponse> items = new ArrayList<>();
        for (Map.Entry<String, Long> entry : grouped.entrySet()) {
            if ("UNKNOWN".equals(entry.getKey()) && entry.getValue() == 0L) {
                continue;
            }
            SensitiveLevelCountResponse item = new SensitiveLevelCountResponse();
            item.setLevel(entry.getKey());
            item.setCount(entry.getValue());
            item.setSortOrder(resolveLevelSort(entry.getKey()));
            items.add(item);
        }
        items.sort(Comparator.comparing(SensitiveLevelCountResponse::getSortOrder, Comparator.nullsLast(Integer::compareTo)));
        return items;
    }

    private List<AnalyticsMetricResponse> buildSensitiveSummaryCards(List<MaskingRuleViewResponse> rules,
                                                                     List<SensitiveCoverageItemResponse> coverage,
                                                                     RoleAnalyticsProfile profile) {
        long totalFields = rules.size();
        long highLevelFields = rules.stream()
                .filter(rule -> "HIGH".equalsIgnoreCase(rule.getSensitiveLevel()))
                .count();
        long roleAssignedFields = rules.stream()
                .filter(rule -> rule.getAssignedPolicyId() != null)
                .count();
        long filledCount = coverage.stream()
                .mapToLong(item -> item.getFilledCount() == null ? 0L : item.getFilledCount())
                .sum();
        long capacity = coverage.stream()
                .mapToLong(item -> item.getTotalCount() == null ? 0L : item.getTotalCount())
                .sum();
        double coverageRate = capacity == 0 ? 0D : (filledCount * 100D / capacity);

        List<AnalyticsMetricResponse> cards = new ArrayList<>();
        cards.add(metric("敏感字段数", String.valueOf(totalFields), "来自 sensitive_field 目录的已启用字段。"));
        cards.add(metric("高敏字段数", String.valueOf(highLevelFields), "敏感等级为 HIGH 的字段数量。"));
        cards.add(metric("角色定制策略", String.valueOf(roleAssignedFields), profile.roleName() + " 当前使用角色策略覆盖的字段数量。"));
        cards.add(metric("字段填写覆盖率", formatPercent(coverageRate), "手机号、邮箱、身份证、家庭收入四类核心敏感字段的整体填写率。"));
        return cards;
    }

    private AnalyticsMetricResponse metric(String label, String value, String hint) {
        AnalyticsMetricResponse card = new AnalyticsMetricResponse();
        card.setLabel(label);
        card.setValue(value);
        card.setHint(hint);
        return card;
    }

    private String resolvePolicyDisplay(MaskingRuleViewResponse rule) {
        String policyName = firstNonBlank(rule.getEffectiveMaskingTypeName(),
                rule.getAssignedMaskingTypeName(),
                rule.getDefaultMaskingTypeName(),
                rule.getEffectiveMaskingType(),
                rule.getAssignedMaskingType(),
                rule.getDefaultMaskingType());
        String params = firstNonBlank(rule.getEffectiveParams(), rule.getAssignedParams(), rule.getDefaultParams());
        if (params == null || params.isBlank() || "{}".equals(params.trim())) {
            return policyName;
        }
        return policyName + " · " + params;
    }

    private String resolveFieldLabel(String columnName, String fallback) {
        if (columnName == null || columnName.isBlank()) {
            return fallback;
        }
        return switch (columnName) {
            case "name" -> "姓名";
            case "birth_date" -> "出生日期";
            case "phone" -> "手机号";
            case "email" -> "邮箱";
            case "id_card" -> "身份证号";
            case "address" -> "住址";
            case "family_income" -> "家庭收入";
            case "bank_card" -> "银行卡号";
            case "score" -> "成绩";
            default -> fallback == null || fallback.isBlank() ? columnName : fallback;
        };
    }

    private int compareSensitiveLevel(String left, String right) {
        return Integer.compare(resolveLevelSort(left), resolveLevelSort(right));
    }

    private int resolveLevelSort(String level) {
        if ("HIGH".equalsIgnoreCase(level)) {
            return 1;
        }
        if ("MEDIUM".equalsIgnoreCase(level)) {
            return 2;
        }
        if ("LOW".equalsIgnoreCase(level)) {
            return 3;
        }
        return 9;
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value;
            }
        }
        return "";
    }

    private String formatInteger(Long value) {
        return value == null ? "0" : String.valueOf(value);
    }

    private String formatDecimal(Double value) {
        return value == null ? "0.00" : String.format(Locale.ROOT, "%.2f", value);
    }

    private String formatPercent(Double value) {
        return value == null ? "0.00%" : String.format(Locale.ROOT, "%.2f%%", value);
    }

    private record RoleAnalyticsProfile(Long roleId,
                                        String roleCode,
                                        String roleName,
                                        String scoreGranularity,
                                        String scoreScopeNote,
                                        String sensitiveGranularity,
                                        String sensitiveScopeNote) {
    }
}
