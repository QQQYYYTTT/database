SET NAMES utf8mb4;

-- 说明：
-- 1. 本脚本面向当前实际库 stu_info2026 的现有结构编写；
-- 2. 当前库中 masking_rule_assignment 的角色外键错误指向 sys_role，本脚本先做最小修复；
-- 3. 当前库缺少本任务所需角色与脱敏配置数据，本脚本补齐最小种子数据；
-- 4. 永久数据库对象仅新增/重建以下 3 个：
--    FN_APPLY_MASK
--    FN_MASK_BY_ROLE
--    SP_QUERY_STUDENTS

-- =========================================================
-- 一、最小前置修复：修正错误外键
-- =========================================================

SET @drop_wrong_fk_sql = (
    SELECT IF(
        EXISTS (
            SELECT 1
              FROM information_schema.table_constraints
             WHERE constraint_schema = DATABASE()
               AND table_name = 'masking_rule_assignment'
               AND constraint_name = 'masking_rule_assignment_ibfk_1'
        ),
        'ALTER TABLE masking_rule_assignment DROP FOREIGN KEY masking_rule_assignment_ibfk_1',
        'SELECT 1'
    )
);
PREPARE stmt_drop_wrong_fk FROM @drop_wrong_fk_sql;
EXECUTE stmt_drop_wrong_fk;
DEALLOCATE PREPARE stmt_drop_wrong_fk;

SET @drop_correct_fk_sql = (
    SELECT IF(
        EXISTS (
            SELECT 1
              FROM information_schema.table_constraints
             WHERE constraint_schema = DATABASE()
               AND table_name = 'masking_rule_assignment'
               AND constraint_name = 'fk_masking_rule_assignment_role'
        ),
        'ALTER TABLE masking_rule_assignment DROP FOREIGN KEY fk_masking_rule_assignment_role',
        'SELECT 1'
    )
);
PREPARE stmt_drop_correct_fk FROM @drop_correct_fk_sql;
EXECUTE stmt_drop_correct_fk;
DEALLOCATE PREPARE stmt_drop_correct_fk;

ALTER TABLE masking_rule_assignment
    ADD CONSTRAINT fk_masking_rule_assignment_role
        FOREIGN KEY (role_id) REFERENCES role(id);

-- =========================================================
-- 二、最小种子数据：角色、脱敏类型、敏感字段、策略、分配
-- =========================================================

INSERT INTO role (role_code, role_name, role_description, sort_num, enabled)
SELECT 'SUPER_ADMIN', 'Super Admin', '动态脱敏：超级管理员，可查看原始敏感数据', 101, 1
WHERE NOT EXISTS (SELECT 1 FROM role WHERE role_code = 'SUPER_ADMIN');

INSERT INTO role (role_code, role_name, role_description, sort_num, enabled)
SELECT 'DATA_ADMIN', 'Data Admin', '动态脱敏：数据管理员，可查看原始敏感数据', 102, 1
WHERE NOT EXISTS (SELECT 1 FROM role WHERE role_code = 'DATA_ADMIN');

INSERT INTO role (role_code, role_name, role_description, sort_num, enabled)
SELECT 'TEACHER', 'Teacher', '动态脱敏：教师，按教学场景部分脱敏', 103, 1
WHERE NOT EXISTS (SELECT 1 FROM role WHERE role_code = 'TEACHER');

INSERT INTO role (role_code, role_name, role_description, sort_num, enabled)
SELECT 'ANALYST', 'Analyst', '动态脱敏：分析师，按统计分析场景脱敏/泛化', 104, 1
WHERE NOT EXISTS (SELECT 1 FROM role WHERE role_code = 'ANALYST');

INSERT INTO role (role_code, role_name, role_description, sort_num, enabled)
SELECT 'NORMAL', 'Normal', '动态脱敏：普通用户，使用高强度默认脱敏', 105, 1
WHERE NOT EXISTS (SELECT 1 FROM role WHERE role_code = 'NORMAL');

INSERT INTO role (role_code, role_name, role_description, sort_num, enabled)
SELECT 'STUDENT', 'Student', '动态脱敏：学生查看本人信息与成绩', 106, 1
WHERE NOT EXISTS (SELECT 1 FROM role WHERE role_code = 'STUDENT');

INSERT INTO masking_type_dict (type_code, type_name, param_schema)
VALUES ('NO_MASK', '不脱敏', JSON_OBJECT('description', '返回原始数据'))
ON DUPLICATE KEY UPDATE
    type_name = VALUES(type_name),
    param_schema = VALUES(param_schema);

INSERT INTO masking_type_dict (type_code, type_name, param_schema)
VALUES ('FULL_MASK', '完全遮蔽', JSON_OBJECT('description', '使用星号完全遮蔽'))
ON DUPLICATE KEY UPDATE
    type_name = VALUES(type_name),
    param_schema = VALUES(param_schema);

INSERT INTO masking_type_dict (type_code, type_name, param_schema)
VALUES ('KEEP_PREFIX', '保留前缀', JSON_OBJECT('prefix', 'integer'))
ON DUPLICATE KEY UPDATE
    type_name = VALUES(type_name),
    param_schema = VALUES(param_schema);

