package com.cd.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public class StudentCreateRequest {

    private Long studentId;

    @NotNull(message = "班级不能为空")
    @Positive(message = "班级不能为空")
    private Long classId;

    @NotBlank(message = "学号不能为空")
    @Size(max = 30, message = "学号长度不能超过 30")
    private String studentNo;

    @NotBlank(message = "姓名不能为空")
    @Size(max = 50, message = "姓名长度不能超过 50")
    private String name;

    @NotBlank(message = "性别不能为空")
    @Pattern(regexp = "^(M|F)$", message = "性别只能为 M 或 F")
    private String gender;

    @Pattern(regexp = "^$|^\\d{4}-\\d{2}-\\d{2}$", message = "出生日期格式应为 yyyy-MM-dd")
    private String birthDate;

    private Integer status;

    @Pattern(regexp = "^$|^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;

    @Email(message = "邮箱格式不正确")
    @Size(max = 100, message = "邮箱长度不能超过 100")
    private String email;

    @Size(max = 30, message = "身份证号长度不能超过 30")
    private String idCard;

    @Size(max = 255, message = "住址长度不能超过 255")
    private String address;

    @DecimalMin(value = "0.00", message = "家庭收入不能为负数")
    private BigDecimal familyIncome;

    @Size(max = 30, message = "银行卡号长度不能超过 30")
    private String bankCard;

    public Long getStudentId() {
        return studentId;
    }

    public void setStudentId(Long studentId) {
        this.studentId = studentId;
    }

    public Long getClassId() {
        return classId;
    }

    public void setClassId(Long classId) {
        this.classId = classId;
    }

    public String getStudentNo() {
        return studentNo;
    }

    public void setStudentNo(String studentNo) {
        this.studentNo = studentNo;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(String birthDate) {
        this.birthDate = birthDate;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getIdCard() {
        return idCard;
    }

    public void setIdCard(String idCard) {
        this.idCard = idCard;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public BigDecimal getFamilyIncome() {
        return familyIncome;
    }

    public void setFamilyIncome(BigDecimal familyIncome) {
        this.familyIncome = familyIncome;
    }

    public String getBankCard() {
        return bankCard;
    }

    public void setBankCard(String bankCard) {
        this.bankCard = bankCard;
    }
}
