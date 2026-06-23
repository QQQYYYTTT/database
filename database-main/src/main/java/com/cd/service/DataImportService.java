package com.cd.service;

import com.cd.dto.DataImportResultResponse;
import com.cd.dto.DataImportType;
import org.springframework.web.multipart.MultipartFile;

public interface DataImportService {

    DataImportResultResponse importExcel(DataImportType importType, MultipartFile file);
}
