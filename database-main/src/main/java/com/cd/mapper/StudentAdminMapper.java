package com.cd.mapper;

import com.cd.dto.ClassOptionResponse;
import com.cd.dto.CourseOptionResponse;
import com.cd.dto.SemesterOptionResponse;
import com.cd.dto.StudentCreateRequest;
import com.cd.dto.StudentManageUpdateRequest;
import com.cd.dto.StudentProfileMaskedResponse;
import com.cd.dto.StudentScoreCreateRequest;
import com.cd.dto.StudentSelfProfileResponse;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface StudentAdminMapper {

    StudentSelfProfileResponse selectCurrentStudentProfile(@Param("userId") Long userId);

    StudentProfileMaskedResponse selectStudentProfileSnapshotById(@Param("studentId") Long studentId);

    Long selectLinkedStudentIdByUserId(@Param("userId") Long userId);

    Long selectStudentIdByStudentNo(@Param("studentNo") String studentNo);

    Long selectClassIdByClassCode(@Param("classCode") String classCode);

    Long selectCourseIdByCourseCode(@Param("courseCode") String courseCode);

    Long selectSemesterIdBySemesterName(@Param("semesterName") String semesterName);

    Long selectScoreId(@Param("studentId") Long studentId,
                       @Param("courseId") Long courseId,
                       @Param("semesterId") Long semesterId);

    Integer countClassById(@Param("classId") Long classId);

    Integer countCourseById(@Param("courseId") Long courseId);

    Integer countSemesterById(@Param("semesterId") Long semesterId);

    List<ClassOptionResponse> selectClassOptions();

    List<CourseOptionResponse> selectCourseOptions();

    List<SemesterOptionResponse> selectSemesterOptions();

    int insertStudent(@Param("request") StudentCreateRequest request);

    int insertStudentSensitive(@Param("studentId") Long studentId,
                               @Param("request") StudentCreateRequest request);

    int updateStudentBasicById(@Param("studentId") Long studentId,
                               @Param("request") StudentManageUpdateRequest request);

    int upsertStudentSensitive(@Param("studentId") Long studentId,
                               @Param("phone") String phone,
                               @Param("email") String email,
                               @Param("address") String address);

    int deleteStudentSensitiveByStudentId(@Param("studentId") Long studentId);

    int deleteStudentScoresByStudentId(@Param("studentId") Long studentId);

    int deleteStudentById(@Param("studentId") Long studentId);

    int insertStudentScore(@Param("studentId") Long studentId,
                           @Param("request") StudentScoreCreateRequest request);

    int updateStudentScoreById(@Param("scoreId") Long scoreId,
                               @Param("request") StudentScoreCreateRequest request);
}
