package com.cd.mapper;

import com.cd.dto.MaskingPolicyOptionResponse;
import com.cd.dto.MaskingRuleFieldOptionResponse;
import com.cd.dto.MaskingRuleViewResponse;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface MaskingRuleMapper {

    List<MaskingRuleViewResponse> selectMaskingRules(@Param("roleId") Long roleId,
                                                    @Param("sensitiveFieldId") Long sensitiveFieldId);

    Long countMaskingRules(@Param("roleId") Long roleId,
                           @Param("sensitiveFieldId") Long sensitiveFieldId);

    List<MaskingRuleViewResponse> selectMaskingRulesPage(@Param("roleId") Long roleId,
                                                         @Param("sensitiveFieldId") Long sensitiveFieldId,
                                                         @Param("offset") int offset,
                                                         @Param("size") int size);

    List<MaskingPolicyOptionResponse> selectPolicyOptions();

    List<MaskingRuleFieldOptionResponse> selectFieldOptions();

    Integer countEnabledSensitiveFieldById(@Param("sensitiveFieldId") Long sensitiveFieldId);

    Long selectSensitiveFieldIdByPolicyId(@Param("policyId") Long policyId);

    Long selectAssignmentIdByRoleAndPolicy(@Param("roleId") Long roleId, @Param("policyId") Long policyId);

    int disableAssignmentsByRoleAndField(@Param("roleId") Long roleId, @Param("sensitiveFieldId") Long sensitiveFieldId);

    int updateAssignmentEnabled(@Param("id") Long id, @Param("enabled") boolean enabled);

    int insertAssignment(@Param("roleId") Long roleId, @Param("policyId") Long policyId, @Param("enabled") boolean enabled);
}
