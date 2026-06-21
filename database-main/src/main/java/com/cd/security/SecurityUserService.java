package com.cd.security;

import com.cd.dto.CurrentUserResponse;
import com.cd.dto.MenuNodeResponse;
import com.cd.dto.RoleOptionResponse;
import com.cd.dto.UserResponse;
import com.cd.entity.PermissionEntity;
import com.cd.entity.UserEntity;
import com.cd.mapper.PermissionMapper;
import com.cd.mapper.RoleMapper;
import com.cd.mapper.UserMapper;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class SecurityUserService implements UserDetailsService {

    private final UserMapper userMapper;
    private final RoleMapper roleMapper;
    private final PermissionMapper permissionMapper;

    public SecurityUserService(UserMapper userMapper,
                               RoleMapper roleMapper,
                               PermissionMapper permissionMapper) {
        this.userMapper = userMapper;
        this.roleMapper = roleMapper;
        this.permissionMapper = permissionMapper;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        SecurityUser securityUser = loadSecurityUserByUsername(username);
        if (securityUser == null) {
            throw new UsernameNotFoundException("User not found");
        }
        return securityUser;
    }

    public SecurityUser loadSecurityUserByUsername(String username) {
        UserEntity entity = userMapper.selectEntityByUserName(username);
        return entity == null ? null : buildSecurityUser(entity);
    }

    public SecurityUser loadSecurityUserByUserId(Long userId) {
        UserEntity entity = userMapper.selectEntityById(userId);
        return entity == null ? null : buildSecurityUser(entity);
    }

    public CurrentUserResponse buildCurrentUserResponse(Long userId) {
        UserResponse user = userMapper.selectViewById(userId);
        UserEntity entity = userMapper.selectEntityById(userId);
        if (user == null || entity == null) {
            return null;
        }

        List<RoleOptionResponse> roles = roleMapper.selectRolesByUserId(userId);
        List<PermissionEntity> permissions = Boolean.TRUE.equals(entity.getSuperAdmin())
                ? permissionMapper.selectAll()
                : permissionMapper.selectPermissionsByUserId(userId);

        CurrentUserResponse response = new CurrentUserResponse();
        response.setId(user.getId());
        response.setUserName(user.getUserName());
        response.setUserHeader(user.getUserHeader());
        response.setUserPhonenum(user.getUserPhonenum());
        response.setUserEmail(user.getUserEmail());
        response.setSuperAdmin(Boolean.TRUE.equals(entity.getSuperAdmin()));
        response.setCreateAt(user.getCreateAt());
        response.setUpdatedAt(user.getUpdatedAt());
        response.setLastLoginTime(user.getLastLoginTime());
        response.setRoles(roles);
        response.setPermissionCodes(permissions.stream()
                .map(PermissionEntity::getPermissionCode)
                .filter(Objects::nonNull)
                .distinct()
                .toList());
        response.setMenuTree(buildMenuTree(permissions));
        return response;
    }

    private SecurityUser buildSecurityUser(UserEntity entity) {
        List<RoleOptionResponse> roles = roleMapper.selectRolesByUserId(entity.getId());
        List<PermissionEntity> permissions = Boolean.TRUE.equals(entity.getSuperAdmin())
                ? permissionMapper.selectAll()
                : permissionMapper.selectPermissionsByUserId(entity.getId());

        List<String> permissionCodes = permissions.stream()
                .map(PermissionEntity::getPermissionCode)
                .filter(Objects::nonNull)
                .distinct()
                .toList();

        return new SecurityUser(
                entity.getId(),
                entity.getUserName(),
                entity.getUserPwd(),
                Boolean.TRUE.equals(entity.getEnabled()),
                Boolean.TRUE.equals(entity.getSuperAdmin()),
                roles,
                permissionCodes
        );
    }

    private List<MenuNodeResponse> buildMenuTree(List<PermissionEntity> permissions) {
        List<PermissionEntity> menus = permissions.stream()
                .filter(permission -> "MENU".equalsIgnoreCase(permission.getPermissionType()))
                .filter(permission -> !Boolean.FALSE.equals(permission.getVisible()))
                .sorted(Comparator.comparing(PermissionEntity::getSortNum, Comparator.nullsLast(Integer::compareTo))
                        .thenComparing(PermissionEntity::getId))
                .toList();

        Map<Long, MenuNodeResponse> nodeMap = new LinkedHashMap<>();
        List<MenuNodeResponse> roots = new ArrayList<>();
        for (PermissionEntity permission : menus) {
            MenuNodeResponse node = new MenuNodeResponse();
            node.setId(permission.getId());
            node.setPermissionCode(permission.getPermissionCode());
            node.setPermissionName(permission.getPermissionName());
            node.setMenuKey(permission.getMenuKey());
            node.setRoutePath(permission.getRoutePath());
            node.setIcon(permission.getIcon());
            node.setSortNum(permission.getSortNum());
            nodeMap.put(permission.getId(), node);
        }

        for (PermissionEntity permission : menus) {
            MenuNodeResponse node = nodeMap.get(permission.getId());
            Long parentId = permission.getParentId();
            if (parentId == null || parentId == 0L || !nodeMap.containsKey(parentId)) {
                roots.add(node);
            } else {
                nodeMap.get(parentId).getChildren().add(node);
            }
        }
        return roots;
    }
}
