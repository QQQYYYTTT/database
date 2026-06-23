package com.cd.service.impl;

import com.cd.dto.AbnormalAccessResponse;
import com.cd.dto.PageResponse;
import com.cd.exception.DatabaseRoutineException;
import com.cd.mapper.AbnormalAccessMapper;
import com.cd.service.AbnormalAccessService;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;
import javax.sql.DataSource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class AbnormalAccessServiceImpl implements AbnormalAccessService {

    private static final int DEFAULT_PAGE = 1;
    private static final int DEFAULT_SIZE = 10;
    private static final int MAX_SIZE = 50;

    private final AbnormalAccessMapper abnormalAccessMapper;
    private final DataSource dataSource;

    public AbnormalAccessServiceImpl(AbnormalAccessMapper abnormalAccessMapper, DataSource dataSource) {
        this.abnormalAccessMapper = abnormalAccessMapper;
        this.dataSource = dataSource;
    }

    @Override
    public PageResponse<AbnormalAccessResponse> findPage(String userName,
                                                         String ruleName,
                                                         String severity,
                                                         Integer page,
                                                         Integer size) {
        int pageNo = normalizePage(page);
        int pageSize = normalizeSize(size);
        int offset = (pageNo - 1) * pageSize;

        long total = abnormalAccessMapper.countPage(userName, ruleName, severity);
        List<AbnormalAccessResponse> records = abnormalAccessMapper.selectPage(userName, ruleName, severity, offset, pageSize);

        PageResponse<AbnormalAccessResponse> response = new PageResponse<>();
        response.setRecords(records);
        response.setTotal(total);
        response.setPage(pageNo);
        response.setSize(pageSize);
        response.setTotalPages(total == 0 ? 0L : (total + pageSize - 1) / pageSize);
        return response;
    }

    @Override
    public void detect(Long operatorUserId) {
        String sql = "{CALL SP_DETECT_ABNORMAL(?)}";
        try (Connection connection = dataSource.getConnection();
             CallableStatement statement = connection.prepareCall(sql)) {
            if (operatorUserId == null) {
                statement.setNull(1, Types.BIGINT);
            } else {
                statement.setLong(1, operatorUserId);
            }
            statement.execute();
        } catch (SQLException ex) {
            throw translateSqlException("Failed to detect abnormal access", ex);
        }
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

    private DatabaseRoutineException translateSqlException(String fallbackMessage, SQLException ex) {
        String sqlState = ex.getSQLState();
        String message = ex.getMessage() == null || ex.getMessage().isBlank() ? fallbackMessage : ex.getMessage();
        int statusCode = "45000".equals(sqlState)
                ? HttpStatus.BAD_REQUEST.value()
                : HttpStatus.INTERNAL_SERVER_ERROR.value();
        return new DatabaseRoutineException(statusCode, sqlState, message, ex);
    }
}
