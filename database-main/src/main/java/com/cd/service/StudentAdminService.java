package com.cd.service;

import com.cd.dto.StudentManageUpdateRequest;

public interface StudentAdminService {

    void updateStudent(Long studentId, StudentManageUpdateRequest request);

    void deleteStudent(Long studentId);
}
