package com.cd.controller;

import com.cd.common.Result;
import com.cd.dto.PermissionCreateRequest;
import com.cd.dto.PermissionNodeResponse;
import com.cd.dto.PermissionUpdateRequest;
import com.cd.service.PermissionService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Optional;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/permissions")
public class PermissionController {

    private final PermissionService permissionService;

    public PermissionController(PermissionService permissionService) {
        this.permissionService = permissionService;
    }

    @GetMapping("/tree")
    @PreAuthorize("hasAuthority('sys:permission:view')")
    public ResponseEntity<Result<List<PermissionNodeResponse>>> findTree() {
        return ResponseEntity.ok(Result.success(permissionService.findTree()));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('sys:permission:view')")
    public ResponseEntity<Result<PermissionNodeResponse>> findById(@PathVariable Long id) {
        Optional<PermissionNodeResponse> permission = permissionService.findById(id);
        if (permission.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Result.error(404, "权限不存在"));
        }
        return ResponseEntity.ok(Result.success(permission.get()));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('sys:permission:create')")
    public ResponseEntity<Result<PermissionNodeResponse>> create(@Valid @RequestBody PermissionCreateRequest request) {
        PermissionNodeResponse created = permissionService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(Result.success("权限创建成功", created));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('sys:permission:update')")
    public ResponseEntity<Result<PermissionNodeResponse>> update(@PathVariable Long id,
                                                                 @Valid @RequestBody PermissionUpdateRequest request) {
        Optional<PermissionNodeResponse> updated = permissionService.update(id, request);
        if (updated.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Result.error(404, "权限不存在"));
        }
        return ResponseEntity.ok(Result.success("权限更新成功", updated.get()));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('sys:permission:delete')")
    public ResponseEntity<Result<Void>> delete(@PathVariable Long id) {
        if (!permissionService.delete(id)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Result.error(404, "权限不存在"));
        }
        return ResponseEntity.ok(Result.success("权限删除成功", null));
    }
}