INSERT INTO masking_type_dict (type_code, type_name, param_schema)
VALUES ('KEEP_SUFFIX', '保留后缀', JSON_OBJECT('suffix', 'integer'))
ON DUPLICATE KEY UPDATE
    type_name = VALUES(type_name),
    param_schema = VALUES(param_schema);

INSERT INTO masking_type_dict (type_code, type_name, param_schema)
VALUES ('KEEP_PREFIX_SUFFIX', '保留前后缀', JSON_OBJECT('prefix', 'integer', 'suffix', 'integer'))
ON DUPLICATE KEY UPDATE
    type_name = VALUES(type_name),
    param_schema = VALUES(param_schema);

INSERT INTO masking_type_dict (type_code, type_name, param_schema)
VALUES ('EMAIL_MASK', '邮箱脱敏', JSON_OBJECT('description', '保留首字符和域名'))
ON DUPLICATE KEY UPDATE
    type_name = VALUES(type_name),
    param_schema = VALUES(param_schema);

INSERT INTO masking_type_dict (type_code, type_name, param_schema)
VALUES ('ADDRESS_LEVEL', '地址层级脱敏', JSON_OBJECT('level', 'string'))
ON DUPLICATE KEY UPDATE
    type_name = VALUES(type_name),
    param_schema = VALUES(param_schema);

INSERT INTO masking_type_dict (type_code, type_name, param_schema)
VALUES ('GENERALIZATION', '区间泛化', JSON_OBJECT('step', 'number'))
ON DUPLICATE KEY UPDATE
    type_name = VALUES(type_name),
    param_schema = VALUES(param_schema);

INSERT INTO masking_type_dict (type_code, type_name, param_schema)
VALUES ('KEEP_YEAR', '仅保留年份', JSON_OBJECT('description', '日期仅保留年份'))
ON DUPLICATE KEY UPDATE
    type_name = VALUES(type_name),
    param_schema = VALUES(param_schema);

INSERT INTO sensitive_field (table_name, column_name, sensitive_type, sensitive_level, enabled)
SELECT 'v_student_profile', 'name', 'NAME', 'MEDIUM', 1
WHERE NOT EXISTS (
    SELECT 1
      FROM sensitive_field
     WHERE table_name = 'v_student_profile'
       AND column_name = 'name'
);

INSERT INTO sensitive_field (table_name, column_name, sensitive_type, sensitive_level, enabled)
SELECT 'v_student_profile', 'birth_date', 'BIRTH_DATE', 'HIGH', 1
WHERE NOT EXISTS (
    SELECT 1
      FROM sensitive_field
     WHERE table_name = 'v_student_profile'
       AND column_name = 'birth_date'
);

INSERT INTO sensitive_field (table_name, column_name, sensitive_type, sensitive_level, enabled)
SELECT 'v_student_profile', 'phone', 'PHONE', 'HIGH', 1
WHERE NOT EXISTS (
    SELECT 1
      FROM sensitive_field
     WHERE table_name = 'v_student_profile'
       AND column_name = 'phone'
);

INSERT INTO sensitive_field (table_name, column_name, sensitive_type, sensitive_level, enabled)
SELECT 'v_student_profile', 'email', 'EMAIL', 'HIGH', 1
WHERE NOT EXISTS (
    SELECT 1
      FROM sensitive_field
     WHERE table_name = 'v_student_profile'
       AND column_name = 'email'
);

INSERT INTO sensitive_field (table_name, column_name, sensitive_type, sensitive_level, enabled)
SELECT 'v_student_profile', 'id_card', 'ID_CARD', 'HIGH', 1
WHERE NOT EXISTS (
    SELECT 1
      FROM sensitive_field
     WHERE table_name = 'v_student_profile'
       AND column_name = 'id_card'
);

INSERT INTO sensitive_field (table_name, column_name, sensitive_type, sensitive_level, enabled)
SELECT 'v_student_profile', 'address', 'ADDRESS', 'HIGH', 1
WHERE NOT EXISTS (
    SELECT 1
      FROM sensitive_field
     WHERE table_name = 'v_student_profile'
       AND column_name = 'address'
);

INSERT INTO sensitive_field (table_name, column_name, sensitive_type, sensitive_level, enabled)
SELECT 'v_student_profile', 'family_income', 'INCOME', 'HIGH', 1
WHERE NOT EXISTS (
    SELECT 1
      FROM sensitive_field
     WHERE table_name = 'v_student_profile'
       AND column_name = 'family_income'
);

INSERT INTO sensitive_field (table_name, column_name, sensitive_type, sensitive_level, enabled)
SELECT 'v_student_profile', 'bank_card', 'BANK_CARD', 'HIGH', 1
WHERE NOT EXISTS (
    SELECT 1
      FROM sensitive_field
     WHERE table_name = 'v_student_profile'
       AND column_name = 'bank_card'
);

INSERT INTO sensitive_field (table_name, column_name, sensitive_type, sensitive_level, enabled)
SELECT 'v_student_score_detail', 'score', 'SCORE', 'HIGH', 1
WHERE NOT EXISTS (
    SELECT 1
      FROM sensitive_field
     WHERE table_name = 'v_student_score_detail'
       AND column_name = 'score'
);

