package com.cd.service;

import com.cd.dto.StudentProfileMaskedResponse;
import com.cd.dto.StudentScoreMaskedResponse;
import com.cd.security.SecurityUser;
import java.util.List;

public interface StudentMaskingService {

    List<StudentProfileMaskedResponse> queryStudentProfiles(SecurityUser currentUser,
                                                           String studentNo,
                                                           String name,
                                                           String className);

    List<StudentScoreMaskedResponse> queryStudentScores(SecurityUser currentUser,
                                                        String studentNo,
                                                        String courseName,
                                                        String semesterName);
}
