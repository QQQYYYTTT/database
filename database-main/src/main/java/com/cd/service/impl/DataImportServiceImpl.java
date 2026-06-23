package com.cd.service.impl;

import com.cd.dto.DataImportErrorResponse;
import com.cd.dto.DataImportResultResponse;
import com.cd.dto.DataImportType;
import com.cd.dto.RoleOptionResponse;
import com.cd.dto.StudentCreateRequest;
import com.cd.dto.StudentScoreCreateRequest;
import com.cd.dto.UserCreateRequest;
import com.cd.mapper.RoleMapper;
import com.cd.mapper.StudentAdminMapper;
import com.cd.service.DataImportService;
import com.cd.service.StudentAdminService;
import com.cd.service.UserService;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

@Service
public class DataImportServiceImpl implements DataImportService {

    private static final DataFormatter DATA_FORMATTER = new DataFormatter();
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private final UserService userService;
    private final RoleMapper roleMapper;
    private final StudentAdminService studentAdminService;
    private final StudentAdminMapper studentAdminMapper;

    public DataImportServiceImpl(UserService userService,
                                 RoleMapper roleMapper,
                                 StudentAdminService studentAdminService,
                                 StudentAdminMapper studentAdminMapper) {
        this.userService = userService;
        this.roleMapper = roleMapper;
        this.studentAdminService = studentAdminService;
        this.studentAdminMapper = studentAdminMapper;
    }

    @Override
    public DataImportResultResponse importExcel(DataImportType importType, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("请选择要导入的 Excel 文件");
        }
        String fileName = file.getOriginalFilename();
        if (!StringUtils.hasText(fileName) || !fileName.toLowerCase(Locale.ROOT).endsWith(".xlsx")) {
            throw new IllegalArgumentException("仅支持导入 .xlsx 文件");
        }

