package com.cd.controller;

import com.cd.dto.TestRequest;
import com.cd.entity.TestEntity;
import com.cd.service.TestService;
import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/tests")
public class TestController {

    private final TestService testService;

    public TestController(TestService testService) {
        this.testService = testService;
    }

    @GetMapping
    public List<TestEntity> findAll() {
        return testService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<TestEntity> findById(@PathVariable Long id) {
        return testService.findById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<TestEntity> create(@Valid @RequestBody TestRequest request) {
        TestEntity saved = testService.create(request);
        return ResponseEntity.created(URI.create("/api/tests/" + saved.getId())).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TestEntity> update(@PathVariable Long id, @Valid @RequestBody TestRequest request) {
        return testService.update(id, request)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!testService.delete(id)) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.noContent().build();
    }
}
