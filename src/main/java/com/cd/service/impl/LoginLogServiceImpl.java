package com.cd.service.impl;

import com.cd.dto.LoginLogResponse;
import com.cd.dto.PageResponse;
import com.cd.entity.LoginLogEntity;
import com.cd.mapper.LoginLogMapper;
import com.cd.service.LoginLogService;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class LoginLogServiceImpl implements LoginLogService {

    private static final int DEFAULT_PAGE = 1;
    private static final int DEFAULT_SIZE = 10;
    private static final int MAX_SIZE = 50;

    private final LoginLogMapper loginLogMapper;

    public LoginLogServiceImpl(LoginLogMapper loginLogMapper) {
        this.loginLogMapper = loginLogMapper;
    }

    @Override
    public void record(String userName, String loginStatus, String loginIp, String loginMessage) {
        LoginLogEntity entity = new LoginLogEntity();
        entity.setUserName(StringUtils.hasText(userName) ? userName : "unknown");
        entity.setLoginStatus(loginStatus);
        entity.setLoginIp(loginIp);
        entity.setLoginMessage(loginMessage);
        entity.setLoginTime(LocalDateTime.now());
        loginLogMapper.insert(entity);
    }

    @Override
    public PageResponse<LoginLogResponse> findPage(String userName, Integer page, Integer size) {
        int pageNo = normalizePage(page);
        int pageSize = normalizeSize(size);
        int offset = (pageNo - 1) * pageSize;

        long total = loginLogMapper.countByUserName(userName);
        List<LoginLogResponse> records = loginLogMapper.selectPage(userName, offset, pageSize);

        PageResponse<LoginLogResponse> response = new PageResponse<>();
        response.setRecords(records);
        response.setTotal(total);
        response.setPage(pageNo);
        response.setSize(pageSize);
        response.setTotalPages(total == 0 ? 0L : (total + pageSize - 1) / pageSize);
        return response;
    }

    private int normalizePage(Integer page) {
        if (page == null || page < DEFAULT_PAGE) {
            return DEFAULT_PAGE;
        }
        return page;
    }

    private int normalizeSize(Integer size) {
        if (size == null || size < 1) {
            return DEFAULT_SIZE;
        }
        return Math.min(size, MAX_SIZE);
    }
}
