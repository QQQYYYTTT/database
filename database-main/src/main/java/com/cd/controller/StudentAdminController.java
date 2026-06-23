package com.cd.controller;

import com.cd.common.Result;
import com.cd.dto.StudentCreateRequest;
import com.cd.dto.StudentManageUpdateRequest;
import com.cd.dto.StudentScoreCreateRequest;
import com.cd.service.StudentAdminService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/students")
public class StudentAdminController {

    private final StudentAdminService studentAdminService;

    public StudentAdminController(StudentAdminService studentAdminService) {
        this.studentAdminService = studentAdminService;
    }

    @PostMapping
    @PreAuthorize("hasAuthority('sys:user:create')")
    public ResponseEntity<Result<Void>> createStudent(@Valid @RequestBody StudentCreateRequest request) {
        studentAdminService.createStudent(request);
        return ResponseEntity.ok(Result.success("学生信息新增成功", null));
    }

    @PutMapping("/{studentId}")
    @PreAuthorize("hasAuthority('sys:user:update')")
    public ResponseEntity<Result<Void>> updateStudent(@PathVariable Long studentId,
                                                      @Valid @RequestBody StudentManageUpdateRequest request) {
        studentAdminService.updateStudent(studentId, request);
        return ResponseEntity.ok(Result.success("学生信息更新成功", null));
    }

    @DeleteMapping("/{studentId}")
    @PreAuthorize("hasAuthority('sys:user:delete')")
    public ResponseEntity<Result<Void>> deleteStudent(@PathVariable Long studentId) {
        studentAdminService.deleteStudent(studentId);
        return ResponseEntity.ok(Result.success("学生信息删除成功", null));
    }

    @PostMapping("/scores")
    @PreAuthorize("hasAuthority('sys:user:create')")
    public ResponseEntity<Result<Void>> saveStudentScore(@Valid @RequestBody StudentScoreCreateRequest request) {
        studentAdminService.saveStudentScore(request);
        return ResponseEntity.ok(Result.success("学生成绩保存成功", null));
    }
}
