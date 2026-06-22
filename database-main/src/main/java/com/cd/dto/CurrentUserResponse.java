package com.cd.dto;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class CurrentUserResponse {

    private Long id;
    private String userName;
    private String userHeader;
    private String userPhonenum;
    private String userEmail;
    private Boolean superAdmin;
    private LocalDateTime createAt;
    private LocalDateTime updatedAt;
    private LocalDateTime lastLoginTime;
    private StudentSelfProfileResponse studentProfile;
    private List<RoleOptionResponse> roles = new ArrayList<>();
    private List<String> permissionCodes = new ArrayList<>();
    private List<MenuNodeResponse> menuTree = new ArrayList<>();

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserHeader() {
        return userHeader;
    }

    public void setUserHeader(String userHeader) {
        this.userHeader = userHeader;
    }

    public String getUserPhonenum() {
        return userPhonenum;
    }

    public void setUserPhonenum(String userPhonenum) {
        this.userPhonenum = userPhonenum;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public Boolean getSuperAdmin() {
        return superAdmin;
    }

    public void setSuperAdmin(Boolean superAdmin) {
        this.superAdmin = superAdmin;
    }

    public LocalDateTime getCreateAt() {
        return createAt;
    }

    public void setCreateAt(LocalDateTime createAt) {
        this.createAt = createAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public LocalDateTime getLastLoginTime() {
        return lastLoginTime;
    }

    public void setLastLoginTime(LocalDateTime lastLoginTime) {
        this.lastLoginTime = lastLoginTime;
    }

    public StudentSelfProfileResponse getStudentProfile() {
        return studentProfile;
    }

    public void setStudentProfile(StudentSelfProfileResponse studentProfile) {
        this.studentProfile = studentProfile;
    }

    public List<RoleOptionResponse> getRoles() {
        return roles;
    }

    public void setRoles(List<RoleOptionResponse> roles) {
        this.roles = roles;
    }

    public List<String> getPermissionCodes() {
        return permissionCodes;
    }

    public void setPermissionCodes(List<String> permissionCodes) {
        this.permissionCodes = permissionCodes;
    }

    public List<MenuNodeResponse> getMenuTree() {
        return menuTree;
    }

    public void setMenuTree(List<MenuNodeResponse> menuTree) {
        this.menuTree = menuTree;
    }
}
