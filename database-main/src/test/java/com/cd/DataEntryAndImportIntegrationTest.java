package com.cd;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.cd.security.JwtTokenService;
import com.cd.security.SecurityUser;
import com.cd.security.SecurityUserService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import javax.sql.DataSource;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

@SpringBootTest
@AutoConfigureMockMvc
class DataEntryAndImportIntegrationTest {

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

    private String superAdminToken;
    private String teacherToken;

    @BeforeEach
    void setUp() {
        superAdminToken = tokenFor("admin");
        teacherToken = tokenFor("mask_teacher");
    }

    @Test
    void createStudentShouldPersistAndBeQueryable() throws Exception {
        String suffix = uniqueSuffix();
        String studentNo = "91" + suffix;

        JsonNode root = readBody(mockMvc.perform(
                        post("/api/students")
                                .header("Authorization", bearer(superAdminToken))
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                        {
                                          "classId": 1,
                                          "studentNo": "%s",
                                          "name": "EntryStudent%s",
                                          "gender": "M",
                                          "birthDate": "2005-01-01",
                                          "phone": "139%s",
                                          "email": "entry%s@example.com",
                                          "address": "Test Address"
                                        }
                                        """.formatted(studentNo, suffix, suffix, suffix)))
                .andExpect(status().isOk())
                .andReturn());

        assertEquals(200, root.path("code").asInt());
        assertEquals(1, countStudentByStudentNo(studentNo));

        JsonNode queryRoot = readBody(mockMvc.perform(
                        get("/api/student-profiles")
                                .header("Authorization", bearer(superAdminToken))
                                .param("studentNo", studentNo))
                .andExpect(status().isOk())
                .andReturn());
        assertEquals(studentNo, queryRoot.path("data").get(0).path("studentNo").asText());
    }

    @Test
    void createStudentScoreShouldPersistAndBeQueryable() throws Exception {
        String suffix = uniqueSuffix();
        String studentNo = "92" + suffix;
        createStudent(studentNo, "ScoreStudent" + suffix);

        JsonNode root = readBody(mockMvc.perform(
                        post("/api/students/scores")
                                .header("Authorization", bearer(superAdminToken))
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                        {
                                          "studentNo": "%s",
                                          "courseId": 1,
                                          "semesterId": 1,
                                          "score": 87.5
                                        }
                                        """.formatted(studentNo)))
                .andExpect(status().isOk())
                .andReturn());

        assertEquals(200, root.path("code").asInt());
        assertEquals("87.50", queryScoreValue(studentNo, 1L, 1L).toPlainString());

