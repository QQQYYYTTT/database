package com.cd.service;

import com.cd.dto.StudentCreateRequest;
import com.cd.dto.StudentManageUpdateRequest;
import com.cd.dto.StudentScoreCreateRequest;

public interface StudentAdminService {

    void createStudent(StudentCreateRequest request);

    void updateStudent(Long studentId, StudentManageUpdateRequest request);

    void deleteStudent(Long studentId);

    void saveStudentScore(StudentScoreCreateRequest request);
}
