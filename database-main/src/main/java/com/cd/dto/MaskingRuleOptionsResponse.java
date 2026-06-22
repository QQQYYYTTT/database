package com.cd.dto;

import java.util.ArrayList;
import java.util.List;

public class MaskingRuleOptionsResponse {

    private List<RoleOptionResponse> roles = new ArrayList<>();
    private List<MaskingRuleFieldOptionResponse> fields = new ArrayList<>();

    public List<RoleOptionResponse> getRoles() {
        return roles;
    }

    public void setRoles(List<RoleOptionResponse> roles) {
        this.roles = roles;
    }

    public List<MaskingRuleFieldOptionResponse> getFields() {
        return fields;
    }

    public void setFields(List<MaskingRuleFieldOptionResponse> fields) {
        this.fields = fields;
    }
}
