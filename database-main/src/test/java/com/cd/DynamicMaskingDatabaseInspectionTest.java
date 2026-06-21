package com.cd;

import static org.junit.jupiter.api.Assertions.assertFalse;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.Test;

class DynamicMaskingDatabaseInspectionTest {

    private static final String JDBC_URL =
            "jdbc:mysql://127.0.0.1:3306/stu_info2026?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=UTF-8";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "root";

    @Test
    void inspectCurrentMaskingSetup() throws Exception {
        try (Connection connection = openConnection()) {
            printObjectPresence(connection);
            printMaskingTableColumns(connection);
            printSensitiveFieldCoverage(connection);
            printStudentProfileSamples(connection);
            printStudentScoreSamples(connection);
            printFilterSamples(connection);
            printMaskFunctionSamples(connection);
            printFallbackSamples(connection);
            printInvalidRoleSample(connection);
            printDynamicAssignmentFallbackCheck(connection);
        }
    }

    @Test
    void applyDynamicMaskingCoreScript() throws Exception {
        List<String> statements = parseSqlScript(Path.of("02_dynamic_masking_core.sql"));
        assertFalse(statements.isEmpty(), "No SQL statements were parsed from 02_dynamic_masking_core.sql");

        try (Connection connection = openConnection();
             Statement statement = connection.createStatement()) {
            for (String sql : statements) {
                statement.execute(sql);
            }
        }
    }

    private Connection openConnection() throws SQLException {
        return DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
    }

