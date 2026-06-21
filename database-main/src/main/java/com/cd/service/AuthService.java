package com.cd.service;

import com.cd.dto.CurrentUserResponse;
import com.cd.dto.LoginResponse;
import com.cd.dto.PasswordChangeRequest;
import com.cd.dto.ProfileUpdateRequest;
import com.cd.dto.UserLoginRequest;

public interface AuthService {

    LoginResponse login(UserLoginRequest request);

    CurrentUserResponse currentUser(Long userId);

    CurrentUserResponse updateProfile(Long userId, ProfileUpdateRequest request);

    void changePassword(Long userId, PasswordChangeRequest request);
}
