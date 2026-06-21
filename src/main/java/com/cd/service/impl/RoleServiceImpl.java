package com.cd.service.impl;

import com.cd.dto.RoleCreateRequest;
import com.cd.dto.RoleOptionResponse;
import com.cd.dto.RoleResponse;
import com.cd.dto.RoleUpdateRequest;
import com.cd.entity.RoleEntity;
import com.cd.mapper.PermissionMapper;
import com.cd.mapper.RoleMapper;
import com.cd.service.RoleService;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class RoleServiceImpl implements RoleService {

    private final RoleMapper roleMapper;
    private final PermissionMapper permissionMapper;

    public RoleServiceImpl(RoleMapper roleMapper, PermissionMapper permissionMapper) {
        this.roleMapper = roleMapper;
        this.permissionMapper = permissionMapper;
    }

    @Override
    public List<RoleResponse> findAll(String roleName) {
        List<RoleResponse> responses = new ArrayList<>();
        for (RoleEntity entity : roleMapper.selectAll(roleName)) {
            responses.add(toResponse(entity));
        }
        return responses;
    }

    @Override
    public List<RoleOptionResponse> findOptions() {
        return roleMapper.selectOptions();
    }

    @Override
    public Optional<RoleResponse> findById(Long id) {
        RoleEntity entity = roleMapper.selectById(id);
        return entity == null ? Optional.empty() : Optional.of(toResponse(entity));
    }

    @Override
    public RoleResponse create(RoleCreateRequest request) {
        validatePermissionIds(request.getPermissionIds());
        RoleEntity entity = new RoleEntity();
        entity.setRoleCode(normalizeRoleCode(request.getRoleCode()));
        entity.setRoleName(request.getRoleName());
        entity.setRoleDescription(emptyToNull(request.getRoleDescription()));
        entity.setSortNum(request.getSortNum() == null ? 0 : request.getSortNum());
        entity.setEnabled(request.getEnabled() == null || request.getEnabled());
        roleMapper.insert(entity);
        bindPermissions(entity.getId(), request.getPermissionIds());
        return findById(entity.getId()).orElseThrow();
    }

    @Override
    public Optional<RoleResponse> update(Long id, RoleUpdateRequest request) {
        validatePermissionIds(request.getPermissionIds());
        RoleEntity entity = roleMapper.selectById(id);
        if (entity == null) {
            return Optional.empty();
        }

        entity.setRoleCode(normalizeRoleCode(request.getRoleCode()));
        entity.setRoleName(request.getRoleName());
        entity.setRoleDescription(emptyToNull(request.getRoleDescription()));
        entity.setSortNum(request.getSortNum() == null ? 0 : request.getSortNum());
        entity.setEnabled(request.getEnabled() == null || request.getEnabled());
        roleMapper.updateById(entity);
        bindPermissions(id, request.getPermissionIds());
        return findById(id);
    }

    @Override
    public boolean delete(Long id) {
        RoleEntity entity = roleMapper.selectById(id);
        if (entity == null) {
            return false;
        }
        if ("ADMIN".equalsIgnoreCase(entity.getRoleCode())) {
            throw new IllegalArgumentException("内置 ADMIN 角色不允许删除");
        }
        return roleMapper.deleteById(id) > 0;
    }

    private RoleResponse toResponse(RoleEntity entity) {
        RoleResponse response = new RoleResponse();
        response.setId(entity.getId());
        response.setRoleCode(entity.getRoleCode());
        response.setRoleName(entity.getRoleName());
        response.setRoleDescription(entity.getRoleDescription());
        response.setSortNum(entity.getSortNum());
        response.setEnabled(entity.getEnabled());
        response.setCreateAt(entity.getCreateAt());
        response.setUpdatedAt(entity.getUpdatedAt());
        response.setPermissionIds(roleMapper.selectPermissionIdsByRoleId(entity.getId()));
        return response;
    }

    private void bindPermissions(Long roleId, List<Long> permissionIds) {
        List<Long> normalizedIds = normalizeIds(permissionIds);
        roleMapper.deleteRolePermissionsByRoleId(roleId);
        if (!normalizedIds.isEmpty()) {
            roleMapper.insertRolePermissions(roleId, normalizedIds);
        }
    }

    private void validatePermissionIds(List<Long> permissionIds) {
        Set<Long> requestedIds = new LinkedHashSet<>(normalizeIds(permissionIds));
        if (requestedIds.isEmpty()) {
            return;
        }
        Set<Long> existingIds = permissionMapper.selectAll().stream()
                .map(permission -> permission.getId())
                .collect(LinkedHashSet::new, Set::add, Set::addAll);
        if (!existingIds.containsAll(requestedIds)) {
            throw new IllegalArgumentException("存在无效的权限选择");
        }
    }

    private List<Long> normalizeIds(List<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return List.of();
        }
        return new ArrayList<>(new LinkedHashSet<>(ids.stream().filter(id -> id != null && id > 0).toList()));
    }

    private String normalizeRoleCode(String roleCode) {
        return roleCode == null ? null : roleCode.trim().toUpperCase(Locale.ROOT);
    }

    private String emptyToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }
}
