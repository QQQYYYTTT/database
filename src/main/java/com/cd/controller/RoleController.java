package com.cd.controller;

import com.cd.common.Result;
import com.cd.dto.RoleCreateRequest;
import com.cd.dto.RoleOptionResponse;
import com.cd.dto.RoleResponse;
import com.cd.dto.RoleUpdateRequest;
import com.cd.service.RoleService;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/roles")
public class RoleController {

    private final RoleService roleService;

    public RoleController(RoleService roleService) {
        this.roleService = roleService;
    }

    @GetMapping
    @PreAuthorize("hasAuthority('sys:role:view')")
    public ResponseEntity<Result<List<RoleResponse>>> findAll(@RequestParam(required = false) String roleName) {
        return ResponseEntity.ok(Result.success(roleService.findAll(roleName)));
    }

    @GetMapping("/options")
    @PreAuthorize("hasAuthority('sys:role:view')")
    public ResponseEntity<Result<List<RoleOptionResponse>>> findOptions() {
        return ResponseEntity.ok(Result.success(roleService.findOptions()));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('sys:role:view')")
    public ResponseEntity<Result<RoleResponse>> findById(@PathVariable Long id) {
        Optional<RoleResponse> role = roleService.findById(id);
        if (role.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Result.error(404, "角色不存在"));
        }
        return ResponseEntity.ok(Result.success(role.get()));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('sys:role:create')")
    public ResponseEntity<Result<RoleResponse>> create(@Valid @RequestBody RoleCreateRequest request) {
        RoleResponse created = roleService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(Result.success("角色创建成功", created));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('sys:role:update')")
    public ResponseEntity<Result<RoleResponse>> update(@PathVariable Long id,
                                                       @Valid @RequestBody RoleUpdateRequest request) {
        Optional<RoleResponse> updated = roleService.update(id, request);
        if (updated.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Result.error(404, "角色不存在"));
        }
        return ResponseEntity.ok(Result.success("角色更新成功", updated.get()));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('sys:role:delete')")
    public ResponseEntity<Result<Void>> delete(@PathVariable Long id) {
        if (!roleService.delete(id)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Result.error(404, "角色不存在"));
        }
        return ResponseEntity.ok(Result.success("角色删除成功", null));
    }
}
