package com.cd.mapper;

import com.cd.dto.LoginLogResponse;
import com.cd.entity.LoginLogEntity;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface LoginLogMapper {

    int insert(LoginLogEntity entity);

    long countByUserName(@Param("userName") String userName);

    List<LoginLogResponse> selectPage(@Param("userName") String userName,
                                      @Param("offset") int offset,
                                      @Param("size") int size);
}
