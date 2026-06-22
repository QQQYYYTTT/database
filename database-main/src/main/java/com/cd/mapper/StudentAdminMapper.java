package com.cd.mapper;

import com.cd.dto.StudentManageUpdateRequest;
import com.cd.dto.StudentProfileMaskedResponse;
import com.cd.dto.StudentSelfProfileResponse;
import org.apache.ibatis.annotations.Param;

public interface StudentAdminMapper {

    StudentSelfProfileResponse selectCurrentStudentProfile(@Param("userId") Long userId);

    StudentProfileMaskedResponse selectStudentProfileSnapshotById(@Param("studentId") Long studentId);

    Long selectLinkedStudentIdByUserId(@Param("userId") Long userId);

    int updateStudentBasicById(@Param("studentId") Long studentId,
                               @Param("request") StudentManageUpdateRequest request);

    int upsertStudentSensitive(@Param("studentId") Long studentId,
                               @Param("phone") String phone,
                               @Param("email") String email,
                               @Param("address") String address);

    int deleteStudentSensitiveByStudentId(@Param("studentId") Long studentId);

    int deleteStudentScoresByStudentId(@Param("studentId") Long studentId);

    int deleteStudentById(@Param("studentId") Long studentId);
}
