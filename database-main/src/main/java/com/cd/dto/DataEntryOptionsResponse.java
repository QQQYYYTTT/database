package com.cd.dto;

import java.util.ArrayList;
import java.util.List;

public class DataEntryOptionsResponse {

    private List<RoleOptionResponse> roles = new ArrayList<>();
    private List<ClassOptionResponse> classes = new ArrayList<>();
    private List<CourseOptionResponse> courses = new ArrayList<>();
    private List<SemesterOptionResponse> semesters = new ArrayList<>();

    public List<RoleOptionResponse> getRoles() {
        return roles;
    }

    public void setRoles(List<RoleOptionResponse> roles) {
        this.roles = roles;
    }

    public List<ClassOptionResponse> getClasses() {
        return classes;
    }

    public void setClasses(List<ClassOptionResponse> classes) {
        this.classes = classes;
    }

    public List<CourseOptionResponse> getCourses() {
        return courses;
    }

    public void setCourses(List<CourseOptionResponse> courses) {
        this.courses = courses;
    }

    public List<SemesterOptionResponse> getSemesters() {
        return semesters;
    }

    public void setSemesters(List<SemesterOptionResponse> semesters) {
        this.semesters = semesters;
    }
}
