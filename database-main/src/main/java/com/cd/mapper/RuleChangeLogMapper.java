package com.cd.mapper;

import com.cd.dto.RuleChangeLogResponse;
import com.cd.entity.RuleChangeLogEntity;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface RuleChangeLogMapper {

    int insert(RuleChangeLogEntity entity);

    long countRuleChanges(@Param("operatorName") String operatorName);

    List<RuleChangeLogResponse> selectRuleChangesPage(@Param("operatorName") String operatorName,
                                                      @Param("offset") int offset,
                                                      @Param("size") int size);
}