DROP TEMPORARY TABLE IF EXISTS tmp_masking_policy_seed;
CREATE TEMPORARY TABLE tmp_masking_policy_seed (
    table_name VARCHAR(100) NOT NULL,
    column_name VARCHAR(100) NOT NULL,
    policy_key VARCHAR(100) NOT NULL,
    masking_type VARCHAR(50) NOT NULL,
    params JSON NULL,
    is_default TINYINT NOT NULL
);

INSERT INTO tmp_masking_policy_seed (table_name, column_name, policy_key, masking_type, params, is_default) VALUES
('v_student_profile', 'name', 'DEFAULT_NAME', 'FULL_MASK', JSON_OBJECT(), 1),
('v_student_profile', 'name', 'RAW_NAME', 'NO_MASK', JSON_OBJECT(), 0),
('v_student_profile', 'name', 'KEEP_NAME_1', 'KEEP_PREFIX', JSON_OBJECT('prefix', 1), 0),

('v_student_profile', 'birth_date', 'DEFAULT_BIRTH', 'FULL_MASK', JSON_OBJECT(), 1),
('v_student_profile', 'birth_date', 'RAW_BIRTH', 'NO_MASK', JSON_OBJECT(), 0),
('v_student_profile', 'birth_date', 'KEEP_BIRTH_YEAR', 'KEEP_YEAR', JSON_OBJECT(), 0),

('v_student_profile', 'phone', 'DEFAULT_PHONE', 'FULL_MASK', JSON_OBJECT(), 1),
('v_student_profile', 'phone', 'RAW_PHONE', 'NO_MASK', JSON_OBJECT(), 0),
('v_student_profile', 'phone', 'PHONE_3_4', 'KEEP_PREFIX_SUFFIX', JSON_OBJECT('prefix', 3, 'suffix', 4), 0),

('v_student_profile', 'email', 'DEFAULT_EMAIL', 'FULL_MASK', JSON_OBJECT(), 1),
('v_student_profile', 'email', 'RAW_EMAIL', 'NO_MASK', JSON_OBJECT(), 0),
('v_student_profile', 'email', 'EMAIL_STD', 'EMAIL_MASK', JSON_OBJECT(), 0),

('v_student_profile', 'id_card', 'DEFAULT_ID_CARD', 'FULL_MASK', JSON_OBJECT(), 1),
('v_student_profile', 'id_card', 'RAW_ID_CARD', 'NO_MASK', JSON_OBJECT(), 0),
('v_student_profile', 'id_card', 'ID_CARD_6_4', 'KEEP_PREFIX_SUFFIX', JSON_OBJECT('prefix', 6, 'suffix', 4), 0),

('v_student_profile', 'address', 'DEFAULT_ADDRESS', 'FULL_MASK', JSON_OBJECT(), 1),
('v_student_profile', 'address', 'RAW_ADDRESS', 'NO_MASK', JSON_OBJECT(), 0),
('v_student_profile', 'address', 'ADDRESS_CITY', 'ADDRESS_LEVEL', JSON_OBJECT('level', 'city'), 0),
('v_student_profile', 'address', 'ADDRESS_PROVINCE', 'ADDRESS_LEVEL', JSON_OBJECT('level', 'province'), 0),

('v_student_profile', 'family_income', 'DEFAULT_INCOME', 'FULL_MASK', JSON_OBJECT(), 1),
('v_student_profile', 'family_income', 'RAW_INCOME', 'NO_MASK', JSON_OBJECT(), 0),
('v_student_profile', 'family_income', 'INCOME_10000', 'GENERALIZATION', JSON_OBJECT('step', 10000), 0),

('v_student_profile', 'bank_card', 'DEFAULT_BANK_CARD', 'FULL_MASK', JSON_OBJECT(), 1),
('v_student_profile', 'bank_card', 'RAW_BANK_CARD', 'NO_MASK', JSON_OBJECT(), 0),
('v_student_profile', 'bank_card', 'BANK_CARD_LAST4', 'KEEP_SUFFIX', JSON_OBJECT('suffix', 4), 0),

('v_student_score_detail', 'score', 'DEFAULT_SCORE', 'FULL_MASK', JSON_OBJECT(), 1),
('v_student_score_detail', 'score', 'RAW_SCORE', 'NO_MASK', JSON_OBJECT(), 0),
('v_student_score_detail', 'score', 'SCORE_10_RANGE', 'GENERALIZATION', JSON_OBJECT('step', 10), 0);

INSERT INTO masking_policy (sensitive_field_id, masking_type, params, is_default)
SELECT sf.id, s.masking_type, s.params, s.is_default
  FROM tmp_masking_policy_seed s
  JOIN sensitive_field sf
    ON sf.table_name = s.table_name
   AND sf.column_name = s.column_name
 WHERE NOT EXISTS (
    SELECT 1
      FROM masking_policy mp
     WHERE mp.sensitive_field_id = sf.id
       AND mp.masking_type = s.masking_type
       AND mp.is_default = s.is_default
       AND (
            (mp.params IS NULL AND s.params IS NULL)
         OR (
                mp.params IS NOT NULL
            AND s.params IS NOT NULL
            AND JSON_CONTAINS(mp.params, s.params)
            AND JSON_CONTAINS(s.params, mp.params)
         )
       )
 );