        JsonNode queryRoot = readBody(mockMvc.perform(
                        get("/api/student-scores")
                                .header("Authorization", bearer(superAdminToken))
                                .param("studentNo", studentNo))
                .andExpect(status().isOk())
                .andReturn());
        assertEquals(studentNo, queryRoot.path("data").get(0).path("studentNo").asText());
        assertEquals("87.50", queryRoot.path("data").get(0).path("score").asText());
    }

    @Test
    void importUsersShouldSupportPartialSuccess() throws Exception {
        String suffix = uniqueSuffix();
        String userName = "impu" + suffix;
        MockMultipartFile file = workbookFile(
                "users.xlsx",
                new String[]{"用户名", "密码", "手机号", "邮箱", "头像地址", "角色编码"},
                List.of(
                        new String[]{userName, "123456", "139" + suffix, "user" + suffix + "@example.com", "", "USER"},
                        new String[]{"admin", "123456", "13999999999", "dup@example.com", "", "USER"}
                )
        );

        JsonNode root = readBody(mockMvc.perform(
                        multipart("/api/import/{importType}", "user")
                                .file(file)
                                .header("Authorization", bearer(superAdminToken)))
                .andExpect(status().isOk())
                .andReturn());

        JsonNode data = root.path("data");
        assertEquals(1, data.path("successCount").asInt());
        assertEquals(1, data.path("failureCount").asInt());
        assertEquals(1, countUserByUserName(userName));
    }

    @Test
    void importStudentsShouldSupportPartialSuccess() throws Exception {
        String suffix = uniqueSuffix();
        String studentNo = "93" + suffix;
        MockMultipartFile file = workbookFile(
                "students.xlsx",
                new String[]{"学号", "姓名", "性别", "出生日期", "班级代码", "手机号", "邮箱", "身份证号", "住址", "家庭收入", "银行卡号"},
                List.of(
                        new String[]{studentNo, "ImportStudent" + suffix, "F", "2005-02-02", "CS2301", "139" + suffix, "student" + suffix + "@example.com", "", "Addr", "12345.67", ""},
                        new String[]{"94" + suffix, "BadClass" + suffix, "M", "2005-02-02", "BAD_CLASS", "13812345678", "", "", "", "", ""}
                )
        );

        JsonNode root = readBody(mockMvc.perform(
                        multipart("/api/import/{importType}", "student")
                                .file(file)
                                .header("Authorization", bearer(superAdminToken)))
                .andExpect(status().isOk())
                .andReturn());

        JsonNode data = root.path("data");
        assertEquals(1, data.path("successCount").asInt());
        assertEquals(1, data.path("failureCount").asInt());
        assertEquals(1, countStudentByStudentNo(studentNo));
    }

    @Test
    void importScoresShouldSupportPartialSuccess() throws Exception {
        String suffix = uniqueSuffix();
        String studentNo = "95" + suffix;
        createStudent(studentNo, "ImportScoreStudent" + suffix);
        String semesterName = querySemesterName(1L);

        MockMultipartFile file = workbookFile(
                "scores.xlsx",
                new String[]{"学号", "课程代码", "学期名称", "成绩"},
                List.of(
                        new String[]{studentNo, "C001", semesterName, "78.50"},
                        new String[]{"NOT_EXIST_" + suffix, "C001", semesterName, "66.00"}
                )
        );

        JsonNode root = readBody(mockMvc.perform(
                        multipart("/api/import/{importType}", "score")
                                .file(file)
                                .header("Authorization", bearer(superAdminToken)))
                .andExpect(status().isOk())
                .andReturn());

        JsonNode data = root.path("data");
        assertEquals(1, data.path("successCount").asInt());
        assertEquals(1, data.path("failureCount").asInt());
        assertEquals("78.50", queryScoreValue(studentNo, 1L, 1L).toPlainString());
    }

    @Test
    void teacherShouldNotCreateScoreOrImportExcel() throws Exception {
        mockMvc.perform(
                        post("/api/students/scores")
                                .header("Authorization", bearer(teacherToken))
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                        {
                                          "studentNo": "2023001",
                                          "courseId": 1,
                                          "semesterId": 1,
                                          "score": 88
                                        }
                                        """))
                .andExpect(status().isForbidden());

        MockMultipartFile file = workbookFile(
                "scores.xlsx",
                new String[]{"学号", "课程代码", "学期名称", "成绩"},
                List.<String[]>of(new String[]{"2023001", "C001", querySemesterName(1L), "88.00"})
        );

        mockMvc.perform(
                        multipart("/api/import/{importType}", "score")
                                .file(file)
                                .header("Authorization", bearer(teacherToken)))
                .andExpect(status().isForbidden());
    }

    private void createStudent(String studentNo, String name) throws Exception {
        mockMvc.perform(
                        post("/api/students")
                                .header("Authorization", bearer(superAdminToken))
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                        {
                                          "classId": 1,
                                          "studentNo": "%s",
                                          "name": "%s",
                                          "gender": "M",
                                          "birthDate": "2005-01-01"
                                        }
                                        """.formatted(studentNo, name)))
                .andExpect(status().isOk());
    }

    private MockMultipartFile workbookFile(String fileName, String[] headers, List<String[]> rows) throws Exception {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet("Sheet1");
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.length; i++) {
                headerRow.createCell(i).setCellValue(headers[i]);
            }
            for (int rowIndex = 0; rowIndex < rows.size(); rowIndex++) {
                Row row = sheet.createRow(rowIndex + 1);
                String[] values = rows.get(rowIndex);
                for (int colIndex = 0; colIndex < values.length; colIndex++) {
                    row.createCell(colIndex).setCellValue(values[colIndex]);
                }
            }
            workbook.write(outputStream);
            return new MockMultipartFile(
                    "file",
                    fileName,
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    outputStream.toByteArray()
            );
        }
    }

    private int countUserByUserName(String userName) throws Exception {
        return countBySql("SELECT COUNT(*) FROM `user` WHERE user_name = ?", userName);
    }

    private int countStudentByStudentNo(String studentNo) throws Exception {
        return countBySql("SELECT COUNT(*) FROM student WHERE student_no = ?", studentNo);
    }

    private int countBySql(String sql, String value) throws Exception {
        try (Connection connection = dataSource.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, value);
            try (ResultSet resultSet = statement.executeQuery()) {
                resultSet.next();
                return resultSet.getInt(1);
            }
        }
    }

    private BigDecimal queryScoreValue(String studentNo, Long courseId, Long semesterId) throws Exception {
        try (Connection connection = dataSource.getConnection();
             PreparedStatement statement = connection.prepareStatement("""
                     SELECT sc.score
                     FROM student_score sc
                     JOIN student s ON s.id = sc.student_id
                     WHERE s.student_no = ?
                       AND sc.course_id = ?
                       AND sc.semester_id = ?
                     LIMIT 1
                     """)) {
            statement.setString(1, studentNo);
            statement.setLong(2, courseId);
            statement.setLong(3, semesterId);
            try (ResultSet resultSet = statement.executeQuery()) {
                assertTrue(resultSet.next(), "Expected score record for " + studentNo);
                return resultSet.getBigDecimal(1);
            }
        }
    }

    private String querySemesterName(Long semesterId) throws Exception {
        try (Connection connection = dataSource.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT semester_name FROM semester_info WHERE id = ? LIMIT 1")) {
            statement.setLong(1, semesterId);
            try (ResultSet resultSet = statement.executeQuery()) {
                assertTrue(resultSet.next(), "Expected semester to exist: " + semesterId);
                return resultSet.getString(1);
            }
        }
    }

    private String tokenFor(String userName) {
        SecurityUser user = securityUserService.loadSecurityUserByUsername(userName);
        assertNotNull(user, "Expected test user to exist: " + userName);
        return jwtTokenService.generateToken(user);
    }

    private JsonNode readBody(MvcResult result) throws Exception {
        String content = result.getResponse().getContentAsString(StandardCharsets.UTF_8);
        return objectMapper.readTree(content);
    }

    private String bearer(String token) {
        return "Bearer " + token;
    }

    private String uniqueSuffix() {
        String value = String.valueOf(System.nanoTime());
        return value.substring(Math.max(0, value.length() - 8));
    }
}
