package com.cd.mapper;

import com.cd.entity.TestEntity;
import java.util.List;

public interface TestMapper {

    List<TestEntity> selectAll();

    TestEntity selectById(Long id);

    int insert(TestEntity entity);

    int updateById(TestEntity entity);

    int deleteById(Long id);
}