DROP TEMPORARY TABLE IF EXISTS tmp_masking_assignment_seed;
CREATE TEMPORARY TABLE tmp_masking_assignment_seed (
    role_code VARCHAR(50) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    column_name VARCHAR(100) NOT NULL,
    policy_key VARCHAR(100) NOT NULL
);

INSERT INTO tmp_masking_assignment_seed (role_code, table_name, column_name, policy_key) VALUES
('SUPER_ADMIN', 'v_student_profile', 'name', 'RAW_NAME'),
('SUPER_ADMIN', 'v_student_profile', 'birth_date', 'RAW_BIRTH'),
('SUPER_ADMIN', 'v_student_profile', 'phone', 'RAW_PHONE'),
('SUPER_ADMIN', 'v_student_profile', 'email', 'RAW_EMAIL'),
('SUPER_ADMIN', 'v_student_profile', 'id_card', 'RAW_ID_CARD'),
('SUPER_ADMIN', 'v_student_profile', 'address', 'RAW_ADDRESS'),
('SUPER_ADMIN', 'v_student_profile', 'family_income', 'RAW_INCOME'),
('SUPER_ADMIN', 'v_student_profile', 'bank_card', 'RAW_BANK_CARD'),

('DATA_ADMIN', 'v_student_profile', 'name', 'RAW_NAME'),
('DATA_ADMIN', 'v_student_profile', 'birth_date', 'RAW_BIRTH'),
('DATA_ADMIN', 'v_student_profile', 'phone', 'RAW_PHONE'),
('DATA_ADMIN', 'v_student_profile', 'email', 'RAW_EMAIL'),
('DATA_ADMIN', 'v_student_profile', 'id_card', 'RAW_ID_CARD'),
('DATA_ADMIN', 'v_student_profile', 'address', 'RAW_ADDRESS'),
('DATA_ADMIN', 'v_student_profile', 'family_income', 'RAW_INCOME'),
('DATA_ADMIN', 'v_student_profile', 'bank_card', 'RAW_BANK_CARD'),

('TEACHER', 'v_student_profile', 'name', 'KEEP_NAME_1'),
('TEACHER', 'v_student_profile', 'birth_date', 'KEEP_BIRTH_YEAR'),
('TEACHER', 'v_student_profile', 'phone', 'PHONE_3_4'),
('TEACHER', 'v_student_profile', 'email', 'EMAIL_STD'),
('TEACHER', 'v_student_profile', 'id_card', 'ID_CARD_6_4'),
('TEACHER', 'v_student_profile', 'address', 'ADDRESS_CITY'),
('TEACHER', 'v_student_profile', 'family_income', 'INCOME_10000'),
('TEACHER', 'v_student_profile', 'bank_card', 'BANK_CARD_LAST4'),

('ANALYST', 'v_student_profile', 'name', 'KEEP_NAME_1'),
('ANALYST', 'v_student_profile', 'birth_date', 'KEEP_BIRTH_YEAR'),
('ANALYST', 'v_student_profile', 'phone', 'PHONE_3_4'),
('ANALYST', 'v_student_profile', 'email', 'EMAIL_STD'),
('ANALYST', 'v_student_profile', 'id_card', 'DEFAULT_ID_CARD'),
('ANALYST', 'v_student_profile', 'address', 'ADDRESS_PROVINCE'),
('ANALYST', 'v_student_profile', 'family_income', 'INCOME_10000'),
('ANALYST', 'v_student_profile', 'bank_card', 'DEFAULT_BANK_CARD'),

('STUDENT', 'v_student_profile', 'name', 'RAW_NAME'),
('STUDENT', 'v_student_profile', 'birth_date', 'RAW_BIRTH'),
('STUDENT', 'v_student_profile', 'phone', 'RAW_PHONE'),
('STUDENT', 'v_student_profile', 'email', 'RAW_EMAIL'),
('STUDENT', 'v_student_profile', 'id_card', 'RAW_ID_CARD'),
('STUDENT', 'v_student_profile', 'address', 'RAW_ADDRESS'),
('STUDENT', 'v_student_profile', 'family_income', 'RAW_INCOME'),
('STUDENT', 'v_student_profile', 'bank_card', 'RAW_BANK_CARD'),

('SUPER_ADMIN', 'v_student_score_detail', 'score', 'RAW_SCORE'),
('DATA_ADMIN', 'v_student_score_detail', 'score', 'RAW_SCORE'),
('TEACHER', 'v_student_score_detail', 'score', 'RAW_SCORE'),
('ANALYST', 'v_student_score_detail', 'score', 'SCORE_10_RANGE'),
('STUDENT', 'v_student_score_detail', 'score', 'RAW_SCORE');

