package com.cd.service.impl;

import com.cd.dto.TestRequest;
import com.cd.entity.TestEntity;
import com.cd.mapper.TestMapper;
import com.cd.service.TestService;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;

@Service
public class TestServiceImpl implements TestService {

    private final TestMapper testMapper;

    public TestServiceImpl(TestMapper testMapper) {
        this.testMapper = testMapper;
    }

    @Override
    public List<TestEntity> findAll() {
        return testMapper.selectAll();
    }

    @Override
    public Optional<TestEntity> findById(Long id) {
        return Optional.ofNullable(testMapper.selectById(id));
    }

    @Override
    public TestEntity create(TestRequest request) {
        TestEntity entity = toEntity(request);
        testMapper.insert(entity);
        return testMapper.selectById(entity.getId());
    }

    @Override
    public Optional<TestEntity> update(Long id, TestRequest request) {
        TestEntity existing = testMapper.selectById(id);
        if (existing == null) {
            return Optional.empty();
        }
        existing.setName(request.getName());
        existing.setAge(request.getAge());
        existing.setEmail(request.getEmail());
        testMapper.updateById(existing);
        return Optional.ofNullable(testMapper.selectById(id));
    }

    @Override
    public boolean delete(Long id) {
        return testMapper.deleteById(id) > 0;
    }

    private TestEntity toEntity(TestRequest request) {
        TestEntity entity = new TestEntity();
        entity.setName(request.getName());
        entity.setAge(request.getAge());
        entity.setEmail(request.getEmail());
        return entity;
    }
}
