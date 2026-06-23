package com.cd.service;

import com.cd.dto.AbnormalAccessResponse;
import com.cd.dto.PageResponse;

public interface AbnormalAccessService {

    PageResponse<AbnormalAccessResponse> findPage(String userName, String ruleName, String severity, Integer page, Integer size);

    void detect(Long operatorUserId);
}