INSERT INTO masking_rule_assignment (role_id, policy_id, enabled)
SELECT r.id, mp.id, 1
  FROM tmp_masking_assignment_seed a
  JOIN role r
    ON r.role_code = a.role_code
  JOIN sensitive_field sf
    ON sf.table_name = a.table_name
   AND sf.column_name = a.column_name
  JOIN tmp_masking_policy_seed ps
    ON ps.table_name = a.table_name
   AND ps.column_name = a.column_name
   AND ps.policy_key = a.policy_key
  JOIN masking_policy mp
    ON mp.sensitive_field_id = sf.id
   AND mp.masking_type = ps.masking_type
   AND mp.is_default = ps.is_default
   AND (
        (mp.params IS NULL AND ps.params IS NULL)
     OR (
            mp.params IS NOT NULL
        AND ps.params IS NOT NULL
        AND JSON_CONTAINS(mp.params, ps.params)
        AND JSON_CONTAINS(ps.params, mp.params)
     )
   )
 WHERE NOT EXISTS (
    SELECT 1
      FROM masking_rule_assignment mra
      JOIN masking_policy mp2
        ON mp2.id = mra.policy_id
     WHERE mra.role_id = r.id
       AND mra.enabled = 1
       AND mp2.sensitive_field_id = sf.id
 );

DROP TEMPORARY TABLE IF EXISTS tmp_masking_assignment_seed;
DROP TEMPORARY TABLE IF EXISTS tmp_masking_policy_seed;

-- =========================================================
-- 三、仅重建本次目标对象
-- =========================================================

DROP PROCEDURE IF EXISTS SP_QUERY_STUDENTS;
DROP FUNCTION IF EXISTS FN_MASK_BY_ROLE;
DROP FUNCTION IF EXISTS FN_APPLY_MASK;

DELIMITER $$

