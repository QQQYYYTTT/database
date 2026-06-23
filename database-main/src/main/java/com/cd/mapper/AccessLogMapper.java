package com.cd.mapper;

import com.cd.dto.AccessLogResponse;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface AccessLogMapper {

    long countPage(@Param("userName") String userName,
                   @Param("roleCode") String roleCode,
                   @Param("operationType") String operationType);

    List<AccessLogResponse> selectPage(@Param("userName") String userName,
                                       @Param("roleCode") String roleCode,
                                       @Param("operationType") String operationType,
                                       @Param("offset") int offset,
                                       @Param("size") int size);
}