        try (InputStream inputStream = file.getInputStream();
             Workbook workbook = new XSSFWorkbook(inputStream)) {
            Sheet sheet = workbook.getNumberOfSheets() > 0 ? workbook.getSheetAt(0) : null;
            if (sheet == null) {
                throw new IllegalArgumentException("Excel 文件中没有可读取的工作表");
            }
            return switch (importType) {
                case USER -> importUsers(sheet);
                case STUDENT -> importStudents(sheet);
                case SCORE -> importScores(sheet);
            };
        } catch (IOException ex) {
            throw new IllegalArgumentException("读取 Excel 文件失败");
        }
    }

    private DataImportResultResponse importUsers(Sheet sheet) {
        String[] headers = {"用户名", "密码", "手机号", "邮箱", "头像地址", "角色编码"};
        validateHeaders(sheet, headers);

        Map<String, Long> roleCodeMap = new HashMap<>();
        for (RoleOptionResponse role : roleMapper.selectOptions()) {
            roleCodeMap.put(role.getRoleCode(), role.getId());
        }

        List<DataImportErrorResponse> errors = new ArrayList<>();
        int totalRows = 0;
        int successCount = 0;
        for (int rowIndex = 1; rowIndex <= sheet.getLastRowNum(); rowIndex++) {
            Row row = sheet.getRow(rowIndex);
            if (isRowBlank(row, 6)) {
                continue;
            }
            totalRows++;
            try {
                String userName = requiredCell(row, 0, "用户名不能为空");
                if (userService.findEntityByUserName(userName) != null) {
                    throw new IllegalArgumentException("用户名已存在");
                }
                UserCreateRequest request = new UserCreateRequest();
                request.setUserName(userName);
                request.setUserPwd(requiredCell(row, 1, "密码不能为空"));
                request.setUserPhonenum(optionalCell(row, 2));
                request.setUserEmail(optionalCell(row, 3));
                request.setUserHeader(optionalCell(row, 4));
                request.setRoleIds(resolveRoleIds(optionalCell(row, 5), roleCodeMap));
                userService.create(request);
                successCount++;
            } catch (Exception ex) {
                errors.add(buildError(rowIndex + 1, optionalCell(row, 0), ex.getMessage()));
            }
        }
        return buildImportResult(DataImportType.USER, totalRows, successCount, errors);
    }

    private DataImportResultResponse importStudents(Sheet sheet) {
        String[] headers = {"学号", "姓名", "性别", "出生日期", "班级代码", "手机号", "邮箱", "身份证号", "住址", "家庭收入", "银行卡号"};
        validateHeaders(sheet, headers);

        List<DataImportErrorResponse> errors = new ArrayList<>();
        int totalRows = 0;
        int successCount = 0;
        for (int rowIndex = 1; rowIndex <= sheet.getLastRowNum(); rowIndex++) {
            Row row = sheet.getRow(rowIndex);
            if (isRowBlank(row, 11)) {
                continue;
            }
            totalRows++;
            try {
                StudentCreateRequest request = new StudentCreateRequest();
                request.setStudentNo(requiredCell(row, 0, "学号不能为空"));
                request.setName(requiredCell(row, 1, "姓名不能为空"));
                request.setGender(requiredCell(row, 2, "性别不能为空"));
                request.setBirthDate(parseDate(optionalCell(row, 3)));
                request.setClassId(resolveClassId(requiredCell(row, 4, "班级代码不能为空")));
                request.setStatus(1);
                request.setPhone(optionalCell(row, 5));
                request.setEmail(optionalCell(row, 6));
                request.setIdCard(optionalCell(row, 7));
                request.setAddress(optionalCell(row, 8));
                request.setFamilyIncome(parseDecimal(optionalCell(row, 9), "家庭收入格式不正确"));
                request.setBankCard(optionalCell(row, 10));
                studentAdminService.createStudent(request);
                successCount++;
            } catch (Exception ex) {
                errors.add(buildError(rowIndex + 1, optionalCell(row, 0), ex.getMessage()));
            }
        }
        return buildImportResult(DataImportType.STUDENT, totalRows, successCount, errors);
    }

    private DataImportResultResponse importScores(Sheet sheet) {
        String[] headers = {"学号", "课程代码", "学期名称", "成绩"};
        validateHeaders(sheet, headers);

        List<DataImportErrorResponse> errors = new ArrayList<>();
        int totalRows = 0;
        int successCount = 0;
        for (int rowIndex = 1; rowIndex <= sheet.getLastRowNum(); rowIndex++) {
            Row row = sheet.getRow(rowIndex);
            if (isRowBlank(row, 4)) {
                continue;
            }
            totalRows++;
            try {
                StudentScoreCreateRequest request = new StudentScoreCreateRequest();
                request.setStudentNo(requiredCell(row, 0, "学号不能为空"));
                request.setCourseId(resolveCourseId(requiredCell(row, 1, "课程代码不能为空")));
                request.setSemesterId(resolveSemesterId(requiredCell(row, 2, "学期名称不能为空")));
                request.setScore(parseDecimal(requiredCell(row, 3, "成绩不能为空"), "成绩格式不正确"));
                studentAdminService.saveStudentScore(request);
                successCount++;
            } catch (Exception ex) {
                errors.add(buildError(rowIndex + 1, optionalCell(row, 0), ex.getMessage()));
            }
        }
        return buildImportResult(DataImportType.SCORE, totalRows, successCount, errors);
    }

    private List<Long> resolveRoleIds(String roleCodes, Map<String, Long> roleCodeMap) {
        List<Long> roleIds = new ArrayList<>();
        if (!StringUtils.hasText(roleCodes)) {
            return roleIds;
        }
        String[] parts = roleCodes.split("[,，/\\s]+");
        for (String part : parts) {
            if (!StringUtils.hasText(part)) {
                continue;
            }
            Long roleId = roleCodeMap.get(part.trim());
            if (roleId == null) {
                throw new IllegalArgumentException("角色编码不存在: " + part.trim());
            }
            if (!roleIds.contains(roleId)) {
                roleIds.add(roleId);
            }
        }
        return roleIds;
    }

    private Long resolveClassId(String classCode) {
        Long classId = studentAdminMapper.selectClassIdByClassCode(classCode);
        if (classId == null) {
            throw new IllegalArgumentException("班级代码不存在: " + classCode);
        }
        return classId;
    }

    private Long resolveCourseId(String courseCode) {
        Long courseId = studentAdminMapper.selectCourseIdByCourseCode(courseCode);
        if (courseId == null) {
            throw new IllegalArgumentException("课程代码不存在: " + courseCode);
        }
        return courseId;
    }

    private Long resolveSemesterId(String semesterName) {
        Long semesterId = studentAdminMapper.selectSemesterIdBySemesterName(semesterName);
        if (semesterId == null) {
            throw new IllegalArgumentException("学期名称不存在: " + semesterName);
        }
        return semesterId;
    }

    private void validateHeaders(Sheet sheet, String[] expectedHeaders) {
        Row headerRow = sheet.getRow(0);
        if (headerRow == null) {
            throw new IllegalArgumentException("Excel 表头不能为空");
        }
        for (int i = 0; i < expectedHeaders.length; i++) {
            String actual = normalizeCellValue(headerRow.getCell(i));
            if (!expectedHeaders[i].equals(actual)) {
                throw new IllegalArgumentException("Excel 表头不匹配，请使用系统约定模板");
            }
        }
    }

    private boolean isRowBlank(Row row, int expectedColumns) {
        if (row == null) {
            return true;
        }
        for (int i = 0; i < expectedColumns; i++) {
            if (StringUtils.hasText(normalizeCellValue(row.getCell(i)))) {
                return false;
            }
        }
        return true;
    }

    private String requiredCell(Row row, int index, String message) {
        String value = optionalCell(row, index);
        if (!StringUtils.hasText(value)) {
            throw new IllegalArgumentException(message);
        }
        return value;
    }

    private String optionalCell(Row row, int index) {
        return normalizeCellValue(row == null ? null : row.getCell(index));
    }

    private String normalizeCellValue(Cell cell) {
        if (cell == null) {
            return "";
        }
        String value = DATA_FORMATTER.formatCellValue(cell);
        return value == null ? "" : value.trim();
    }

    private String parseDate(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        try {
            return LocalDate.parse(value.trim(), DATE_FORMATTER).format(DATE_FORMATTER);
        } catch (DateTimeParseException ex) {
            throw new IllegalArgumentException("日期格式应为 yyyy-MM-dd");
        }
    }

    private BigDecimal parseDecimal(String value, String message) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        try {
            return new BigDecimal(value.trim());
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException(message);
        }
    }

    private DataImportErrorResponse buildError(int rowNumber, String identifier, String message) {
        DataImportErrorResponse error = new DataImportErrorResponse();
        error.setRowNumber(rowNumber);
        error.setIdentifier(identifier);
        error.setMessage(StringUtils.hasText(message) ? message : "导入失败");
        return error;
    }

    private DataImportResultResponse buildImportResult(DataImportType importType,
                                                       int totalRows,
                                                       int successCount,
                                                       List<DataImportErrorResponse> errors) {
        DataImportResultResponse response = new DataImportResultResponse();
        response.setImportType(importType.getCode());
        response.setTotalRows(totalRows);
        response.setSuccessCount(successCount);
        response.setFailureCount(errors.size());
        response.setErrors(errors);
        return response;
    }
}
