package com.cd.service.impl;

import com.cd.dto.StudentCreateRequest;
import com.cd.dto.StudentManageUpdateRequest;
import com.cd.dto.StudentProfileMaskedResponse;
import com.cd.dto.StudentScoreCreateRequest;
import com.cd.mapper.StudentAdminMapper;
import com.cd.security.SecurityUtils;
import com.cd.service.RuleChangeLogService;
import com.cd.service.StudentAdminService;
import java.math.BigDecimal;
import java.math.RoundingMode;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class StudentAdminServiceImpl implements StudentAdminService {

    private final StudentAdminMapper studentAdminMapper;
    private final RuleChangeLogService ruleChangeLogService;

    public StudentAdminServiceImpl(StudentAdminMapper studentAdminMapper,
                                   RuleChangeLogService ruleChangeLogService) {
        this.studentAdminMapper = studentAdminMapper;
        this.ruleChangeLogService = ruleChangeLogService;
    }

    @Override
    @Transactional
    public void createStudent(StudentCreateRequest request) {
        validateClassExists(request.getClassId());
        if (studentAdminMapper.selectStudentIdByStudentNo(request.getStudentNo()) != null) {
            throw new IllegalArgumentException("学号已存在");
        }
        normalizeStudentRequest(request);
        studentAdminMapper.insertStudent(request);
        studentAdminMapper.insertStudentSensitive(request.getStudentId(), request);
        StudentProfileMaskedResponse afterSnapshot = studentAdminMapper.selectStudentProfileSnapshotById(request.getStudentId());
        ruleChangeLogService.record(currentOperatorName(), "CREATE_STUDENT", null, afterSnapshot);
    }

    @Override
    @Transactional
    public void updateStudent(Long studentId, StudentManageUpdateRequest request) {
        StudentProfileMaskedResponse beforeSnapshot = studentAdminMapper.selectStudentProfileSnapshotById(studentId);
        int updated = studentAdminMapper.updateStudentBasicById(studentId, request);
        if (updated <= 0) {
            throw new IllegalArgumentException("学生不存在");
        }
        studentAdminMapper.upsertStudentSensitive(
                studentId,
                emptyToNull(request.getPhone()),
                emptyToNull(request.getEmail()),
                emptyToNull(request.getAddress())
        );
        StudentProfileMaskedResponse afterSnapshot = studentAdminMapper.selectStudentProfileSnapshotById(studentId);
        ruleChangeLogService.record(currentOperatorName(), "UPDATE_STUDENT", beforeSnapshot, afterSnapshot);
    }

    @Override
    @Transactional
    public void deleteStudent(Long studentId) {
        StudentProfileMaskedResponse beforeSnapshot = studentAdminMapper.selectStudentProfileSnapshotById(studentId);
        studentAdminMapper.deleteStudentScoresByStudentId(studentId);
        studentAdminMapper.deleteStudentSensitiveByStudentId(studentId);
        int deleted = studentAdminMapper.deleteStudentById(studentId);
        if (deleted <= 0) {
            throw new IllegalArgumentException("学生不存在");
        }
        ruleChangeLogService.record(currentOperatorName(), "DELETE_STUDENT", beforeSnapshot, null);
    }

    @Override
    @Transactional
    public void saveStudentScore(StudentScoreCreateRequest request) {
        Long studentId = studentAdminMapper.selectStudentIdByStudentNo(request.getStudentNo());
        if (studentId == null) {
            throw new IllegalArgumentException("学号不存在");
        }
        validateCourseExists(request.getCourseId());
        validateSemesterExists(request.getSemesterId());
        normalizeScoreRequest(request);

        Long scoreId = studentAdminMapper.selectScoreId(studentId, request.getCourseId(), request.getSemesterId());
        if (scoreId == null) {
            studentAdminMapper.insertStudentScore(studentId, request);
            ruleChangeLogService.record(currentOperatorName(), "CREATE_STUDENT_SCORE", null, buildScoreAuditSnapshot(studentId, request));
            return;
        }
        studentAdminMapper.updateStudentScoreById(scoreId, request);
        ruleChangeLogService.record(currentOperatorName(), "UPDATE_STUDENT_SCORE", null, buildScoreAuditSnapshot(studentId, request));
    }

    private void validateClassExists(Long classId) {
        Integer classCount = classId == null || classId <= 0 ? 0 : studentAdminMapper.countClassById(classId);
        if (classCount == null || classCount <= 0) {
            throw new IllegalArgumentException("班级不存在");
        }
    }

    private void validateCourseExists(Long courseId) {
        Integer courseCount = courseId == null || courseId <= 0 ? 0 : studentAdminMapper.countCourseById(courseId);
        if (courseCount == null || courseCount <= 0) {
            throw new IllegalArgumentException("课程不存在");
        }
    }

    private void validateSemesterExists(Long semesterId) {
        Integer semesterCount = semesterId == null || semesterId <= 0 ? 0 : studentAdminMapper.countSemesterById(semesterId);
        if (semesterCount == null || semesterCount <= 0) {
            throw new IllegalArgumentException("学期不存在");
        }
    }

    private void normalizeStudentRequest(StudentCreateRequest request) {
        request.setStudentNo(trimToNull(request.getStudentNo()));
        request.setName(trimToNull(request.getName()));
        request.setGender(trimToNull(request.getGender()));
        request.setBirthDate(trimToNull(request.getBirthDate()));
        request.setStatus(request.getStatus() == null ? 1 : request.getStatus());
        request.setPhone(trimToNull(request.getPhone()));
        request.setEmail(trimToNull(request.getEmail()));
        request.setIdCard(trimToNull(request.getIdCard()));
        request.setAddress(trimToNull(request.getAddress()));
        request.setBankCard(trimToNull(request.getBankCard()));
        request.setFamilyIncome(request.getFamilyIncome() == null ? null : request.getFamilyIncome().setScale(2, RoundingMode.HALF_UP));
    }

    private void normalizeScoreRequest(StudentScoreCreateRequest request) {
        request.setStudentNo(trimToNull(request.getStudentNo()));
        if (request.getScore() != null) {
            request.setScore(request.getScore().setScale(2, RoundingMode.HALF_UP));
        }
    }

    private Object buildScoreAuditSnapshot(Long studentId, StudentScoreCreateRequest request) {
        return java.util.Map.of(
                "studentId", studentId,
                "studentNo", request.getStudentNo(),
                "courseId", request.getCourseId(),
                "semesterId", request.getSemesterId(),
                "score", request.getScore()
        );
    }

    private String emptyToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }

    private String trimToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }

    private String currentOperatorName() {
        var currentUser = SecurityUtils.currentUser();
        return currentUser == null ? "system" : currentUser.getUsername();
    }
}
