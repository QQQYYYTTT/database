package com.cd.service;

import com.cd.dto.MaskingRuleOptionsResponse;
import com.cd.dto.MaskingRuleUpdateRequest;
import com.cd.dto.MaskingRuleViewResponse;
import com.cd.dto.PageResponse;
import java.util.List;

public interface MaskingRuleService {

    MaskingRuleOptionsResponse findOptions();

    PageResponse<MaskingRuleViewResponse> findRules(Long roleId, Long sensitiveFieldId, Integer page, Integer size);

    void updateRule(MaskingRuleUpdateRequest request);
}
