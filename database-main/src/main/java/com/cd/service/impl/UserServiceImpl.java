package com.cd.service.impl;

import com.cd.dto.PageResponse;
import com.cd.dto.RoleOptionResponse;
import com.cd.dto.UserCreateRequest;
import com.cd.dto.UserResponse;
import com.cd.dto.UserUpdateRequest;
import com.cd.entity.UserEntity;
import com.cd.mapper.RoleMapper;
import com.cd.mapper.UserMapper;
import com.cd.service.UserService;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class UserServiceImpl implements UserService {

    private static final int DEFAULT_PAGE = 1;
    private static final int DEFAULT_SIZE = 10;
    private static final int MAX_SIZE = 50;

    private final UserMapper userMapper;
    private final RoleMapper roleMapper;
    private final PasswordEncoder passwordEncoder;

    public UserServiceImpl(UserMapper userMapper,
                           RoleMapper roleMapper,
                           PasswordEncoder passwordEncoder) {
        this.userMapper = userMapper;
        this.roleMapper = roleMapper;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public PageResponse<UserResponse> findPage(String userName, Integer page, Integer size) {
        int pageNo = normalizePage(page);
        int pageSize = normalizeSize(size);
        int offset = (pageNo - 1) * pageSize;

        long total = userMapper.countByUserName(userName);
        List<UserResponse> records = userMapper.selectPage(userName, offset, pageSize);
        records.forEach(this::fillRoles);

        PageResponse<UserResponse> response = new PageResponse<>();
        response.setRecords(records);
        response.setTotal(total);
        response.setPage(pageNo);
        response.setSize(pageSize);
        response.setTotalPages(total == 0 ? 0L : (total + pageSize - 1) / pageSize);
        return response;
    }

    @Override
    public Optional<UserResponse> findById(Long id) {
        UserResponse user = userMapper.selectViewById(id);
        if (user == null) {
            return Optional.empty();
        }
        fillRoles(user);
        return Optional.of(user);
    }

    @Override
    public UserResponse create(UserCreateRequest request) {
        validateRoleIds(request.getRoleIds());
        UserEntity entity = new UserEntity();
        entity.setUserName(request.getUserName());
        entity.setUserPwd(passwordEncoder.encode(request.getUserPwd()));
        entity.setUserHeader(emptyToNull(request.getUserHeader()));
        entity.setUserPhonenum(emptyToNull(request.getUserPhonenum()));
        entity.setUserEmail(emptyToNull(request.getUserEmail()));
        entity.setEnabled(true);
        entity.setSuperAdmin(false);
        userMapper.insert(entity);
        bindRoles(entity.getId(), request.getRoleIds());
        return findById(entity.getId()).orElseThrow();
    }

    @Override
    public Optional<UserResponse> update(Long id, UserUpdateRequest request) {
        validateRoleIds(request.getRoleIds());
        UserEntity existing = userMapper.selectEntityById(id);
        if (existing == null) {
            return Optional.empty();
        }

        existing.setUserName(request.getUserName());
        existing.setUserHeader(emptyToNull(request.getUserHeader()));
        existing.setUserPhonenum(emptyToNull(request.getUserPhonenum()));
        existing.setUserEmail(emptyToNull(request.getUserEmail()));
        if (StringUtils.hasText(request.getUserPwd())) {
            existing.setUserPwd(passwordEncoder.encode(request.getUserPwd()));
        }
        userMapper.updateById(existing);
        bindRoles(id, request.getRoleIds());
        return findById(id);
    }

    @Override
    public boolean delete(Long id) {
        UserEntity existing = userMapper.selectEntityById(id);
        if (existing == null) {
            return false;
        }
        if (Boolean.TRUE.equals(existing.getSuperAdmin())) {
            throw new IllegalArgumentException("超级管理员账号不允许删除");
        }
        return userMapper.deleteById(id) > 0;
    }

    private void fillRoles(UserResponse user) {
        List<RoleOptionResponse> roles = roleMapper.selectRolesByUserId(user.getId());
        user.setRoles(roles);
        user.setRoleIds(roles.stream().map(RoleOptionResponse::getId).toList());
    }

    private void bindRoles(Long userId, List<Long> roleIds) {
        List<Long> normalizedRoleIds = normalizeIds(roleIds);
        userMapper.deleteUserRolesByUserId(userId);
        if (!normalizedRoleIds.isEmpty()) {
            userMapper.insertUserRoles(userId, normalizedRoleIds);
        }
    }

    private void validateRoleIds(List<Long> roleIds) {
        Set<Long> requestedIds = new LinkedHashSet<>(normalizeIds(roleIds));
        if (requestedIds.isEmpty()) {
            return;
        }

        Set<Long> existingIds = roleMapper.selectOptions().stream()
                .map(RoleOptionResponse::getId)
                .collect(LinkedHashSet::new, Set::add, Set::addAll);
        if (!existingIds.containsAll(requestedIds)) {
            throw new IllegalArgumentException("存在无效的角色选择");
        }
    }

    private List<Long> normalizeIds(List<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return List.of();
        }
        return new ArrayList<>(new LinkedHashSet<>(ids.stream().filter(id -> id != null && id > 0).toList()));
    }

    private String emptyToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }

    private int normalizePage(Integer page) {
        if (page == null || page < DEFAULT_PAGE) {
            return DEFAULT_PAGE;
        }
        return page;
    }

    private int normalizeSize(Integer size) {
        if (size == null || size < 1) {
            return DEFAULT_SIZE;
        }
        return Math.min(size, MAX_SIZE);
    }
}
