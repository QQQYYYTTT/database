package com.cd.dto;

import java.util.Arrays;

public enum DataImportType {
    USER("user"),
    STUDENT("student"),
    SCORE("score");

    private final String code;

    DataImportType(String code) {
        this.code = code;
    }

    public String getCode() {
        return code;
    }

    public static DataImportType from(String value) {
        return Arrays.stream(values())
                .filter(item -> item.code.equalsIgnoreCase(value))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("不支持的导入类型: " + value));
    }
}
