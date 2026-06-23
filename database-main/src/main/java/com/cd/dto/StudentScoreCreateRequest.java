package com.cd.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public class StudentScoreCreateRequest {

    private Long scoreId;

    @NotBlank(message = "学号不能为空")
    @Size(max = 30, message = "学号长度不能超过 30")
    private String studentNo;

    @NotNull(message = "课程不能为空")
    @Positive(message = "课程不能为空")
    private Long courseId;

    @NotNull(message = "学期不能为空")
    @Positive(message = "学期不能为空")
    private Long semesterId;

    @NotNull(message = "成绩不能为空")
    @DecimalMin(value = "0.00", message = "成绩不能小于 0")
    @DecimalMax(value = "100.00", message = "成绩不能大于 100")
    private BigDecimal score;

    public Long getScoreId() {
        return scoreId;
    }

    public void setScoreId(Long scoreId) {
        this.scoreId = scoreId;
    }

    public String getStudentNo() {
        return studentNo;
    }

    public void setStudentNo(String studentNo) {
        this.studentNo = studentNo;
    }

    public Long getCourseId() {
        return courseId;
    }

    public void setCourseId(Long courseId) {
        this.courseId = courseId;
    }

    public Long getSemesterId() {
        return semesterId;
    }

    public void setSemesterId(Long semesterId) {
        this.semesterId = semesterId;
    }

    public BigDecimal getScore() {
        return score;
    }

    public void setScore(BigDecimal score) {
        this.score = score;
    }
}
