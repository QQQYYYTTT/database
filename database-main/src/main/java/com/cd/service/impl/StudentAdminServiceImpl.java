package com.cd.service.impl;

import com.cd.dto.StudentManageUpdateRequest;
import com.cd.dto.StudentProfileMaskedResponse;
import com.cd.mapper.StudentAdminMapper;
import com.cd.security.SecurityUtils;
import com.cd.service.RuleChangeLogService;
import com.cd.service.StudentAdminService;
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

    private String emptyToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }

    private String currentOperatorName() {
        var currentUser = SecurityUtils.currentUser();
        return currentUser == null ? "system" : currentUser.getUsername();
    }
}
