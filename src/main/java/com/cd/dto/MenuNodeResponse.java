package com.cd.dto;

import java.util.ArrayList;
import java.util.List;

public class MenuNodeResponse {

    private Long id;
    private String permissionCode;
    private String permissionName;
    private String menuKey;
    private String routePath;
    private String icon;
    private Integer sortNum;
    private List<MenuNodeResponse> children = new ArrayList<>();

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getPermissionCode() {
        return permissionCode;
    }

    public void setPermissionCode(String permissionCode) {
        this.permissionCode = permissionCode;
    }

    public String getPermissionName() {
        return permissionName;
    }

    public void setPermissionName(String permissionName) {
        this.permissionName = permissionName;
    }

    public String getMenuKey() {
        return menuKey;
    }

    public void setMenuKey(String menuKey) {
        this.menuKey = menuKey;
    }

    public String getRoutePath() {
        return routePath;
    }

    public void setRoutePath(String routePath) {
        this.routePath = routePath;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public Integer getSortNum() {
        return sortNum;
    }

    public void setSortNum(Integer sortNum) {
        this.sortNum = sortNum;
    }

    public List<MenuNodeResponse> getChildren() {
        return children;
    }

    public void setChildren(List<MenuNodeResponse> children) {
        this.children = children;
    }
}
