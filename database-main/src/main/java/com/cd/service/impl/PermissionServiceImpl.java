package com.cd.service.impl;

import com.cd.dto.PermissionCreateRequest;
import com.cd.dto.PermissionNodeResponse;
import com.cd.dto.PermissionUpdateRequest;
import com.cd.entity.PermissionEntity;
import com.cd.mapper.PermissionMapper;
import com.cd.service.PermissionService;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class PermissionServiceImpl implements PermissionService {

    private final PermissionMapper permissionMapper;

    public PermissionServiceImpl(PermissionMapper permissionMapper) {
        this.permissionMapper = permissionMapper;
    }

    @Override
    public List<PermissionNodeResponse> findTree() {
        return buildTree(permissionMapper.selectAll());
    }

    @Override
    public Optional<PermissionNodeResponse> findById(Long id) {
        PermissionEntity entity = permissionMapper.selectById(id);
        return entity == null ? Optional.empty() : Optional.of(toNode(entity));
    }

    @Override
    public PermissionNodeResponse create(PermissionCreateRequest request) {
        PermissionEntity entity = new PermissionEntity();
        applyRequest(entity, request);
        permissionMapper.insert(entity);
        return findById(entity.getId()).orElseThrow();
    }

    @Override
    public Optional<PermissionNodeResponse> update(Long id, PermissionUpdateRequest request) {
        PermissionEntity entity = permissionMapper.selectById(id);
        if (entity == null) {
            return Optional.empty();
        }
        applyRequest(entity, request);
        if (id.equals(entity.getParentId())) {
            throw new IllegalArgumentException("权限节点不能将自己设置为父节点");
        }
        permissionMapper.updateById(entity);
        return findById(id);
    }

    @Override
    public boolean delete(Long id) {
        PermissionEntity entity = permissionMapper.selectById(id);
        if (entity == null) {
            return false;
        }
        return permissionMapper.deleteById(id) > 0;
    }

    private void applyRequest(PermissionEntity entity, PermissionCreateRequest request) {
        entity.setPermissionCode(request.getPermissionCode().trim());
        entity.setPermissionName(request.getPermissionName().trim());
        entity.setPermissionType(normalizePermissionType(request.getPermissionType()));
        entity.setParentId(request.getParentId() == null ? 0L : request.getParentId());
        entity.setMenuKey(emptyToNull(request.getMenuKey()));
        entity.setRoutePath(emptyToNull(request.getRoutePath()));
        entity.setComponentPath(emptyToNull(request.getComponentPath()));
        entity.setIcon(emptyToNull(request.getIcon()));
        entity.setApiPattern(emptyToNull(request.getApiPattern()));
        entity.setHttpMethod(emptyToNull(request.getHttpMethod() == null ? null : request.getHttpMethod().toUpperCase(Locale.ROOT)));
        entity.setSortNum(request.getSortNum() == null ? 0 : request.getSortNum());
        entity.setVisible(request.getVisible() == null || request.getVisible());
        entity.setDescription(emptyToNull(request.getDescription()));
    }

    private void applyRequest(PermissionEntity entity, PermissionUpdateRequest request) {
        PermissionCreateRequest createRequest = new PermissionCreateRequest();
        createRequest.setPermissionCode(request.getPermissionCode());
        createRequest.setPermissionName(request.getPermissionName());
        createRequest.setPermissionType(request.getPermissionType());
        createRequest.setParentId(request.getParentId());
        createRequest.setMenuKey(request.getMenuKey());
        createRequest.setRoutePath(request.getRoutePath());
        createRequest.setComponentPath(request.getComponentPath());
        createRequest.setIcon(request.getIcon());
        createRequest.setApiPattern(request.getApiPattern());
        createRequest.setHttpMethod(request.getHttpMethod());
        createRequest.setSortNum(request.getSortNum());
        createRequest.setVisible(request.getVisible());
        createRequest.setDescription(request.getDescription());
        applyRequest(entity, createRequest);
    }

    private String normalizePermissionType(String permissionType) {
        String type = permissionType == null ? "" : permissionType.trim().toUpperCase(Locale.ROOT);
        if (!"MENU".equals(type) && !"API".equals(type)) {
            throw new IllegalArgumentException("权限类型只能是 MENU 或 API");
        }
        return type;
    }

    private String emptyToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }

    private List<PermissionNodeResponse> buildTree(List<PermissionEntity> permissions) {
        List<PermissionEntity> ordered = permissions.stream()
                .sorted(Comparator.comparing(PermissionEntity::getSortNum, Comparator.nullsLast(Integer::compareTo))
                        .thenComparing(PermissionEntity::getId))
                .toList();

        Map<Long, PermissionNodeResponse> nodeMap = new LinkedHashMap<>();
        List<PermissionNodeResponse> roots = new ArrayList<>();
        for (PermissionEntity permission : ordered) {
            nodeMap.put(permission.getId(), toNode(permission));
        }

        for (PermissionEntity permission : ordered) {
            PermissionNodeResponse node = nodeMap.get(permission.getId());
            Long parentId = permission.getParentId();
            if (parentId == null || parentId == 0L || !nodeMap.containsKey(parentId)) {
                roots.add(node);
            } else {
                nodeMap.get(parentId).getChildren().add(node);
            }
        }
        return roots;
    }

    private PermissionNodeResponse toNode(PermissionEntity entity) {
        PermissionNodeResponse node = new PermissionNodeResponse();
        node.setId(entity.getId());
        node.setPermissionCode(entity.getPermissionCode());
        node.setPermissionName(entity.getPermissionName());
        node.setPermissionType(entity.getPermissionType());
        node.setParentId(entity.getParentId());
        node.setMenuKey(entity.getMenuKey());
        node.setRoutePath(entity.getRoutePath());
        node.setComponentPath(entity.getComponentPath());
        node.setIcon(entity.getIcon());
        node.setApiPattern(entity.getApiPattern());
        node.setHttpMethod(entity.getHttpMethod());
        node.setSortNum(entity.getSortNum());
        node.setVisible(entity.getVisible());
        node.setDescription(entity.getDescription());
        node.setCreateAt(entity.getCreateAt());
        node.setUpdatedAt(entity.getUpdatedAt());
        return node;
    }
}
