package com.cd.controller;

import com.cd.common.Result;
import com.cd.dto.PageResponse;
import com.cd.dto.UserCreateRequest;
import com.cd.dto.UserResponse;
import com.cd.dto.UserUpdateRequest;
import com.cd.service.UserService;
import jakarta.validation.Valid;
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
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    @PreAuthorize("hasAuthority('sys:user:view')")
    public ResponseEntity<Result<PageResponse<UserResponse>>> findPage(
            @RequestParam(required = false) String userName,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        return ResponseEntity.ok(Result.success(userService.findPage(userName, page, size)));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('sys:user:view')")
    public ResponseEntity<Result<UserResponse>> findById(@PathVariable Long id) {
        Optional<UserResponse> user = userService.findById(id);
        if (user.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Result.error(404, "用户不存在"));
        }
        return ResponseEntity.ok(Result.success(user.get()));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('sys:user:create')")
    public ResponseEntity<Result<UserResponse>> create(@Valid @RequestBody UserCreateRequest request) {
        UserResponse created = userService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(Result.success("用户创建成功", created));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('sys:user:update')")
    public ResponseEntity<Result<UserResponse>> update(@PathVariable Long id,
                                                       @Valid @RequestBody UserUpdateRequest request) {
        Optional<UserResponse> updated = userService.update(id, request);
        if (updated.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Result.error(404, "用户不存在"));
        }
        return ResponseEntity.ok(Result.success("用户更新成功", updated.get()));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('sys:user:delete')")
    public ResponseEntity<Result<Void>> delete(@PathVariable Long id) {
        if (!userService.delete(id)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Result.error(404, "用户不存在"));
        }
        return ResponseEntity.ok(Result.success("用户删除成功", null));
    }
}
