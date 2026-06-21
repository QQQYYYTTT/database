package com.cd.service;

import com.cd.dto.TestRequest;
import com.cd.entity.TestEntity;
import java.util.List;
import java.util.Optional;

public interface TestService {

    List<TestEntity> findAll();

    Optional<TestEntity> findById(Long id);

    TestEntity create(TestRequest request);

    Optional<TestEntity> update(Long id, TestRequest request);

    boolean delete(Long id);
}
