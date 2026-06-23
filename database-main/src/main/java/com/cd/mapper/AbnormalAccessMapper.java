package com.cd.mapper;

import com.cd.dto.AbnormalAccessResponse;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface AbnormalAccessMapper {

    long countPage(@Param("userName") String userName,
                   @Param("ruleName") String ruleName,
                   @Param("severity") String severity);

    List<AbnormalAccessResponse> selectPage(@Param("userName") String userName,
                                            @Param("ruleName") String ruleName,
                                            @Param("severity") String severity,
                                            @Param("offset") int offset,
                                            @Param("size") int size);
}