    private void printObjectPresence(Connection connection) throws SQLException {
        System.out.println("=== routines ===");
        String sql = """
                SELECT ROUTINE_TYPE, ROUTINE_NAME
                FROM information_schema.ROUTINES
                WHERE ROUTINE_SCHEMA = DATABASE()
                  AND ROUTINE_NAME IN ('FN_APPLY_MASK', 'FN_MASK_BY_ROLE', 'SP_QUERY_STUDENTS', 'SP_QUERY_STUDENT_SCORES')
                ORDER BY ROUTINE_TYPE, ROUTINE_NAME
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                System.out.println(rs.getString("ROUTINE_TYPE") + " " + rs.getString("ROUTINE_NAME"));
            }
        }
    }

    private void printMaskingTableColumns(Connection connection) throws SQLException {
        System.out.println("=== masking table columns ===");
        String sql = """
                SELECT table_name, column_name
                FROM information_schema.COLUMNS
                WHERE table_schema = DATABASE()
                  AND table_name IN ('masking_type_dict', 'masking_policy', 'masking_rule_assignment')
                ORDER BY table_name, ordinal_position
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                System.out.println(rs.getString("table_name") + "." + rs.getString("column_name"));
            }
        }
    }

    private void printSensitiveFieldCoverage(Connection connection) throws SQLException {
        System.out.println("=== sensitive fields ===");
        String sql = """
                SELECT table_name, column_name, enabled
                FROM sensitive_field
                WHERE table_name IN ('v_student_profile', 'v_student_score_detail')
                ORDER BY table_name, column_name
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                System.out.println(
                        rs.getString("table_name") + "." + rs.getString("column_name") + " enabled=" + rs.getInt("enabled"));
            }
        }
    }

    private void printStudentProfileSamples(Connection connection) throws SQLException {
        System.out.println("=== student profile samples ===");
        printProcedureResults(connection, "CALL SP_QUERY_STUDENTS(1, 'SUPER_ADMIN', '2023001', NULL, NULL)");
        printProcedureResults(connection, "CALL SP_QUERY_STUDENTS(5, 'TEACHER', '2023001', NULL, NULL)");
        printProcedureResults(connection, "CALL SP_QUERY_STUDENTS(6, 'ANALYST', '2023001', NULL, NULL)");
        printProcedureResults(connection, "CALL SP_QUERY_STUDENTS(8, 'NORMAL', '2023001', NULL, NULL)");
        printProcedureResults(connection, "CALL SP_QUERY_STUDENTS(1, 'STUDENT', '2023001', NULL, NULL)");
    }

    private void printStudentScoreSamples(Connection connection) throws SQLException {
        System.out.println("=== student score samples ===");
        if (!routineExists(connection, "PROCEDURE", "SP_QUERY_STUDENT_SCORES")) {
            System.out.println("SP_QUERY_STUDENT_SCORES is missing");
            return;
        }
        printProcedureResults(connection, "CALL SP_QUERY_STUDENT_SCORES(1, 'SUPER_ADMIN', '2023001', NULL, NULL)");
        printProcedureResults(connection, "CALL SP_QUERY_STUDENT_SCORES(5, 'TEACHER', '2023001', NULL, NULL)");
        printProcedureResults(connection, "CALL SP_QUERY_STUDENT_SCORES(6, 'ANALYST', '2023001', NULL, NULL)");
        printProcedureResults(connection, "CALL SP_QUERY_STUDENT_SCORES(8, 'NORMAL', '2023001', NULL, NULL)");
        printProcedureResults(connection, "CALL SP_QUERY_STUDENT_SCORES(1, 'STUDENT', '2023001', NULL, NULL)");
    }

    private void printFilterSamples(Connection connection) throws SQLException {
        System.out.println("=== filter samples ===");
        printProcedureResults(connection, "CALL SP_QUERY_STUDENTS(5, 'TEACHER', '2023001', NULL, NULL)");
        printProcedureResults(connection, "CALL SP_QUERY_STUDENTS(5, 'TEACHER', NULL, '张', NULL)");
        printProcedureResults(connection, "CALL SP_QUERY_STUDENTS(5, 'TEACHER', NULL, NULL, '计算机科学2301班')");
        printProcedureResults(connection, "CALL SP_QUERY_STUDENT_SCORES(5, 'TEACHER', '2023001', '数据结构', '2023秋')");
    }

    private void printMaskFunctionSamples(Connection connection) throws SQLException {
        System.out.println("=== FN_APPLY_MASK samples ===");
        printQueryResults(connection, "SELECT FN_APPLY_MASK('13800000001', 'NO_MASK', JSON_OBJECT()) AS no_mask_result");
        printQueryResults(connection, "SELECT FN_APPLY_MASK('13800000001', 'FULL_MASK', JSON_OBJECT()) AS full_mask_result");
        printQueryResults(connection, "SELECT FN_APPLY_MASK('张伟', 'KEEP_PREFIX', JSON_OBJECT('prefix', 1)) AS keep_prefix_result");
        printQueryResults(connection, "SELECT FN_APPLY_MASK('6222020000000001', 'KEEP_SUFFIX', JSON_OBJECT('suffix', 4)) AS keep_suffix_result");
        printQueryResults(connection, "SELECT FN_APPLY_MASK('13800000001', 'KEEP_PREFIX_SUFFIX', JSON_OBJECT('prefix', 3, 'suffix', 4)) AS keep_prefix_suffix_result");
        printQueryResults(connection, "SELECT FN_APPLY_MASK('zhangwei@edu.com', 'EMAIL_MASK', JSON_OBJECT()) AS email_mask_result");
        printQueryResults(connection, "SELECT FN_APPLY_MASK('成都高新区', 'ADDRESS_LEVEL', JSON_OBJECT('level', 'province')) AS address_province_result");
        printQueryResults(connection, "SELECT FN_APPLY_MASK('成都高新区', 'ADDRESS_LEVEL', JSON_OBJECT('level', 'city')) AS address_city_result");
        printQueryResults(connection, "SELECT FN_APPLY_MASK('120000', 'GENERALIZATION', JSON_OBJECT('step', 10000)) AS generalization_result");
        printQueryResults(connection, "SELECT FN_APPLY_MASK('2005-03-12', 'KEEP_YEAR', JSON_OBJECT()) AS keep_year_result");
    }

    private void printFallbackSamples(Connection connection) throws SQLException {
        System.out.println("=== FN_MASK_BY_ROLE fallback samples ===");
        printQueryResults(connection, """
                SELECT
                    FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'SUPER_ADMIN'), 'v_student_profile', 'phone', '13800000001') AS super_admin_phone,
                    FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'DATA_ADMIN'), 'v_student_profile', 'phone', '13800000001') AS data_admin_phone,
                    FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'TEACHER'), 'v_student_profile', 'phone', '13800000001') AS teacher_phone,
                    FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'ANALYST'), 'v_student_profile', 'phone', '13800000001') AS analyst_phone,
                    FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'NORMAL'), 'v_student_profile', 'phone', '13800000001') AS normal_phone,
                    FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'ADMIN'), 'v_student_profile', 'phone', '13800000001') AS admin_default_fallback_phone,
                    FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'TEACHER'), 'v_student_profile', 'gender', 'M') AS no_rule_returns_raw_value
                """);
        printQueryResults(connection, """
                SELECT
                    FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'SUPER_ADMIN'), 'v_student_score_detail', 'score', '92.50') AS super_admin_score,
                    FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'TEACHER'), 'v_student_score_detail', 'score', '92.50') AS teacher_score,
                    FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'ANALYST'), 'v_student_score_detail', 'score', '92.50') AS analyst_score,
                    FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'NORMAL'), 'v_student_score_detail', 'score', '92.50') AS normal_score,
                    FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'STUDENT'), 'v_student_score_detail', 'score', '92.50') AS student_score
                """);
    }

    private void printInvalidRoleSample(Connection connection) throws SQLException {
        System.out.println("=== invalid role sample ===");
        try {
            printProcedureResults(connection, "CALL SP_QUERY_STUDENTS(5, 'NOT_EXISTS_ROLE', NULL, NULL, NULL)");
        } catch (SQLException ex) {
            System.out.println("CALL SP_QUERY_STUDENTS invalid role -> " + ex.getMessage());
        }
    }

    private void printDynamicAssignmentFallbackCheck(Connection connection) throws SQLException {
        System.out.println("=== dynamic assignment fallback check ===");
        connection.setAutoCommit(false);
        try {
            printQueryResults(connection, """
                    SELECT FN_MASK_BY_ROLE(
                        (SELECT id FROM role WHERE role_code = 'TEACHER'),
                        'v_student_profile',
                        'phone',
                        '13800000001'
                    ) AS teacher_phone_before
                    """);
            try (PreparedStatement ps = connection.prepareStatement("""
                    UPDATE masking_rule_assignment mra
                    JOIN role r ON r.id = mra.role_id
                    JOIN masking_policy mp ON mp.id = mra.policy_id
                    JOIN sensitive_field sf ON sf.id = mp.sensitive_field_id
                    SET mra.enabled = 0
                    WHERE r.role_code = 'TEACHER'
                      AND sf.table_name = 'v_student_profile'
                      AND sf.column_name = 'phone'
                    """)) {
                ps.executeUpdate();
            }
            printQueryResults(connection, """
                    SELECT FN_MASK_BY_ROLE(
                        (SELECT id FROM role WHERE role_code = 'TEACHER'),
                        'v_student_profile',
                        'phone',
                        '13800000001'
                    ) AS teacher_phone_after_disable
                    """);
        } finally {
            connection.rollback();
            connection.setAutoCommit(true);
        }
    }

    private boolean routineExists(Connection connection, String routineType, String routineName) throws SQLException {
        String sql = """
                SELECT COUNT(*)
                FROM information_schema.ROUTINES
                WHERE ROUTINE_SCHEMA = DATABASE()
                  AND ROUTINE_TYPE = ?
                  AND ROUTINE_NAME = ?
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, routineType);
            ps.setString(2, routineName);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        }
    }

    private void printProcedureResults(Connection connection, String sql) throws SQLException {
        System.out.println(sql);
        try (Statement statement = connection.createStatement();
             ResultSet rs = statement.executeQuery(sql)) {
            printRows(rs);
        }
    }

    private void printQueryResults(Connection connection, String sql) throws SQLException {
        System.out.println(sql);
        try (Statement statement = connection.createStatement();
             ResultSet rs = statement.executeQuery(sql)) {
            printRows(rs);
        }
    }

    private void printRows(ResultSet rs) throws SQLException {
        int columnCount = rs.getMetaData().getColumnCount();
        while (rs.next()) {
            StringBuilder row = new StringBuilder();
            for (int i = 1; i <= columnCount; i++) {
                if (i > 1) {
                    row.append(" | ");
                }
                row.append(rs.getMetaData().getColumnLabel(i)).append('=').append(rs.getString(i));
            }
            System.out.println(row);
        }
    }

    private List<String> parseSqlScript(Path scriptPath) throws IOException {
        List<String> statements = new ArrayList<>();
        List<String> lines = Files.readAllLines(scriptPath, StandardCharsets.UTF_8);
        String delimiter = ";";
        StringBuilder current = new StringBuilder();

        for (String line : lines) {
            String trimmed = line.trim();

            if (trimmed.startsWith("DELIMITER ")) {
                delimiter = trimmed.substring("DELIMITER ".length()).trim();
                continue;
            }
            if (trimmed.startsWith("--") || trimmed.startsWith("#")) {
                continue;
            }

            current.append(line).append(System.lineSeparator());
            if (trimmed.endsWith(delimiter)) {
                int endIndex = current.lastIndexOf(delimiter);
                String sql = current.substring(0, endIndex).trim();
                if (!sql.isEmpty()) {
                    statements.add(sql);
                }
                current.setLength(0);
            }
        }

        String tail = current.toString().trim();
        if (!tail.isEmpty()) {
            statements.add(tail);
        }
        return statements;
    }
}
