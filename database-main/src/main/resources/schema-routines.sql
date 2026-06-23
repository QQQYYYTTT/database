DROP PROCEDURE IF EXISTS SP_DETECT_ABNORMAL;
DROP PROCEDURE IF EXISTS SP_UPDATE_MASKING_RULE;
DROP PROCEDURE IF EXISTS SP_QUERY_STUDENT_SCORES;
DROP PROCEDURE IF EXISTS SP_QUERY_STUDENTS;
DROP FUNCTION IF EXISTS FN_MASK_BY_ROLE;
DROP FUNCTION IF EXISTS FN_APPLY_MASK;

SET @fn_apply_mask = '
CREATE FUNCTION FN_APPLY_MASK(
    p_raw_value TEXT CHARSET utf8mb4,
    p_type_code VARCHAR(50) CHARSET utf8mb4,
    p_params JSON
) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    DETERMINISTIC
    NO SQL
BEGIN
    DECLARE v_input TEXT CHARSET utf8mb4;
    DECLARE v_len INT DEFAULT 0;
    DECLARE v_prefix INT DEFAULT 0;
    DECLARE v_suffix INT DEFAULT 0;
    DECLARE v_step DECIMAL(18, 2) DEFAULT 10;
    DECLARE v_level VARCHAR(20) CHARSET utf8mb4 DEFAULT ''city'';
    DECLARE v_at_pos INT DEFAULT 0;
    DECLARE v_numeric_value DECIMAL(18, 2) DEFAULT 0;
    DECLARE v_start DECIMAL(18, 2) DEFAULT 0;
    DECLARE v_end DECIMAL(18, 2) DEFAULT 0;
    DECLARE v_province_end INT DEFAULT 0;
    DECLARE v_city_end INT DEFAULT 0;
    DECLARE v_email_local TEXT CHARSET utf8mb4;
    DECLARE v_email_domain TEXT CHARSET utf8mb4;
    DECLARE v_effective_params JSON;
    DECLARE v_trimmed_numeric TEXT CHARSET utf8mb4;

    IF p_raw_value IS NULL THEN
        RETURN NULL;
    END IF;

    SET v_input = CONVERT(p_raw_value USING utf8mb4);

    IF v_input = '''' THEN
        RETURN '''';
    END IF;

    IF p_type_code IS NULL OR TRIM(p_type_code) = '''' THEN
        RETURN v_input;
    END IF;

    SET v_effective_params = COALESCE(p_params, JSON_OBJECT());
    SET v_len = CHAR_LENGTH(v_input);

    CASE UPPER(TRIM(p_type_code))
        WHEN ''NO_MASK'' THEN
            RETURN v_input;
        WHEN ''NONE'' THEN
            RETURN v_input;
        WHEN ''FULL_MASK'' THEN
            RETURN REPEAT(''*'', v_len);
        WHEN ''NULL_MASK'' THEN
            RETURN NULL;
        WHEN ''KEEP_PREFIX'' THEN
            SET v_prefix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, ''$.prefix'')), ''1'') AS SIGNED);
            SET v_prefix = GREATEST(v_prefix, 0);
            SET v_prefix = LEAST(v_prefix, v_len);
            IF v_prefix >= v_len THEN
                RETURN v_input;
            END IF;
            RETURN CONCAT(LEFT(v_input, v_prefix), REPEAT(''*'', v_len - v_prefix));
        WHEN ''KEEP_SUFFIX'' THEN
            SET v_suffix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, ''$.suffix'')), ''4'') AS SIGNED);
            SET v_suffix = GREATEST(v_suffix, 0);
            SET v_suffix = LEAST(v_suffix, v_len);
            IF v_suffix >= v_len THEN
                RETURN v_input;
            END IF;
            RETURN CONCAT(REPEAT(''*'', v_len - v_suffix), RIGHT(v_input, v_suffix));
        WHEN ''KEEP_PREFIX_SUFFIX'' THEN
            SET v_prefix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, ''$.prefix'')), ''3'') AS SIGNED);
            SET v_suffix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, ''$.suffix'')), ''4'') AS SIGNED);
            SET v_prefix = GREATEST(v_prefix, 0);
            SET v_suffix = GREATEST(v_suffix, 0);
            IF v_prefix + v_suffix >= v_len THEN
                RETURN v_input;
            END IF;
            RETURN CONCAT(LEFT(v_input, v_prefix), REPEAT(''*'', v_len - v_prefix - v_suffix), RIGHT(v_input, v_suffix));
        WHEN ''PARTIAL_MASK'' THEN
            SET v_prefix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, ''$.prefix_keep'')), ''1'') AS SIGNED);
            SET v_suffix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, ''$.suffix_keep'')), ''1'') AS SIGNED);
            SET v_prefix = GREATEST(v_prefix, 0);
            SET v_suffix = GREATEST(v_suffix, 0);
            IF v_prefix + v_suffix >= v_len THEN
                RETURN v_input;
            END IF;
            RETURN CONCAT(LEFT(v_input, v_prefix), REPEAT(''*'', v_len - v_prefix - v_suffix), RIGHT(v_input, v_suffix));
        WHEN ''EMAIL_MASK'' THEN
            SET v_at_pos = LOCATE(''@'', v_input);
            IF v_at_pos <= 0 THEN
                RETURN REPEAT(''*'', v_len);
            END IF;
            SET v_email_local = SUBSTRING_INDEX(v_input, ''@'', 1);
            SET v_email_domain = SUBSTRING_INDEX(v_input, ''@'', -1);
            IF CHAR_LENGTH(v_email_local) <= 1 THEN
                RETURN CONCAT(''*@'', v_email_domain);
            END IF;
            RETURN CONCAT(LEFT(v_email_local, 1), REPEAT(''*'', CHAR_LENGTH(v_email_local) - 1), ''@'', v_email_domain);
        WHEN ''ADDRESS_LEVEL'' THEN
            SET v_level = LOWER(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, ''$.level'')), ''city''));
            IF LOCATE(''特别行政区'', v_input) > 0 THEN
                SET v_province_end = LOCATE(''特别行政区'', v_input) + CHAR_LENGTH(''特别行政区'') - 1;
            ELSEIF LOCATE(''自治区'', v_input) > 0 THEN
                SET v_province_end = LOCATE(''自治区'', v_input) + CHAR_LENGTH(''自治区'') - 1;
            ELSEIF LOCATE(''省'', v_input) > 0 THEN
                SET v_province_end = LOCATE(''省'', v_input);
            ELSEIF LOCATE(''市'', v_input) > 0 THEN
                SET v_province_end = LOCATE(''市'', v_input);
            END IF;
            IF v_level = ''province'' THEN
                IF v_province_end > 0 THEN
                    RETURN CONCAT(LEFT(v_input, v_province_end), ''**'');
                END IF;
                IF v_len <= 2 THEN
                    RETURN v_input;
                END IF;
                RETURN CONCAT(LEFT(v_input, 2), ''**'');
            END IF;
            IF v_province_end > 0 AND v_province_end < v_len THEN
                IF LOCATE(''市'', SUBSTRING(v_input, v_province_end + 1)) > 0 THEN
                    SET v_city_end = v_province_end + LOCATE(''市'', SUBSTRING(v_input, v_province_end + 1));
                ELSEIF LOCATE(''州'', SUBSTRING(v_input, v_province_end + 1)) > 0 THEN
                    SET v_city_end = v_province_end + LOCATE(''州'', SUBSTRING(v_input, v_province_end + 1));
                ELSEIF LOCATE(''盟'', SUBSTRING(v_input, v_province_end + 1)) > 0 THEN
                    SET v_city_end = v_province_end + LOCATE(''盟'', SUBSTRING(v_input, v_province_end + 1));
                END IF;
            END IF;
            IF v_city_end = 0 AND LOCATE(''市'', v_input) > 0 THEN
                SET v_city_end = LOCATE(''市'', v_input);
            END IF;
            IF v_city_end > 0 THEN
                RETURN CONCAT(LEFT(v_input, v_city_end), ''***'');
            END IF;
            IF v_len <= 2 THEN
                RETURN v_input;
            END IF;
            RETURN CONCAT(LEFT(v_input, 2), ''***'');
        WHEN ''GENERALIZATION'' THEN
            SET v_step = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, ''$.step'')), ''10'') AS DECIMAL(18, 2));
            IF v_step IS NULL OR v_step <= 0 THEN
                SET v_step = 10;
            END IF;
            SET v_trimmed_numeric = TRIM(v_input);
            IF v_trimmed_numeric = '''' OR v_trimmed_numeric NOT REGEXP ''^-?[0-9]+(\\.[0-9]+)?$'' THEN
                RETURN v_input;
            END IF;
            SET v_numeric_value = CAST(v_trimmed_numeric AS DECIMAL(18, 2));
            SET v_start = FLOOR(v_numeric_value / v_step) * v_step;
            SET v_end = v_start + v_step;
            RETURN CONCAT(TRIM(TRAILING ''.'' FROM TRIM(TRAILING ''0'' FROM CAST(v_start AS CHAR))), ''-'', TRIM(TRAILING ''.'' FROM TRIM(TRAILING ''0'' FROM CAST(v_end AS CHAR))));
        WHEN ''RANGE_MASK'' THEN
            SET v_step = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, ''$.range_size'')), ''10'') AS DECIMAL(18, 2));
            IF v_step IS NULL OR v_step <= 0 THEN
                SET v_step = 10;
            END IF;
            SET v_trimmed_numeric = TRIM(v_input);
            IF v_trimmed_numeric = '''' OR v_trimmed_numeric NOT REGEXP ''^-?[0-9]+(\\.[0-9]+)?$'' THEN
                RETURN v_input;
            END IF;
            SET v_numeric_value = CAST(v_trimmed_numeric AS DECIMAL(18, 2));
            SET v_start = FLOOR(v_numeric_value / v_step) * v_step;
            SET v_end = v_start + v_step;
            RETURN CONCAT(TRIM(TRAILING ''.'' FROM TRIM(TRAILING ''0'' FROM CAST(v_start AS CHAR))), ''-'', TRIM(TRAILING ''.'' FROM TRIM(TRAILING ''0'' FROM CAST(v_end AS CHAR))));
        WHEN ''KEEP_YEAR'' THEN
            IF CONVERT(v_input USING utf8mb4) REGEXP ''^[0-9]{4}'' THEN
                RETURN CONCAT(LEFT(v_input, 4), ''-**-**'');
            END IF;
            RETURN v_input;
        WHEN ''HASH_MASK'' THEN
            RETURN LEFT(MD5(v_input), 12);
        ELSE
            RETURN v_input;
    END CASE;
END';
PREPARE stmt FROM @fn_apply_mask;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @fn_mask_by_role = '
CREATE FUNCTION FN_MASK_BY_ROLE(
    p_role_id BIGINT,
    p_object_name VARCHAR(100) CHARSET utf8mb4,
    p_column_name VARCHAR(100) CHARSET utf8mb4,
    p_raw_value TEXT CHARSET utf8mb4
) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    READS SQL DATA
BEGIN
    DECLARE v_sensitive_field_id BIGINT DEFAULT NULL;
    DECLARE v_masking_type VARCHAR(50) DEFAULT NULL;
    DECLARE v_params JSON DEFAULT NULL;
    DECLARE v_input TEXT CHARSET utf8mb4;

    IF p_raw_value IS NULL THEN
        RETURN NULL;
    END IF;

    SET v_input = CONVERT(p_raw_value USING utf8mb4);

    IF p_object_name IS NULL OR TRIM(p_object_name) = '''' OR p_column_name IS NULL OR TRIM(p_column_name) = '''' THEN
        RETURN v_input;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM role r WHERE r.id = p_role_id AND r.enabled = 1) THEN
        RETURN v_input;
    END IF;

    SELECT sf.id INTO v_sensitive_field_id
      FROM sensitive_field sf
     WHERE sf.table_name = p_object_name
       AND sf.column_name = p_column_name
       AND sf.enabled = 1
     LIMIT 1;

    IF v_sensitive_field_id IS NULL THEN
        RETURN v_input;
    END IF;

    SELECT mp.masking_type, mp.params INTO v_masking_type, v_params
      FROM masking_rule_assignment mra
      JOIN role r ON r.id = mra.role_id AND r.enabled = 1
      JOIN masking_policy mp ON mp.id = mra.policy_id AND mp.sensitive_field_id = v_sensitive_field_id
     WHERE mra.role_id = p_role_id
       AND mra.enabled = 1
     ORDER BY mra.id DESC, mp.id DESC
     LIMIT 1;

    IF v_masking_type IS NULL THEN
        SELECT mp.masking_type, mp.params INTO v_masking_type, v_params
          FROM masking_policy mp
         WHERE mp.sensitive_field_id = v_sensitive_field_id
           AND mp.is_default = 1
         ORDER BY mp.id DESC
         LIMIT 1;
    END IF;

    IF v_masking_type IS NULL THEN
        RETURN v_input;
    END IF;

    RETURN FN_APPLY_MASK(v_input, v_masking_type, v_params);
END';
PREPARE stmt FROM @fn_mask_by_role;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sp_update_masking_rule = '
CREATE PROCEDURE SP_UPDATE_MASKING_RULE(
    IN p_operator_user_id BIGINT,
    IN p_operator_name VARCHAR(50) CHARSET utf8mb4,
    IN p_role_id BIGINT,
    IN p_policy_id BIGINT
)
BEGIN
    DECLARE v_sensitive_field_id BIGINT DEFAULT NULL;
    DECLARE v_existing_assignment_id BIGINT DEFAULT NULL;
    DECLARE v_before_assignment_id BIGINT DEFAULT NULL;
    DECLARE v_before_policy_id BIGINT DEFAULT NULL;
    DECLARE v_before_masking_type VARCHAR(50) CHARSET utf8mb4 DEFAULT NULL;
    DECLARE v_before_params JSON DEFAULT NULL;
    DECLARE v_after_masking_type VARCHAR(50) CHARSET utf8mb4 DEFAULT NULL;
    DECLARE v_after_params JSON DEFAULT NULL;
    DECLARE v_effective_operator_name VARCHAR(50) CHARSET utf8mb4 DEFAULT NULL;
    DECLARE v_before_content JSON DEFAULT NULL;
    DECLARE v_after_content JSON DEFAULT NULL;

    IF p_role_id IS NULL OR p_role_id <= 0 THEN
        SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''角色参数不合法'';
    END IF;

    IF p_policy_id IS NULL OR p_policy_id <= 0 THEN
        SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''脱敏策略参数不合法'';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM role WHERE id = p_role_id AND enabled = 1) THEN
        SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''目标角色不存在或已禁用'';
    END IF;

    SELECT sensitive_field_id, masking_type, params
      INTO v_sensitive_field_id, v_after_masking_type, v_after_params
      FROM masking_policy
     WHERE id = p_policy_id
     LIMIT 1;

    IF v_sensitive_field_id IS NULL THEN
        SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''目标脱敏策略不存在'';
    END IF;

    SELECT mra.id, mra.policy_id, mp.masking_type, mp.params
      INTO v_before_assignment_id, v_before_policy_id, v_before_masking_type, v_before_params
      FROM masking_rule_assignment mra
      JOIN masking_policy mp ON mp.id = mra.policy_id
     WHERE mra.role_id = p_role_id
       AND mra.enabled = 1
       AND mp.sensitive_field_id = v_sensitive_field_id
     ORDER BY mra.id DESC
     LIMIT 1;

    UPDATE masking_rule_assignment mra
    JOIN masking_policy mp ON mp.id = mra.policy_id
       SET mra.enabled = 0
     WHERE mra.role_id = p_role_id
       AND mp.sensitive_field_id = v_sensitive_field_id;

    SELECT id
      INTO v_existing_assignment_id
      FROM masking_rule_assignment
     WHERE role_id = p_role_id
       AND policy_id = p_policy_id
     LIMIT 1;

    IF v_existing_assignment_id IS NOT NULL THEN
        UPDATE masking_rule_assignment
           SET enabled = 1
         WHERE id = v_existing_assignment_id;
    ELSE
        INSERT INTO masking_rule_assignment (role_id, policy_id, enabled)
        VALUES (p_role_id, p_policy_id, 1);
        SET v_existing_assignment_id = LAST_INSERT_ID();
    END IF;

    SET v_effective_operator_name = NULLIF(TRIM(CONVERT(p_operator_name USING utf8mb4)), '''');
    IF v_effective_operator_name IS NULL THEN
        SET v_effective_operator_name = ''system'';
    END IF;

    SET @AUDIT_SUPPRESS_MASKING_RULE_LOG = 1;

    SET v_before_content = JSON_OBJECT(
        ''assignmentId'', v_before_assignment_id,
        ''roleId'', p_role_id,
        ''policyId'', v_before_policy_id,
        ''maskingType'', v_before_masking_type,
        ''params'', v_before_params
    );

    SET v_after_content = JSON_OBJECT(
        ''assignmentId'', v_existing_assignment_id,
        ''roleId'', p_role_id,
        ''policyId'', p_policy_id,
        ''maskingType'', v_after_masking_type,
        ''params'', v_after_params
    );

    INSERT INTO rule_change_log (
        policy_id,
        operator_name,
        operation_type,
        before_content,
        after_content,
        operate_time
    ) VALUES (
        p_policy_id,
        v_effective_operator_name,
        CASE
            WHEN v_before_policy_id IS NULL THEN ''MASKING_RULE_RESTORE''
            ELSE ''MASKING_RULE_UPDATE''
        END,
        JSON_COMPACT(v_before_content),
        JSON_COMPACT(v_after_content),
        NOW()
    );

    SET @AUDIT_SUPPRESS_MASKING_RULE_LOG = NULL;
