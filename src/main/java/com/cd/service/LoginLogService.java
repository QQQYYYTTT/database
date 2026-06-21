package com.cd.service;

import com.cd.dto.LoginLogResponse;
import com.cd.dto.PageResponse;

public interface LoginLogService {

    void record(String userName, String loginStatus, String loginIp, String loginMessage);

    PageResponse<LoginLogResponse> findPage(String userName, Integer page, Integer size);
}
