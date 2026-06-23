package com.cd.service.impl;

import com.cd.dto.AccessLogResponse;
import com.cd.dto.PageResponse;
import com.cd.mapper.AccessLogMapper;
import com.cd.service.AccessLogService;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class AccessLogServiceImpl implements AccessLogService {

    private static final int DEFAULT_PAGE = 1;
    private static final int DEFAULT_SIZE = 10;
    private static final int MAX_SIZE = 50;

    private final AccessLogMapper accessLogMapper;

    public AccessLogServiceImpl(AccessLogMapper accessLogMapper) {
        this.accessLogMapper = accessLogMapper;
    }

    @Override
    public PageResponse<AccessLogResponse> findPage(String userName,
                                                    String roleCode,
                                                    String operationType,
                                                    Integer page,
                                                    Integer size) {
        int pageNo = normalizePage(page);
        int pageSize = normalizeSize(size);
        int offset = (pageNo - 1) * pageSize;

        long total = accessLogMapper.countPage(userName, roleCode, operationType);
        List<AccessLogResponse> records = accessLogMapper.selectPage(userName, roleCode, operationType, offset, pageSize);

        PageResponse<AccessLogResponse> response = new PageResponse<>();
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
