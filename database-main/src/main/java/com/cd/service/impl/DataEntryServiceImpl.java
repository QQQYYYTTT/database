package com.cd.service.impl;

import com.cd.dto.DataEntryOptionsResponse;
import com.cd.mapper.RoleMapper;
import com.cd.mapper.StudentAdminMapper;
import com.cd.service.DataEntryService;
import org.springframework.stereotype.Service;

@Service
public class DataEntryServiceImpl implements DataEntryService {

    private final RoleMapper roleMapper;
    private final StudentAdminMapper studentAdminMapper;

    public DataEntryServiceImpl(RoleMapper roleMapper,
                                StudentAdminMapper studentAdminMapper) {
        this.roleMapper = roleMapper;
        this.studentAdminMapper = studentAdminMapper;
    }

    @Override
    public DataEntryOptionsResponse loadOptions() {
        DataEntryOptionsResponse response = new DataEntryOptionsResponse();
        response.setRoles(roleMapper.selectOptions());
        response.setClasses(studentAdminMapper.selectClassOptions());
        response.setCourses(studentAdminMapper.selectCourseOptions());
        response.setSemesters(studentAdminMapper.selectSemesterOptions());
        return response;
    }
}