CREATE FUNCTION FN_APPLY_MASK(
    p_raw_value TEXT,
    p_type_code VARCHAR(50),
    p_params JSON
) RETURNS TEXT
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_len INT DEFAULT 0;
    DECLARE v_prefix INT DEFAULT 0;
    DECLARE v_suffix INT DEFAULT 0;
    DECLARE v_step DECIMAL(18, 2) DEFAULT 10;
    DECLARE v_level VARCHAR(20) DEFAULT 'city';
    DECLARE v_at_pos INT DEFAULT 0;
    DECLARE v_numeric_value DECIMAL(18, 2) DEFAULT 0;
    DECLARE v_start DECIMAL(18, 2) DEFAULT 0;
    DECLARE v_end DECIMAL(18, 2) DEFAULT 0;
    DECLARE v_province_end INT DEFAULT 0;
    DECLARE v_city_end INT DEFAULT 0;
    DECLARE v_email_local TEXT;
    DECLARE v_email_domain TEXT;
    DECLARE v_effective_params JSON;

    IF p_raw_value IS NULL THEN
        RETURN NULL;
    END IF;

    IF p_raw_value = '' THEN
        RETURN '';
    END IF;

    IF p_type_code IS NULL OR TRIM(p_type_code) = '' THEN
        RETURN p_raw_value;
    END IF;

    SET v_effective_params = COALESCE(p_params, JSON_OBJECT());
    SET v_len = CHAR_LENGTH(p_raw_value);

    CASE UPPER(TRIM(p_type_code))
        WHEN 'NO_MASK' THEN
            RETURN p_raw_value;

        WHEN 'NONE' THEN
            RETURN p_raw_value;

        WHEN 'FULL_MASK' THEN
            RETURN REPEAT('*', v_len);

        WHEN 'NULL_MASK' THEN
            RETURN NULL;

        WHEN 'KEEP_PREFIX' THEN
            SET v_prefix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, '$.prefix')), '1') AS SIGNED);
            SET v_prefix = GREATEST(v_prefix, 0);
            SET v_prefix = LEAST(v_prefix, v_len);
            IF v_prefix >= v_len THEN
                RETURN p_raw_value;
            END IF;
            RETURN CONCAT(LEFT(p_raw_value, v_prefix), REPEAT('*', v_len - v_prefix));

        WHEN 'KEEP_SUFFIX' THEN
            SET v_suffix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, '$.suffix')), '4') AS SIGNED);
            SET v_suffix = GREATEST(v_suffix, 0);
            SET v_suffix = LEAST(v_suffix, v_len);
            IF v_suffix >= v_len THEN
                RETURN p_raw_value;
            END IF;
            RETURN CONCAT(REPEAT('*', v_len - v_suffix), RIGHT(p_raw_value, v_suffix));

        WHEN 'KEEP_PREFIX_SUFFIX' THEN
            SET v_prefix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, '$.prefix')), '3') AS SIGNED);
            SET v_suffix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, '$.suffix')), '4') AS SIGNED);
            SET v_prefix = GREATEST(v_prefix, 0);
            SET v_suffix = GREATEST(v_suffix, 0);
            IF v_prefix + v_suffix >= v_len THEN
                RETURN p_raw_value;
            END IF;
            RETURN CONCAT(
                LEFT(p_raw_value, v_prefix),
                REPEAT('*', v_len - v_prefix - v_suffix),
                RIGHT(p_raw_value, v_suffix)
            );

        WHEN 'PARTIAL_MASK' THEN
            SET v_prefix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, '$.prefix_keep')), '1') AS SIGNED);
            SET v_suffix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, '$.suffix_keep')), '1') AS SIGNED);
            SET v_prefix = GREATEST(v_prefix, 0);
            SET v_suffix = GREATEST(v_suffix, 0);
            IF v_prefix + v_suffix >= v_len THEN
                RETURN p_raw_value;
            END IF;
            RETURN CONCAT(
                LEFT(p_raw_value, v_prefix),
                REPEAT('*', v_len - v_prefix - v_suffix),
                RIGHT(p_raw_value, v_suffix)
            );

        WHEN 'EMAIL_MASK' THEN
            SET v_at_pos = LOCATE('@', p_raw_value);
            IF v_at_pos <= 0 THEN
                RETURN REPEAT('*', v_len);
            END IF;

            SET v_email_local = SUBSTRING_INDEX(p_raw_value, '@', 1);
            SET v_email_domain = SUBSTRING_INDEX(p_raw_value, '@', -1);

            IF CHAR_LENGTH(v_email_local) <= 1 THEN
                RETURN CONCAT('*@', v_email_domain);
            END IF;

            RETURN CONCAT(
                LEFT(v_email_local, 1),
                REPEAT('*', CHAR_LENGTH(v_email_local) - 1),
                '@',
                v_email_domain
            );

        WHEN 'ADDRESS_LEVEL' THEN
            SET v_level = LOWER(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, '$.level')), 'city'));

            IF LOCATE('特别行政区', p_raw_value) > 0 THEN
                SET v_province_end = LOCATE('特别行政区', p_raw_value) + CHAR_LENGTH('特别行政区') - 1;
            ELSEIF LOCATE('自治区', p_raw_value) > 0 THEN
                SET v_province_end = LOCATE('自治区', p_raw_value) + CHAR_LENGTH('自治区') - 1;
            ELSEIF LOCATE('省', p_raw_value) > 0 THEN
                SET v_province_end = LOCATE('省', p_raw_value);
            ELSEIF LOCATE('市', p_raw_value) > 0 THEN
                SET v_province_end = LOCATE('市', p_raw_value);
            END IF;

            IF v_level = 'province' THEN
                IF v_province_end > 0 THEN
                    RETURN CONCAT(LEFT(p_raw_value, v_province_end), '**');
                END IF;
                IF v_len <= 2 THEN
                    RETURN p_raw_value;
                END IF;
                RETURN CONCAT(LEFT(p_raw_value, 2), '**');
            END IF;

            IF v_province_end > 0 AND v_province_end < v_len THEN
                IF LOCATE('市', SUBSTRING(p_raw_value, v_province_end + 1)) > 0 THEN
                    SET v_city_end = v_province_end + LOCATE('市', SUBSTRING(p_raw_value, v_province_end + 1));
                ELSEIF LOCATE('州', SUBSTRING(p_raw_value, v_province_end + 1)) > 0 THEN
                    SET v_city_end = v_province_end + LOCATE('州', SUBSTRING(p_raw_value, v_province_end + 1));
                ELSEIF LOCATE('盟', SUBSTRING(p_raw_value, v_province_end + 1)) > 0 THEN
                    SET v_city_end = v_province_end + LOCATE('盟', SUBSTRING(p_raw_value, v_province_end + 1));
                END IF;
            END IF;

            IF v_city_end = 0 AND LOCATE('市', p_raw_value) > 0 THEN
                SET v_city_end = LOCATE('市', p_raw_value);
            END IF;

            IF v_city_end > 0 THEN
                RETURN CONCAT(LEFT(p_raw_value, v_city_end), '***');
            END IF;

            IF v_len <= 2 THEN
                RETURN p_raw_value;
            END IF;
            RETURN CONCAT(LEFT(p_raw_value, 2), '***');

        WHEN 'GENERALIZATION' THEN
            SET v_step = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, '$.step')), '10') AS DECIMAL(18, 2));
            IF v_step IS NULL OR v_step <= 0 THEN
                SET v_step = 10;
            END IF;

            IF NOT REGEXP_LIKE(TRIM(p_raw_value), '^-?[0-9]+(\\.[0-9]+)?$') THEN
                RETURN p_raw_value;
            END IF;

            SET v_numeric_value = CAST(TRIM(p_raw_value) AS DECIMAL(18, 2));
            SET v_start = FLOOR(v_numeric_value / v_step) * v_step;
            SET v_end = v_start + v_step;

            RETURN CONCAT(
                TRIM(TRAILING '.' FROM TRIM(TRAILING '0' FROM CAST(v_start AS CHAR))),
                '-',
                TRIM(TRAILING '.' FROM TRIM(TRAILING '0' FROM CAST(v_end AS CHAR)))
            );

        WHEN 'RANGE_MASK' THEN
            SET v_step = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(v_effective_params, '$.range_size')), '10') AS DECIMAL(18, 2));
            IF v_step IS NULL OR v_step <= 0 THEN
                SET v_step = 10;
            END IF;

            IF NOT REGEXP_LIKE(TRIM(p_raw_value), '^-?[0-9]+(\\.[0-9]+)?$') THEN
                RETURN p_raw_value;
            END IF;

            SET v_numeric_value = CAST(TRIM(p_raw_value) AS DECIMAL(18, 2));
            SET v_start = FLOOR(v_numeric_value / v_step) * v_step;
            SET v_end = v_start + v_step;

            RETURN CONCAT(
                TRIM(TRAILING '.' FROM TRIM(TRAILING '0' FROM CAST(v_start AS CHAR))),
                '-',
                TRIM(TRAILING '.' FROM TRIM(TRAILING '0' FROM CAST(v_end AS CHAR)))
            );

        WHEN 'KEEP_YEAR' THEN
            IF REGEXP_LIKE(p_raw_value, '^[0-9]{4}') THEN
                RETURN CONCAT(LEFT(p_raw_value, 4), '-**-**');
            END IF;
            RETURN p_raw_value;

        WHEN 'HASH_MASK' THEN
            RETURN LEFT(MD5(p_raw_value), 12);

        ELSE
            RETURN p_raw_value;
    END CASE;
