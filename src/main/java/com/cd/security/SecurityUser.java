package com.cd.security;

import com.cd.dto.RoleOptionResponse;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

public class SecurityUser implements UserDetails {

    private final Long userId;
    private final String username;
    private final String password;
    private final boolean enabled;
    private final boolean superAdmin;
    private final List<RoleOptionResponse> roles;
    private final List<String> permissionCodes;
    private final List<GrantedAuthority> authorities;

    public SecurityUser(Long userId,
                        String username,
                        String password,
                        boolean enabled,
                        boolean superAdmin,
                        List<RoleOptionResponse> roles,
                        List<String> permissionCodes) {
        this.userId = userId;
        this.username = username;
        this.password = password;
        this.enabled = enabled;
        this.superAdmin = superAdmin;
        this.roles = roles == null ? new ArrayList<>() : roles;
        this.permissionCodes = permissionCodes == null ? new ArrayList<>() : permissionCodes;
        this.authorities = new ArrayList<>();
        for (String permissionCode : this.permissionCodes) {
            this.authorities.add(new SimpleGrantedAuthority(permissionCode));
        }
        for (RoleOptionResponse role : this.roles) {
            this.authorities.add(new SimpleGrantedAuthority("ROLE_" + role.getRoleCode()));
        }
    }

    public Long getUserId() {
        return userId;
    }

    public boolean isSuperAdmin() {
        return superAdmin;
    }

    public List<RoleOptionResponse> getRoles() {
        return roles;
    }

    public List<String> getPermissionCodes() {
        return permissionCodes;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return enabled;
    }
}
