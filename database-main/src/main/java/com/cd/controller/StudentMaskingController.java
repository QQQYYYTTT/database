package com.cd.controller;

import com.cd.common.Result;
import com.cd.dto.StudentProfileMaskedResponse;
import com.cd.dto.StudentScoreMaskedResponse;
import com.cd.security.SecurityUtils;
import com.cd.service.StudentMaskingService;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class StudentMaskingController {

    private final StudentMaskingService studentMaskingService;

    public StudentMaskingController(StudentMaskingService studentMaskingService) {
        this.studentMaskingService = studentMaskingService;
    }

    @GetMapping("/student-profiles")
    @PreAuthorize("hasAuthority('biz:student:view')")
    public ResponseEntity<Result<List<StudentProfileMaskedResponse>>> queryStudentProfiles(
            @RequestParam(required = false) String studentNo,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String className) {
        List<StudentProfileMaskedResponse> data = studentMaskingService.queryStudentProfiles(
                SecurityUtils.currentUser(), studentNo, name, className);
        return ResponseEntity.ok(Result.success(data));
    }

    @GetMapping("/student-scores")
    @PreAuthorize("hasAuthority('biz:score:view')")
    public ResponseEntity<Result<List<StudentScoreMaskedResponse>>> queryStudentScores(
            @RequestParam(required = false) String studentNo,
            @RequestParam(required = false) String courseName,
            @RequestParam(required = false) String semesterName) {
        List<StudentScoreMaskedResponse> data = studentMaskingService.queryStudentScores(
                SecurityUtils.currentUser(), studentNo, courseName, semesterName);
        return ResponseEntity.ok(Result.success(data));
    }
}