END$$

CREATE FUNCTION FN_MASK_BY_ROLE(
    p_role_id BIGINT,
    p_object_name VARCHAR(100),
    p_column_name VARCHAR(100),
    p_raw_value TEXT
) RETURNS TEXT
READS SQL DATA
BEGIN
    DECLARE v_sensitive_field_id BIGINT DEFAULT NULL;
    DECLARE v_masking_type VARCHAR(50) DEFAULT NULL;
    DECLARE v_params JSON DEFAULT NULL;

    IF p_raw_value IS NULL THEN
        RETURN NULL;
    END IF;

    IF p_object_name IS NULL OR TRIM(p_object_name) = '' OR p_column_name IS NULL OR TRIM(p_column_name) = '' THEN
        RETURN p_raw_value;
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM role r
         WHERE r.id = p_role_id
           AND r.enabled = 1
    ) THEN
        RETURN p_raw_value;
    END IF;

    SELECT sf.id
      INTO v_sensitive_field_id
      FROM sensitive_field sf
     WHERE sf.table_name = p_object_name
       AND sf.column_name = p_column_name
       AND sf.enabled = 1
     LIMIT 1;

    IF v_sensitive_field_id IS NULL THEN
        RETURN p_raw_value;
    END IF;

    SELECT mp.masking_type, mp.params
      INTO v_masking_type, v_params
      FROM masking_rule_assignment mra
      JOIN role r
        ON r.id = mra.role_id
       AND r.enabled = 1
      JOIN masking_policy mp
        ON mp.id = mra.policy_id
       AND mp.sensitive_field_id = v_sensitive_field_id
     WHERE mra.role_id = p_role_id
       AND mra.enabled = 1
     ORDER BY mra.id DESC, mp.id DESC
     LIMIT 1;

    IF v_masking_type IS NULL THEN
        SELECT mp.masking_type, mp.params
          INTO v_masking_type, v_params
          FROM masking_policy mp
         WHERE mp.sensitive_field_id = v_sensitive_field_id
           AND mp.is_default = 1
         ORDER BY mp.id DESC
         LIMIT 1;
    END IF;

    IF v_masking_type IS NULL THEN
        RETURN p_raw_value;
    END IF;

    RETURN FN_APPLY_MASK(p_raw_value, v_masking_type, v_params);
END$$

CREATE PROCEDURE SP_QUERY_STUDENTS(
    IN p_user_id BIGINT,
    IN p_role_code VARCHAR(50),
    IN p_student_no VARCHAR(30),
    IN p_name VARCHAR(50),
    IN p_class_name VARCHAR(100)
)
BEGIN
    DECLARE v_role_id BIGINT DEFAULT NULL;
    DECLARE v_role_code VARCHAR(50);
    DECLARE v_student_no VARCHAR(30);
    DECLARE v_name VARCHAR(50);
    DECLARE v_class_name VARCHAR(100);
    DECLARE v_error_message VARCHAR(255);

    SET v_role_code = NULLIF(TRIM(p_role_code), '');
    SET v_student_no = NULLIF(TRIM(p_student_no), '');
    SET v_name = NULLIF(TRIM(p_name), '');
    SET v_class_name = NULLIF(TRIM(p_class_name), '');

    IF v_role_code IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '角色编码不能为空';
    END IF;

    SELECT r.id
      INTO v_role_id
      FROM role r
     WHERE r.role_code = v_role_code
       AND r.enabled = 1
     LIMIT 1;

    IF v_role_id IS NULL THEN
        SET v_error_message = CONCAT('角色不存在或已禁用: ', v_role_code);
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = v_error_message;
    END IF;

    SELECT
        v.student_id,
        v.student_no,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'name', v.name) AS name,
        v.gender,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'birth_date', DATE_FORMAT(v.birth_date, '%Y-%m-%d')) AS birth_date,
        v.status,
        v.class_name,
        v.grade_name,
        v.entry_year,
        v.major_name,
        v.college_name,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'phone', v.phone) AS phone,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'email', v.email) AS email,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'id_card', v.id_card) AS id_card,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'address', v.address) AS address,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'family_income', CAST(v.family_income AS CHAR)) AS family_income,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'bank_card', v.bank_card) AS bank_card
    FROM v_student_profile v
    WHERE (v_student_no IS NULL OR v.student_no = v_student_no)
      AND (v_name IS NULL OR v.name LIKE CONCAT('%', v_name, '%'))
      AND (v_class_name IS NULL OR v.class_name = v_class_name)
    ORDER BY v.student_no;

    -- p_user_id 保留给后续访问审计，本阶段不写 access_log。