END';
PREPARE stmt FROM @sp_update_masking_rule;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sp_detect_abnormal = '
CREATE PROCEDURE SP_DETECT_ABNORMAL(
    IN p_operator_user_id BIGINT
)
BEGIN
    DECLARE v_operator_id BIGINT DEFAULT NULL;
    DECLARE v_operator_name VARCHAR(100) CHARSET utf8mb4 DEFAULT NULL;
    DECLARE v_high_frequency_threshold INT DEFAULT 5;
    DECLARE v_daily_sensitive_threshold INT DEFAULT 8;
    DECLARE v_normal_user_threshold INT DEFAULT 10;
    DECLARE v_window_minutes INT DEFAULT 10;

    SET v_operator_id = NULLIF(p_operator_user_id, 0);
    IF v_operator_id IS NOT NULL THEN
        SELECT u.user_name INTO v_operator_name
          FROM user u
         WHERE u.id = v_operator_id
         LIMIT 1;
    END IF;

    IF v_operator_name IS NULL THEN
        SET v_operator_name = ''system'';
    END IF;

    DROP TEMPORARY TABLE IF EXISTS tmp_abnormal_events;
    CREATE TEMPORARY TABLE tmp_abnormal_events (
        user_id BIGINT,
        rule_name VARCHAR(100) CHARSET utf8mb4,
        abnormal_type VARCHAR(50) CHARSET utf8mb4,
        severity VARCHAR(20) CHARSET utf8mb4,
        trigger_count INT,
        window_start DATETIME,
        window_end DATETIME,
        detail TEXT CHARSET utf8mb4
    ) ENGINE=InnoDB;

    INSERT INTO tmp_abnormal_events (
        user_id, rule_name, abnormal_type, severity, trigger_count, window_start, window_end, detail
    )
    SELECT
        al.user_id,
        ''SHORT_TIME_HIGH_FREQ'',
        ''SHORT_TIME_HIGH_FREQ'',
        CASE WHEN COUNT(*) >= v_high_frequency_threshold * 2 THEN ''HIGH'' ELSE ''MEDIUM'' END,
        COUNT(*),
        MIN(al.access_time),
        MAX(al.access_time),
        JSON_OBJECT(
            ''roleCode'', MAX(al.role_code),
            ''operationType'', MAX(al.operation_type),
            ''tableName'', MAX(al.table_name),
            ''minutes'', v_window_minutes
        )
    FROM access_log al
    WHERE al.access_time >= NOW() - INTERVAL v_window_minutes MINUTE
      AND al.operation_type IN (''QUERY_STUDENT_PROFILE'', ''QUERY_STUDENT_SCORE'')
    GROUP BY al.user_id
    HAVING COUNT(*) >= v_high_frequency_threshold;

    INSERT INTO tmp_abnormal_events (
        user_id, rule_name, abnormal_type, severity, trigger_count, window_start, window_end, detail
    )
    SELECT
        al.user_id,
        ''DAILY_SENSITIVE_ACCESS'',
        ''DAILY_SENSITIVE_ACCESS'',
        CASE WHEN COUNT(*) >= v_daily_sensitive_threshold * 2 THEN ''HIGH'' ELSE ''MEDIUM'' END,
        COUNT(*),
        DATE_FORMAT(NOW(), ''%Y-%m-%d 00:00:00''),
        NOW(),
        JSON_OBJECT(
            ''roleCode'', MAX(al.role_code),
            ''operations'', GROUP_CONCAT(DISTINCT al.operation_type ORDER BY al.operation_type),
            ''window'', ''1 day''
        )
    FROM access_log al
    WHERE al.access_time >= CURDATE()
      AND al.operation_type IN (''QUERY_STUDENT_PROFILE'', ''QUERY_STUDENT_SCORE'')
    GROUP BY al.user_id
    HAVING COUNT(*) >= v_daily_sensitive_threshold;

    INSERT INTO tmp_abnormal_events (
        user_id, rule_name, abnormal_type, severity, trigger_count, window_start, window_end, detail
    )
    SELECT
        al.user_id,
        ''NORMAL_USER_VOLUME'',
        ''NORMAL_USER_VOLUME'',
        CASE WHEN COUNT(*) >= v_normal_user_threshold * 2 THEN ''HIGH'' ELSE ''MEDIUM'' END,
        COUNT(*),
        DATE_FORMAT(NOW(), ''%Y-%m-%d 00:00:00''),
        NOW(),
        JSON_OBJECT(
            ''roleCode'', MAX(al.role_code),
            ''threshold'', v_normal_user_threshold,
            ''window'', ''1 day''
        )
    FROM access_log al
    WHERE al.access_time >= CURDATE()
      AND al.operation_type IN (''QUERY_STUDENT_PROFILE'', ''QUERY_STUDENT_SCORE'')
      AND al.role_code IN (''NORMAL'', ''STUDENT'')
    GROUP BY al.user_id
    HAVING COUNT(*) >= v_normal_user_threshold;

    INSERT INTO abnormal_access (
        user_id,
        rule_name,
        abnormal_type,
        severity,
        trigger_count,
        window_start,
        window_end,
        detail,
        create_time
    )
    SELECT
        t.user_id,
        t.rule_name,
        t.abnormal_type,
        t.severity,
        t.trigger_count,
        t.window_start,
        t.window_end,
        JSON_COMPACT(t.detail),
        NOW()
    FROM tmp_abnormal_events t
    WHERE NOT EXISTS (
        SELECT 1
        FROM abnormal_access aa
        WHERE aa.user_id <=> t.user_id
          AND aa.rule_name = t.rule_name
          AND aa.window_start <=> t.window_start
          AND aa.window_end <=> t.window_end
          AND aa.trigger_count <=> t.trigger_count
    );

    DROP TEMPORARY TABLE IF EXISTS tmp_abnormal_events;
