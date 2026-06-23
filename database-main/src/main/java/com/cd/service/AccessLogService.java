package com.cd.service;

import com.cd.dto.AccessLogResponse;
import com.cd.dto.PageResponse;

public interface AccessLogService {

    PageResponse<AccessLogResponse> findPage(String userName, String roleCode, String operationType, Integer page, Integer size);
}
