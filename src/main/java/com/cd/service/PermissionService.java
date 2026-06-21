package com.cd.service;

import com.cd.dto.PermissionCreateRequest;
import com.cd.dto.PermissionNodeResponse;
import com.cd.dto.PermissionUpdateRequest;
import java.util.List;
import java.util.Optional;

public interface PermissionService {

    List<PermissionNodeResponse> findTree();

    Optional<PermissionNodeResponse> findById(Long id);

    PermissionNodeResponse create(PermissionCreateRequest request);

    Optional<PermissionNodeResponse> update(Long id, PermissionUpdateRequest request);

    boolean delete(Long id);
}