END';
PREPARE stmt FROM @sp_detect_abnormal;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sp_query_students = '
CREATE PROCEDURE SP_QUERY_STUDENTS(
    IN p_user_id BIGINT,
    IN p_role_code VARCHAR(50) CHARSET utf8mb4,
    IN p_student_no VARCHAR(30) CHARSET utf8mb4,
    IN p_name VARCHAR(50) CHARSET utf8mb4,
    IN p_class_name VARCHAR(100) CHARSET utf8mb4
)
BEGIN
    DECLARE v_role_id BIGINT DEFAULT NULL;
    DECLARE v_role_code VARCHAR(50) CHARSET utf8mb4;
    DECLARE v_student_no VARCHAR(30) CHARSET utf8mb4;
    DECLARE v_name VARCHAR(50) CHARSET utf8mb4;
    DECLARE v_class_name VARCHAR(100) CHARSET utf8mb4;
    DECLARE v_user_exists INT DEFAULT 0;
    DECLARE v_error_message VARCHAR(255) CHARSET utf8mb4;
    DECLARE v_masking_applied TINYINT DEFAULT 0;

    SET v_role_code = NULLIF(TRIM(CONVERT(p_role_code USING utf8mb4)), '''');
    SET v_student_no = NULLIF(TRIM(CONVERT(p_student_no USING utf8mb4)), '''');
    SET v_name = NULLIF(TRIM(CONVERT(p_name USING utf8mb4)), '''');
    SET v_class_name = NULLIF(TRIM(CONVERT(p_class_name USING utf8mb4)), '''');

    IF p_user_id IS NULL OR p_user_id <= 0 THEN
        SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''用户标识不能为空'';
    END IF;

    SELECT COUNT(1) INTO v_user_exists
      FROM user u
     WHERE u.id = p_user_id
       AND u.enabled = 1;

    IF v_user_exists = 0 THEN
        SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''当前登录用户不存在或已禁用'';
    END IF;

    IF v_role_code IS NULL THEN
        SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''角色编码不能为空'';
    END IF;

    SELECT r.id INTO v_role_id
      FROM role r
     WHERE r.role_code = v_role_code
       AND r.enabled = 1
     LIMIT 1;

    IF v_role_id IS NULL THEN
        SET v_error_message = CONCAT(''角色不存在或已禁用: '', v_role_code);
        SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = v_error_message;
    END IF;

    SET v_masking_applied = CASE WHEN v_role_code IN (''SUPER_ADMIN'', ''DATA_ADMIN'', ''STUDENT'') THEN 0 ELSE 1 END;

    INSERT INTO access_log (
        user_id,
        role_code,
        operation_type,
        table_name,
        sensitive_columns,
        masking_applied,
        access_time
    ) VALUES (
        p_user_id,
        v_role_code,
        ''QUERY_STUDENT_PROFILE'',
        ''v_student_profile'',
        ''name,birth_date,phone,email,id_card,address,family_income,bank_card'',
        v_masking_applied,
        NOW()
    );

    SELECT
        v.student_id,
        v.student_no,
        FN_MASK_BY_ROLE(v_role_id, ''v_student_profile'', ''name'', CONVERT(v.name USING utf8mb4)) AS name,
        v.gender,
        FN_MASK_BY_ROLE(v_role_id, ''v_student_profile'', ''birth_date'', CONVERT(DATE_FORMAT(v.birth_date, ''%Y-%m-%d'') USING utf8mb4)) AS birth_date,
        v.status,
        v.class_name,
        v.grade_name,
        v.entry_year,
        v.major_name,
        v.college_name,
        FN_MASK_BY_ROLE(v_role_id, ''v_student_profile'', ''phone'', CONVERT(v.phone USING utf8mb4)) AS phone,
        FN_MASK_BY_ROLE(v_role_id, ''v_student_profile'', ''email'', CONVERT(v.email USING utf8mb4)) AS email,
        FN_MASK_BY_ROLE(v_role_id, ''v_student_profile'', ''id_card'', CONVERT(v.id_card USING utf8mb4)) AS id_card,
        FN_MASK_BY_ROLE(v_role_id, ''v_student_profile'', ''address'', CONVERT(v.address USING utf8mb4)) AS address,
        FN_MASK_BY_ROLE(v_role_id, ''v_student_profile'', ''family_income'', CONVERT(CAST(v.family_income AS CHAR CHARACTER SET utf8mb4) USING utf8mb4)) AS family_income,
        FN_MASK_BY_ROLE(v_role_id, ''v_student_profile'', ''bank_card'', CONVERT(v.bank_card USING utf8mb4)) AS bank_card
    FROM v_student_profile v
    WHERE (v_student_no IS NULL OR v.student_no = v_student_no)
      AND (v_name IS NULL OR CONVERT(v.name USING utf8mb4) LIKE CONCAT(''%'', v_name, ''%''))
      AND (v_class_name IS NULL OR CONVERT(v.class_name USING utf8mb4) = v_class_name)
    ORDER BY v.student_no;
END';
PREPARE stmt FROM @sp_query_students;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sp_query_student_scores = '
CREATE PROCEDURE SP_QUERY_STUDENT_SCORES(
    IN p_user_id BIGINT,
    IN p_role_code VARCHAR(50) CHARSET utf8mb4,
    IN p_student_no VARCHAR(30) CHARSET utf8mb4,
    IN p_course_name VARCHAR(100) CHARSET utf8mb4,
    IN p_semester_name VARCHAR(100) CHARSET utf8mb4
)
BEGIN
    DECLARE v_role_id BIGINT DEFAULT NULL;
    DECLARE v_role_code VARCHAR(50) CHARSET utf8mb4;
    DECLARE v_student_no VARCHAR(30) CHARSET utf8mb4;
    DECLARE v_course_name VARCHAR(100) CHARSET utf8mb4;
    DECLARE v_semester_name VARCHAR(100) CHARSET utf8mb4;
    DECLARE v_user_exists INT DEFAULT 0;
    DECLARE v_error_message VARCHAR(255) CHARSET utf8mb4;
    DECLARE v_masking_applied TINYINT DEFAULT 0;

    SET v_role_code = NULLIF(TRIM(CONVERT(p_role_code USING utf8mb4)), '''');
    SET v_student_no = NULLIF(TRIM(CONVERT(p_student_no USING utf8mb4)), '''');
    SET v_course_name = NULLIF(TRIM(CONVERT(p_course_name USING utf8mb4)), '''');
    SET v_semester_name = NULLIF(TRIM(CONVERT(p_semester_name USING utf8mb4)), '''');

    IF p_user_id IS NULL OR p_user_id <= 0 THEN
        SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''用户标识不能为空'';
    END IF;

    SELECT COUNT(1) INTO v_user_exists
      FROM user u
     WHERE u.id = p_user_id
       AND u.enabled = 1;

    IF v_user_exists = 0 THEN
        SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''当前登录用户不存在或已禁用'';
    END IF;

    IF v_role_code IS NULL THEN
        SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''角色编码不能为空'';
    END IF;

    SELECT r.id INTO v_role_id
      FROM role r
     WHERE r.role_code = v_role_code
       AND r.enabled = 1
     LIMIT 1;

    IF v_role_id IS NULL THEN
        SET v_error_message = CONCAT(''角色不存在或已禁用: '', v_role_code);
        SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = v_error_message;
    END IF;

    SET v_masking_applied = CASE WHEN v_role_code IN (''SUPER_ADMIN'', ''DATA_ADMIN'', ''TEACHER'', ''STUDENT'') THEN 0 ELSE 1 END;

    INSERT INTO access_log (
        user_id,
        role_code,
        operation_type,
        table_name,
        sensitive_columns,
        masking_applied,
        access_time
    ) VALUES (
        p_user_id,
        v_role_code,
        ''QUERY_STUDENT_SCORE'',
        ''v_student_score_detail'',
        ''score'',
        v_masking_applied,
        NOW()
    );

    SELECT
        v.score_id,
        v.student_id,
        v.student_no,
        v.student_name,
        v.course_code,
        v.course_name,
        v.semester_name,
        FN_MASK_BY_ROLE(v_role_id, ''v_student_score_detail'', ''score'', CONVERT(CAST(v.score AS CHAR CHARACTER SET utf8mb4) USING utf8mb4)) AS score,
        v.score_level
    FROM v_student_score_detail v
    WHERE (v_student_no IS NULL OR v.student_no = v_student_no)
      AND (v_course_name IS NULL OR CONVERT(v.course_name USING utf8mb4) LIKE CONCAT(''%'', v_course_name, ''%''))
      AND (v_semester_name IS NULL OR CONVERT(v.semester_name USING utf8mb4) = v_semester_name)
    ORDER BY v.student_no, v.course_name;
END';
PREPARE stmt FROM @sp_query_student_scores;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
