package com.cd.service.impl;

import com.cd.dto.RoleOptionResponse;
import com.cd.dto.StudentProfileMaskedResponse;
import com.cd.dto.StudentScoreMaskedResponse;
import com.cd.security.SecurityUser;
import com.cd.service.StudentMaskingService;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class StudentMaskingServiceImpl implements StudentMaskingService {

    private static final String ROLE_SUPER_ADMIN = "SUPER_ADMIN";
    private static final String ROLE_DATA_ADMIN = "DATA_ADMIN";
    private static final String ROLE_TEACHER = "TEACHER";
    private static final String ROLE_ANALYST = "ANALYST";
    private static final String ROLE_NORMAL = "NORMAL";
    private static final String ROLE_STUDENT = "STUDENT";

    private final DataSource dataSource;

    public StudentMaskingServiceImpl(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public List<StudentProfileMaskedResponse> queryStudentProfiles(SecurityUser currentUser,
                                                                   String studentNo,
                                                                   String name,
                                                                   String className) {
        SecurityUser user = requireCurrentUser(currentUser);
        String roleCode = resolveRoleCode(user);
        String effectiveStudentNo = studentNo;
        String effectiveName = name;
        String effectiveClassName = className;

        if (isSelfOnlyRole(roleCode)) {
            effectiveStudentNo = user.getUsername();
            effectiveName = null;
            effectiveClassName = null;
        }

        String sql = "{CALL SP_QUERY_STUDENTS(?, ?, ?, ?, ?)}";
        try (Connection connection = dataSource.getConnection();
             CallableStatement statement = connection.prepareCall(sql)) {
            statement.setLong(1, user.getUserId());
            statement.setString(2, roleCode);
            setNullableString(statement, 3, effectiveStudentNo);
            setNullableString(statement, 4, effectiveName);
            setNullableString(statement, 5, effectiveClassName);

            List<StudentProfileMaskedResponse> results = new ArrayList<>();
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    StudentProfileMaskedResponse item = new StudentProfileMaskedResponse();
                    item.setStudentId(getNullableLong(rs, "student_id"));
                    item.setStudentNo(rs.getString("student_no"));
                    item.setName(rs.getString("name"));
                    item.setGender(rs.getString("gender"));
                    item.setBirthDate(rs.getString("birth_date"));
                    item.setStatus(getNullableInt(rs, "status"));
                    item.setClassName(rs.getString("class_name"));
                    item.setGradeName(rs.getString("grade_name"));
                    item.setEntryYear(getNullableInt(rs, "entry_year"));
                    item.setMajorName(rs.getString("major_name"));
                    item.setCollegeName(rs.getString("college_name"));
                    item.setPhone(rs.getString("phone"));
                    item.setEmail(rs.getString("email"));
                    item.setIdCard(rs.getString("id_card"));
                    item.setAddress(rs.getString("address"));
                    item.setFamilyIncome(rs.getString("family_income"));
                    item.setBankCard(rs.getString("bank_card"));
                    results.add(item);
                }
            }
            return results;
        } catch (SQLException ex) {
            throw new IllegalStateException("Failed to query masked student profiles", ex);
        }
    }

    @Override
    public List<StudentScoreMaskedResponse> queryStudentScores(SecurityUser currentUser,
                                                               String studentNo,
                                                               String courseName,
                                                               String semesterName) {
        SecurityUser user = requireCurrentUser(currentUser);
        String roleCode = resolveRoleCode(user);
        String effectiveStudentNo = studentNo;
        String effectiveCourseName = courseName;
        String effectiveSemesterName = semesterName;

        if (isSelfOnlyRole(roleCode)) {
            effectiveStudentNo = user.getUsername();
            effectiveCourseName = null;
            effectiveSemesterName = null;
        }

        String sql = "{CALL SP_QUERY_STUDENT_SCORES(?, ?, ?, ?, ?)}";
        try (Connection connection = dataSource.getConnection();
             CallableStatement statement = connection.prepareCall(sql)) {
            statement.setLong(1, user.getUserId());
            statement.setString(2, roleCode);
            setNullableString(statement, 3, effectiveStudentNo);
            setNullableString(statement, 4, effectiveCourseName);
            setNullableString(statement, 5, effectiveSemesterName);

            List<StudentScoreMaskedResponse> results = new ArrayList<>();
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    StudentScoreMaskedResponse item = new StudentScoreMaskedResponse();
                    item.setScoreId(getNullableLong(rs, "score_id"));
                    item.setStudentId(getNullableLong(rs, "student_id"));
                    item.setStudentNo(rs.getString("student_no"));
                    item.setStudentName(rs.getString("student_name"));
                    item.setCourseCode(rs.getString("course_code"));
                    item.setCourseName(rs.getString("course_name"));
                    item.setSemesterName(rs.getString("semester_name"));
                    item.setScore(rs.getString("score"));
                    item.setScoreLevel(rs.getString("score_level"));
                    results.add(item);
                }
            }
            return results;
        } catch (SQLException ex) {
            throw new IllegalStateException("Failed to query masked student scores", ex);
        }
    }

    private SecurityUser requireCurrentUser(SecurityUser currentUser) {
        if (currentUser == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Login state is invalid");
        }
        return currentUser;
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
        if (!roleCodes.isEmpty()) {
            return roleCodes.get(0);
        }
        return ROLE_NORMAL;
    }

    private boolean isSelfOnlyRole(String roleCode) {
        return ROLE_STUDENT.equals(roleCode);
    }

    private void setNullableString(CallableStatement statement, int index, String value) throws SQLException {
        if (value == null || value.isBlank()) {
            statement.setNull(index, Types.VARCHAR);
        } else {
            statement.setString(index, value.trim());
        }
    }

    private Long getNullableLong(ResultSet rs, String column) throws SQLException {
        long value = rs.getLong(column);
        return rs.wasNull() ? null : value;
    }

    private Integer getNullableInt(ResultSet rs, String column) throws SQLException {
        int value = rs.getInt(column);
        return rs.wasNull() ? null : value;
    }
}