END$$

DELIMITER ;

-- =========================================================
-- 四、验收测试语句
-- 说明：包含一个非法角色测试，会按预期返回 45000 异常。
-- =========================================================

-- 1. 角色全量查询
-- CALL SP_QUERY_STUDENTS(1, 'SUPER_ADMIN', NULL, NULL, NULL);
-- CALL SP_QUERY_STUDENTS(3, 'DATA_ADMIN', NULL, NULL, NULL);
-- CALL SP_QUERY_STUDENTS(5, 'TEACHER', NULL, NULL, NULL);
-- CALL SP_QUERY_STUDENTS(6, 'ANALYST', NULL, NULL, NULL);
-- CALL SP_QUERY_STUDENTS(8, 'NORMAL', NULL, NULL, NULL);

-- 2. 按学号精确查询
-- CALL SP_QUERY_STUDENTS(5, 'TEACHER', '2023001', NULL, NULL);

-- 3. 按姓名模糊查询
-- CALL SP_QUERY_STUDENTS(5, 'TEACHER', NULL, '张', NULL);

-- 4. 按班级精确查询
-- CALL SP_QUERY_STUDENTS(5, 'TEACHER', NULL, NULL, '网安2301班');

-- 5. 非法角色编码测试
-- CALL SP_QUERY_STUDENTS(5, 'NOT_EXISTS_ROLE', NULL, NULL, NULL);

-- 6. 直接验证 FN_APPLY_MASK 的各类脱敏
-- SELECT FN_APPLY_MASK('13800000001', 'NO_MASK', JSON_OBJECT()) AS no_mask_result;
-- SELECT FN_APPLY_MASK('13800000001', 'FULL_MASK', JSON_OBJECT()) AS full_mask_result;
-- SELECT FN_APPLY_MASK('张伟', 'KEEP_PREFIX', JSON_OBJECT('prefix', 1)) AS keep_prefix_result;
-- SELECT FN_APPLY_MASK('6222020000000001', 'KEEP_SUFFIX', JSON_OBJECT('suffix', 4)) AS keep_suffix_result;
-- SELECT FN_APPLY_MASK('13800000001', 'KEEP_PREFIX_SUFFIX', JSON_OBJECT('prefix', 3, 'suffix', 4)) AS keep_prefix_suffix_result;
-- SELECT FN_APPLY_MASK('zhangwei@edu.com', 'EMAIL_MASK', JSON_OBJECT()) AS email_mask_result;
-- SELECT FN_APPLY_MASK('成都高新区', 'ADDRESS_LEVEL', JSON_OBJECT('level', 'province')) AS address_province_result;
-- SELECT FN_APPLY_MASK('成都高新区', 'ADDRESS_LEVEL', JSON_OBJECT('level', 'city')) AS address_city_result;
-- SELECT FN_APPLY_MASK('120000', 'GENERALIZATION', JSON_OBJECT('step', 10000)) AS generalization_result;
-- SELECT FN_APPLY_MASK('2005-03-12', 'KEEP_YEAR', JSON_OBJECT()) AS keep_year_result;

-- 7. 直接验证 FN_MASK_BY_ROLE 同一手机号的不同角色结果
-- SELECT
--     FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'SUPER_ADMIN'), 'v_student_profile', 'phone', '13800000001') AS super_admin_phone,
--     FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'DATA_ADMIN'), 'v_student_profile', 'phone', '13800000001') AS data_admin_phone,
--     FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'TEACHER'), 'v_student_profile', 'phone', '13800000001') AS teacher_phone,
--     FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'ANALYST'), 'v_student_profile', 'phone', '13800000001') AS analyst_phone,
--     FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'NORMAL'), 'v_student_profile', 'phone', '13800000001') AS normal_phone,
--     FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'ADMIN'), 'v_student_profile', 'phone', '13800000001') AS admin_default_fallback_phone,
--     FN_MASK_BY_ROLE((SELECT id FROM role WHERE role_code = 'TEACHER'), 'v_student_profile', 'gender', 'M') AS no_rule_returns_raw_value;

-- 预期差异说明
-- SUPER_ADMIN：敏感字段返回原始值。
-- DATA_ADMIN：敏感字段返回原始值。
-- TEACHER：姓名保留姓氏，生日保留年份，手机号前3后4，邮箱保留首字符和域名，身份证前6后4，地址保留到市级/城市前缀，收入按 10000 区间泛化，银行卡保留后4位。
-- ANALYST：姓名保留姓氏，生日保留年份，手机号前3后4，邮箱保留首字符和域名，身份证完全遮蔽，地址保留到省级/更粗粒度前缀，收入按 10000 区间泛化，银行卡完全遮蔽。
-- NORMAL：无专属策略，走字段默认策略，表现为高强度遮蔽。
-- ADMIN：当前无专属策略，可用于验证“角色无专属策略时回退默认策略”。
-- 无字段配置：当前实现返回原值，例如 gender。
