package com.cd.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class TestRequest {

    @NotBlank(message = "name cannot be blank")
    @Size(max = 100, message = "name length must be less than or equal to 100")
    private String name;

    @Min(value = 0, message = "age must be greater than or equal to 0")
    @Max(value = 150, message = "age must be less than or equal to 150")
    private Integer age;

    @Email(message = "email format is invalid")
    @Size(max = 100, message = "email length must be less than or equal to 100")
    private String email;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
