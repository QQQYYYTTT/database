package com.cd.controller;

import com.cd.common.Result;
import com.cd.dto.DataEntryOptionsResponse;
import com.cd.service.DataEntryService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/data-entry")
public class DataEntryController {

    private final DataEntryService dataEntryService;

    public DataEntryController(DataEntryService dataEntryService) {
        this.dataEntryService = dataEntryService;
    }

    @GetMapping("/options")
    @PreAuthorize("hasAuthority('sys:user:create')")
    public ResponseEntity<Result<DataEntryOptionsResponse>> loadOptions() {
        return ResponseEntity.ok(Result.success(dataEntryService.loadOptions()));
    }
}
