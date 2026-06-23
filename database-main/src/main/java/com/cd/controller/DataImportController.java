package com.cd.controller;

import com.cd.common.Result;
import com.cd.dto.DataImportResultResponse;
import com.cd.dto.DataImportType;
import com.cd.service.DataImportService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/import")
public class DataImportController {

    private final DataImportService dataImportService;

    public DataImportController(DataImportService dataImportService) {
        this.dataImportService = dataImportService;
    }

    @PostMapping("/{importType}")
    @PreAuthorize("hasAuthority('sys:user:create')")
    public ResponseEntity<Result<DataImportResultResponse>> importExcel(@PathVariable String importType,
                                                                        @RequestParam("file") MultipartFile file) {
        DataImportResultResponse result = dataImportService.importExcel(DataImportType.from(importType), file);
        return ResponseEntity.ok(Result.success("导入完成", result));
    }
}
