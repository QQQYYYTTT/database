package com.cd.service;

import com.cd.dto.RoleCreateRequest;
import com.cd.dto.RoleOptionResponse;
import com.cd.dto.RoleResponse;
import com.cd.dto.RoleUpdateRequest;
import java.util.List;
import java.util.Optional;

public interface RoleService {

    List<RoleResponse> findAll(String roleName);

    List<RoleOptionResponse> findOptions();

    Optional<RoleResponse> findById(Long id);

    RoleResponse create(RoleCreateRequest request);

    Optional<RoleResponse> update(Long id, RoleUpdateRequest request);

    boolean delete(Long id);
}
