package com.cd.service;

import com.cd.dto.PageResponse;
import com.cd.dto.UserCreateRequest;
import com.cd.dto.UserResponse;
import com.cd.dto.UserUpdateRequest;
import java.util.Optional;

public interface UserService {

    PageResponse<UserResponse> findPage(String userName, Integer page, Integer size);

    Optional<UserResponse> findById(Long id);

    UserResponse create(UserCreateRequest request);

    Optional<UserResponse> update(Long id, UserUpdateRequest request);

    boolean delete(Long id);
}
