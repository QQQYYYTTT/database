package com.cd;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.cd.security.JwtTokenService;
import com.cd.security.SecurityUser;
import com.cd.security.SecurityUserService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import javax.sql.DataSource;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

@SpringBootTest
@AutoConfigureMockMvc
class StudentMaskingApiIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private SecurityUserService securityUserService;

    @Autowired
    private JwtTokenService jwtTokenService;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private DataSource dataSource;

    private String teacherToken;
    private String analystToken;
    private String normalToken;
    private String studentToken;
    private String superAdminToken;
    private String basicUserToken;

    @BeforeEach
    void setUp() {
        restoreTeacherPhoneRule();
        teacherToken = tokenFor("mask_teacher");
        analystToken = tokenFor("mask_analyst");
        normalToken = tokenFor("mask_normal");
        studentToken = tokenFor("2023001");
        superAdminToken = tokenFor("admin");
        basicUserToken = tokenFor("lily");
    }

    @Test
    void studentProfilesShouldReturnDifferentMaskingByRole() throws Exception {
        clearAuditLogs();
        JsonNode superAdminRow = firstDataRow(mockMvc.perform(
                        get("/api/student-profiles")
                                .header("Authorization", bearer(superAdminToken))
                                .param("studentNo", "2023001"))
                .andExpect(status().isOk())
                .andReturn());
        JsonNode teacherRow = firstDataRow(mockMvc.perform(
                        get("/api/student-profiles")
                                .header("Authorization", bearer(teacherToken))
                                .param("studentNo", "2023001"))
                .andExpect(status().isOk())
                .andReturn());
        JsonNode analystRow = firstDataRow(mockMvc.perform(
                        get("/api/student-profiles")
                                .header("Authorization", bearer(analystToken))
                                .param("studentNo", "2023001"))
                .andExpect(status().isOk())
                .andReturn());
        JsonNode normalRow = firstDataRow(mockMvc.perform(
                        get("/api/student-profiles")
                                .header("Authorization", bearer(normalToken))
                                .param("studentNo", "2023001"))
                .andExpect(status().isOk())
                .andReturn());
        JsonNode studentRow = firstDataRow(mockMvc.perform(
                        get("/api/student-profiles")
                                .header("Authorization", bearer(studentToken))
                                .param("studentNo", "2023001"))
                .andExpect(status().isOk())
                .andReturn());

        assertEquals("张伟", superAdminRow.path("name").asText());
        assertEquals("张伟", studentRow.path("name").asText());
        assertEquals("张*", teacherRow.path("name").asText());
        assertEquals("张*", analystRow.path("name").asText());
        assertEquals("**", normalRow.path("name").asText());

        assertEquals("13800000001", superAdminRow.path("phone").asText());
        assertEquals("13800000001", studentRow.path("phone").asText());
        assertEquals("138****0001", teacherRow.path("phone").asText());
        assertEquals("138****0001", analystRow.path("phone").asText());
        assertEquals("***********", normalRow.path("phone").asText());
    }

    @Test
    void studentScoresShouldReturnDifferentMaskingByRole() throws Exception {
        clearAuditLogs();
        JsonNode teacherRow = firstDataRow(mockMvc.perform(
                        get("/api/student-scores")
                                .header("Authorization", bearer(teacherToken))
                                .param("studentNo", "2023001"))
                .andExpect(status().isOk())
                .andReturn());
        JsonNode analystRow = firstDataRow(mockMvc.perform(
                        get("/api/student-scores")
                                .header("Authorization", bearer(analystToken))
                                .param("studentNo", "2023001"))
                .andExpect(status().isOk())
                .andReturn());
        JsonNode normalRow = firstDataRow(mockMvc.perform(
                        get("/api/student-scores")
                                .header("Authorization", bearer(normalToken))
                                .param("studentNo", "2023001"))
                .andExpect(status().isOk())
                .andReturn());
        JsonNode studentRow = firstDataRow(mockMvc.perform(
                        get("/api/student-scores")
                                .header("Authorization", bearer(studentToken))
                                .param("studentNo", "2023001"))
                .andExpect(status().isOk())
                .andReturn());

        assertEquals("92.50", teacherRow.path("score").asText());
        assertEquals("90-100", analystRow.path("score").asText());
        assertEquals("*****", normalRow.path("score").asText());
        assertEquals("92.50", studentRow.path("score").asText());
        assertEquals("2023秋", teacherRow.path("semesterName").asText());
    }

    @Test
    void studentRoleShouldOnlySeeSelfEvenWhenPassingAnotherStudentNo() throws Exception {
        JsonNode root = readBody(mockMvc.perform(
                        get("/api/student-profiles")
                                .header("Authorization", bearer(studentToken))
                                .param("studentNo", "2023002")
                                .param("name", "李")
                                .param("className", "网安2301班"))
                .andExpect(status().isOk())
                .andReturn());

        JsonNode data = root.path("data");
        assertEquals(1, data.size());
        assertEquals("2023001", data.get(0).path("studentNo").asText());
    }

    @Test
    void unauthorizedShouldReturn401() throws Exception {
        mockMvc.perform(get("/api/student-profiles"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void forbiddenShouldReturn403ForUserWithoutPermission() throws Exception {
        mockMvc.perform(
                        get("/api/student-profiles")
                                .header("Authorization", bearer(basicUserToken)))
                .andExpect(status().isForbidden());
    }

    @Test
    void routineBusinessErrorShouldReturn400WhenResolvedRoleIsDisabled() throws Exception {
        try (var connection = dataSource.getConnection();
             var disableTeacher = connection.prepareStatement("UPDATE role SET enabled = 0 WHERE role_code = 'TEACHER'");
             var restoreTeacher = connection.prepareStatement("UPDATE role SET enabled = 1 WHERE role_code = 'TEACHER'")) {
            disableTeacher.executeUpdate();
            try {
                teacherToken = tokenFor("mask_teacher");

                JsonNode root = readBody(mockMvc.perform(
                                get("/api/student-profiles")
                                        .header("Authorization", bearer(teacherToken)))
                        .andExpect(status().isBadRequest())
                        .andReturn());

                assertEquals(400, root.path("code").asInt());
                assertTrue(root.path("message").asText().contains("角色不存在或已禁用"));
            } finally {
                restoreTeacher.executeUpdate();
            }
        }
    }

    @Test
    void currentUserShouldExposeStudentAndScoreMenusForMaskingAccounts() throws Exception {
        JsonNode root = readBody(mockMvc.perform(
                        get("/api/user/me")
                                .header("Authorization", bearer(teacherToken)))
                .andExpect(status().isOk())
                .andReturn());

        JsonNode data = root.path("data");
        assertNotNull(data);
        assertTrue(containsText(data.path("permissionCodes"), "biz:student:view"));
        assertTrue(containsText(data.path("permissionCodes"), "biz:score:view"));
        assertTrue(containsMenuKey(data.path("menuTree"), "student"));
        assertTrue(containsMenuKey(data.path("menuTree"), "score"));
    }

    @Test
    void currentUserShouldExposeMaskingRuleMenuForAdminAccount() throws Exception {
        JsonNode root = readBody(mockMvc.perform(
                        get("/api/user/me")
                                .header("Authorization", bearer(superAdminToken)))
                .andExpect(status().isOk())
                .andReturn());

        JsonNode data = root.path("data");
        assertTrue(containsText(data.path("permissionCodes"), "sys:masking-rule:view"));
        assertTrue(containsText(data.path("permissionCodes"), "sys:masking-rule:update"));
        assertTrue(containsMenuKey(data.path("menuTree"), "masking-rule"));
    }

    @Test
    void maskingRuleListShouldSupportPaging() throws Exception {
        JsonNode root = readBody(mockMvc.perform(
                        get("/api/masking-rules")
                                .header("Authorization", bearer(superAdminToken))
                                .param("page", "1")
                                .param("size", "5"))
                .andExpect(status().isOk())
                .andReturn());

        JsonNode data = root.path("data");
        assertEquals(1, data.path("page").asInt());
        assertEquals(5, data.path("size").asInt());
        assertTrue(data.path("records").isArray());
        assertTrue(data.path("records").size() <= 5);
        assertTrue(data.path("total").asLong() >= data.path("records").size());
    }

    @Test
    void updatingMaskingRuleShouldTakeEffectImmediately() throws Exception {
        clearAuditLogs();
        JsonNode before = firstDataRow(mockMvc.perform(
                        get("/api/student-profiles")
                                .header("Authorization", bearer(teacherToken))
                                .param("studentNo", "2023001"))
                .andExpect(status().isOk())
                .andReturn());
        assertEquals("138****0001", before.path("phone").asText());

        JsonNode ruleList = readBody(mockMvc.perform(
                        get("/api/masking-rules")
                                .header("Authorization", bearer(superAdminToken))
                                .param("roleId", "5")
                                .param("sensitiveFieldId", "3")
                                .param("page", "1")
                                .param("size", "10"))
                .andExpect(status().isOk())
                .andReturn());

        JsonNode row = ruleList.path("data").path("records").get(0);
        Long originalPolicyId = row.path("effectivePolicyId").asLong();

        try {
            mockMvc.perform(
                            put("/api/masking-rules")
                                    .header("Authorization", bearer(superAdminToken))
                                    .contentType("application/json")
                                    .content("""
                                            {"roleId":5,"sensitiveFieldId":3,"policyId":7}
                                            """))
                    .andExpect(status().isOk());

            JsonNode after = firstDataRow(mockMvc.perform(
                            get("/api/student-profiles")
                                    .header("Authorization", bearer(teacherToken))
                                    .param("studentNo", "2023001"))
                    .andExpect(status().isOk())
                    .andReturn());
            assertEquals("***********", after.path("phone").asText());
        } finally {
            mockMvc.perform(
                            put("/api/masking-rules")
                                    .header("Authorization", bearer(superAdminToken))
                                    .contentType("application/json")
                                    .content("""
                                            {"roleId":5,"sensitiveFieldId":3,"policyId":%d}
                                            """.formatted(originalPolicyId)))
                    .andExpect(status().isOk());
        }
    }

    @Test
    void queryingStudentProfilesShouldCreateAccessLog() throws Exception {
        clearAuditLogs();

        mockMvc.perform(
                        get("/api/student-profiles")
                                .header("Authorization", bearer(teacherToken))
                                .param("studentNo", "2023001"))
                .andExpect(status().isOk());

        JsonNode root = readBody(mockMvc.perform(
                        get("/api/access-logs")
                                .header("Authorization", bearer(superAdminToken))
                                .param("operationType", "QUERY_STUDENT_PROFILE")
                                .param("page", "1")
                                .param("size", "10"))
                .andExpect(status().isOk())
                .andReturn());

        JsonNode records = root.path("data").path("records");
        assertFalse(records.isEmpty());
        assertEquals("QUERY_STUDENT_PROFILE", records.get(0).path("operationType").asText());
        assertEquals("v_student_profile", records.get(0).path("tableName").asText());
    }

    @Test
    void queryingStudentScoresShouldCreateAccessLog() throws Exception {
        clearAuditLogs();

        mockMvc.perform(
                        get("/api/student-scores")
                                .header("Authorization", bearer(teacherToken))
                                .param("studentNo", "2023001"))
                .andExpect(status().isOk());

        JsonNode root = readBody(mockMvc.perform(
                        get("/api/access-logs")
                                .header("Authorization", bearer(superAdminToken))
                                .param("operationType", "QUERY_STUDENT_SCORE")
                                .param("page", "1")
                                .param("size", "10"))
                .andExpect(status().isOk())
                .andReturn());

        JsonNode records = root.path("data").path("records");
        assertFalse(records.isEmpty());
        assertEquals("QUERY_STUDENT_SCORE", records.get(0).path("operationType").asText());
        assertEquals("v_student_score_detail", records.get(0).path("tableName").asText());
    }

    @Test
    void updatingMaskingRuleShouldCreateRuleChangeLog() throws Exception {
        clearAuditLogs();

        JsonNode ruleList = readBody(mockMvc.perform(
                        get("/api/masking-rules")
                                .header("Authorization", bearer(superAdminToken))
                                .param("roleId", "5")
                                .param("sensitiveFieldId", "3")
                                .param("page", "1")
                                .param("size", "10"))
                .andExpect(status().isOk())
                .andReturn());
        Long originalPolicyId = ruleList.path("data").path("records").get(0).path("effectivePolicyId").asLong();

        try {
            mockMvc.perform(
                            put("/api/masking-rules")
                                    .header("Authorization", bearer(superAdminToken))
                                    .contentType("application/json")
                                    .content("""
                                            {"roleId":5,"sensitiveFieldId":3,"policyId":7}
                                            """))
                    .andExpect(status().isOk());

            JsonNode root = readBody(mockMvc.perform(
                            get("/api/rule-change-logs")
                                    .header("Authorization", bearer(superAdminToken))
                                    .param("page", "1")
                                    .param("size", "10"))
                    .andExpect(status().isOk())
                    .andReturn());

            JsonNode records = root.path("data").path("records");
            assertFalse(records.isEmpty());
            assertTrue(records.get(0).path("operationType").asText().startsWith("MASKING_RULE_"));
            assertTrue(records.get(0).path("afterContent").asText().contains("\"policyId\":\"7\"")
                    || records.get(0).path("afterContent").asText().contains("\"policyId\":7"));
        } finally {
            mockMvc.perform(
                            put("/api/masking-rules")
                                    .header("Authorization", bearer(superAdminToken))
                                    .contentType("application/json")
                                    .content("""
                                            {"roleId":5,"sensitiveFieldId":3,"policyId":%d}
                                            """.formatted(originalPolicyId)))
                    .andExpect(status().isOk());
        }
    }

    @Test
    void detectingAbnormalAccessShouldCreateAbnormalAccessLog() throws Exception {
        clearAuditLogs();

        for (int i = 0; i < 6; i++) {
            mockMvc.perform(
                            get("/api/student-profiles")
                                    .header("Authorization", bearer(normalToken))
                                    .param("studentNo", "2023001"))
                    .andExpect(status().isOk());
        }

        mockMvc.perform(
                        org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post("/api/abnormal-access/detect")
                                .header("Authorization", bearer(superAdminToken)))
                .andExpect(status().isOk());

        JsonNode root = readBody(mockMvc.perform(
                        get("/api/abnormal-access")
                                .header("Authorization", bearer(superAdminToken))
                                .param("page", "1")
                                .param("size", "20"))
                .andExpect(status().isOk())
                .andReturn());

        JsonNode records = root.path("data").path("records");
        assertFalse(records.isEmpty());

        boolean matched = false;
        for (JsonNode record : records) {
            if ("SHORT_TIME_HIGH_FREQ".equals(record.path("ruleName").asText())
                    && "mask_normal".equals(record.path("userName").asText())) {
                matched = true;
                assertTrue(record.path("triggerCount").asInt() >= 6);
                break;
            }
        }
        assertTrue(matched);
    }

    private void clearAuditLogs() throws Exception {
        try (var connection = dataSource.getConnection();
             var clearAccess = connection.prepareStatement("DELETE FROM access_log");
             var clearRuleChange = connection.prepareStatement("DELETE FROM rule_change_log");
             var clearAbnormal = connection.prepareStatement("DELETE FROM abnormal_access")) {
            clearAccess.executeUpdate();
            clearRuleChange.executeUpdate();
            clearAbnormal.executeUpdate();
        }
    }

    private void restoreTeacherPhoneRule() {
        try (var connection = dataSource.getConnection();
             var disableAll = connection.prepareStatement("""
                     UPDATE masking_rule_assignment mra
                     JOIN masking_policy mp ON mp.id = mra.policy_id
                     SET mra.enabled = 0
                     WHERE mra.role_id = 5
                       AND mp.sensitive_field_id = 3
                     """);
             var enableBaseline = connection.prepareStatement("""
                     UPDATE masking_rule_assignment
                     SET enabled = 1
                     WHERE role_id = 5
                       AND policy_id = 9
                     """)) {
            disableAll.executeUpdate();
            enableBaseline.executeUpdate();
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to restore teacher phone masking rule", ex);
        }
    }

    private String tokenFor(String userName) {
        SecurityUser user = securityUserService.loadSecurityUserByUsername(userName);
        assertNotNull(user, "Expected test user to exist: " + userName);
        return jwtTokenService.generateToken(user);
    }

    private JsonNode firstDataRow(MvcResult result) throws Exception {
        JsonNode root = readBody(result);
        JsonNode data = root.path("data");
        assertFalse(data.isEmpty());
        return data.get(0);
    }

    private JsonNode readBody(MvcResult result) throws Exception {
        String content = result.getResponse().getContentAsString(StandardCharsets.UTF_8);
        return objectMapper.readTree(content);
    }

    private String bearer(String token) {
        return "Bearer " + token;
    }

    private boolean containsText(JsonNode arrayNode, String expected) {
        if (arrayNode == null || !arrayNode.isArray()) {
            return false;
        }
        for (JsonNode node : arrayNode) {
            if (expected.equals(node.asText())) {
                return true;
            }
        }
        return false;
    }

    private boolean containsMenuKey(JsonNode menuTree, String expectedMenuKey) {
        if (menuTree == null || !menuTree.isArray()) {
            return false;
        }
        for (JsonNode node : menuTree) {
            if (expectedMenuKey.equals(node.path("menuKey").asText())) {
                return true;
            }
            if (containsMenuKey(node.path("children"), expectedMenuKey)) {
                return true;
            }
        }
        return false;
    }
}
