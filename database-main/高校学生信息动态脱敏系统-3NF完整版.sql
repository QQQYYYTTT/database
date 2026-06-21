SET NAMES utf8mb4;

-- 可按需取消注释
-- CREATE DATABASE IF NOT EXISTS student_masking_system DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE student_masking_system;

SET FOREIGN_KEY_CHECKS = 0;

DROP TRIGGER IF EXISTS trg_masking_policy_default_ins;
DROP TRIGGER IF EXISTS trg_masking_policy_default_upd;
DROP TRIGGER IF EXISTS trg_masking_assignment_unique_ins;
DROP TRIGGER IF EXISTS trg_masking_assignment_unique_upd;
DROP TRIGGER IF EXISTS trg_policy_change_log_ins;
DROP TRIGGER IF EXISTS trg_policy_change_log_upd;
DROP TRIGGER IF EXISTS trg_policy_change_log_del;

DROP PROCEDURE IF EXISTS SP_DETECT_ABNORMAL;
DROP PROCEDURE IF EXISTS SP_QUERY_STUDENT_SCORES;
DROP PROCEDURE IF EXISTS SP_QUERY_STUDENTS;

DROP FUNCTION IF EXISTS FN_MASK_BY_ROLE;
DROP FUNCTION IF EXISTS FN_APPLY_MASK;

DROP VIEW IF EXISTS v_masking_config;
DROP VIEW IF EXISTS v_student_score_detail;
DROP VIEW IF EXISTS v_student_profile;

DROP TABLE IF EXISTS abnormal_access;
DROP TABLE IF EXISTS rule_change_log;
DROP TABLE IF EXISTS access_log;
DROP TABLE IF EXISTS masking_rule_assignment;
DROP TABLE IF EXISTS masking_policy;
DROP TABLE IF EXISTS masking_type_dict;
DROP TABLE IF EXISTS sensitive_field;
DROP TABLE IF EXISTS student_score;
DROP TABLE IF EXISTS semester_info;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS student_sensitive;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS class_info;
DROP TABLE IF EXISTS grade_info;
DROP TABLE IF EXISTS major;
DROP TABLE IF EXISTS college;
DROP TABLE IF EXISTS sys_role_permission;
DROP TABLE IF EXISTS sys_user_role;
DROP TABLE IF EXISTS sys_permission;
DROP TABLE IF EXISTS sys_role;
DROP TABLE IF EXISTS sys_user;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE sys_user (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username        VARCHAR(50) NOT NULL UNIQUE COMMENT '登录用户名',
    password        VARCHAR(255) NOT NULL COMMENT '密码哈希',
    real_name       VARCHAR(50) NOT NULL COMMENT '真实姓名',
    status          TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用，0禁用',
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT chk_sys_user_status CHECK (status IN (0, 1))
) COMMENT='系统用户表';

CREATE TABLE sys_role (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '角色ID',
    role_name       VARCHAR(50) NOT NULL COMMENT '角色名称',
    role_code       VARCHAR(50) NOT NULL UNIQUE COMMENT '角色编码',
    description     VARCHAR(255) COMMENT '角色说明',
    status          TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用，0禁用',
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT chk_sys_role_status CHECK (status IN (0, 1))
) COMMENT='系统角色表';

CREATE TABLE sys_permission (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '权限ID',
    permission_name     VARCHAR(100) NOT NULL COMMENT '权限名称',
    permission_code     VARCHAR(100) NOT NULL UNIQUE COMMENT '权限编码',
    permission_type     VARCHAR(20) NOT NULL COMMENT '权限类型：MENU/API/DATA',
    parent_id           BIGINT NULL COMMENT '父级权限ID',
    sort_order          INT NOT NULL DEFAULT 0 COMMENT '排序号',
    status              TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用，0禁用',
    create_time         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    CONSTRAINT chk_sys_permission_type CHECK (permission_type IN ('MENU', 'API', 'DATA')),
    CONSTRAINT chk_sys_permission_status CHECK (status IN (0, 1))
) COMMENT='系统权限表';

CREATE TABLE sys_user_role (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id         BIGINT NOT NULL COMMENT '用户ID',
    role_id         BIGINT NOT NULL COMMENT '角色ID',
    UNIQUE KEY uk_user_role (user_id, role_id),
    CONSTRAINT fk_sys_user_role_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_sys_user_role_role FOREIGN KEY (role_id) REFERENCES sys_role(id) ON DELETE CASCADE
) COMMENT='用户角色关联表';

CREATE TABLE sys_role_permission (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    role_id         BIGINT NOT NULL COMMENT '角色ID',
    permission_id   BIGINT NOT NULL COMMENT '权限ID',
    UNIQUE KEY uk_role_permission (role_id, permission_id),
    CONSTRAINT fk_sys_role_permission_role FOREIGN KEY (role_id) REFERENCES sys_role(id) ON DELETE CASCADE,
    CONSTRAINT fk_sys_role_permission_permission FOREIGN KEY (permission_id) REFERENCES sys_permission(id) ON DELETE CASCADE
) COMMENT='角色权限关联表';

CREATE TABLE college (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '学院ID',
    college_code    VARCHAR(30) NOT NULL UNIQUE COMMENT '学院编码',
    college_name    VARCHAR(100) NOT NULL UNIQUE COMMENT '学院名称',
    status          TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用，0停用',
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT chk_college_status CHECK (status IN (0, 1))
) COMMENT='学院表';

CREATE TABLE major (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '专业ID',
    college_id      BIGINT NOT NULL COMMENT '所属学院ID',
    major_code      VARCHAR(30) NOT NULL UNIQUE COMMENT '专业编码',
    major_name      VARCHAR(100) NOT NULL COMMENT '专业名称',
    status          TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用，0停用',
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_major_college_name (college_id, major_name),
    CONSTRAINT fk_major_college FOREIGN KEY (college_id) REFERENCES college(id),
    CONSTRAINT chk_major_status CHECK (status IN (0, 1))
) COMMENT='专业表';

CREATE TABLE grade_info (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '年级ID',
    grade_name      VARCHAR(30) NOT NULL UNIQUE COMMENT '年级名称',
    entry_year      INT NOT NULL UNIQUE COMMENT '入学年份',
    status          TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用，0停用',
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT chk_grade_status CHECK (status IN (0, 1))
) COMMENT='年级表';

CREATE TABLE class_info (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '班级ID',
    major_id        BIGINT NOT NULL COMMENT '所属专业ID',
    grade_id        BIGINT NOT NULL COMMENT '所属年级ID',
    class_code      VARCHAR(30) NOT NULL UNIQUE COMMENT '班级编码',
    class_name      VARCHAR(100) NOT NULL COMMENT '班级名称',
    status          TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用，0停用',
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_class_major_grade_name (major_id, grade_id, class_name),
    CONSTRAINT fk_class_major FOREIGN KEY (major_id) REFERENCES major(id),
    CONSTRAINT fk_class_grade FOREIGN KEY (grade_id) REFERENCES grade_info(id),
    CONSTRAINT chk_class_status CHECK (status IN (0, 1))
) COMMENT='班级表';

CREATE TABLE student (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '学生ID',
    class_id        BIGINT NOT NULL COMMENT '班级ID',
    student_no      VARCHAR(30) NOT NULL UNIQUE COMMENT '学号',
    name            VARCHAR(50) NOT NULL COMMENT '姓名',
    gender          CHAR(1) DEFAULT 'U' COMMENT '性别：M/F/U',
    birth_date      DATE COMMENT '出生日期',
    status          TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0在读，1休学，2毕业',
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT fk_student_class FOREIGN KEY (class_id) REFERENCES class_info(id),
    CONSTRAINT chk_student_gender CHECK (gender IN ('M', 'F', 'U')),
    CONSTRAINT chk_student_status CHECK (status IN (0, 1, 2))
) COMMENT='学生基本信息表';

CREATE TABLE student_sensitive (
    student_id          BIGINT PRIMARY KEY COMMENT '学生ID',
    phone               VARCHAR(20) COMMENT '手机号',
    email               VARCHAR(100) COMMENT '邮箱',
    id_card             VARCHAR(30) COMMENT '身份证号',
    address             VARCHAR(255) COMMENT '家庭住址',
    family_income       DECIMAL(10, 2) COMMENT '家庭年收入',
    bank_card           VARCHAR(30) COMMENT '银行卡号',
    create_time         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT fk_student_sensitive_student FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE
) COMMENT='学生敏感信息表';

CREATE TABLE course (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '课程ID',
    course_code     VARCHAR(30) NOT NULL UNIQUE COMMENT '课程编码',
    course_name     VARCHAR(100) NOT NULL UNIQUE COMMENT '课程名称',
    credit          DECIMAL(4, 1) COMMENT '学分',
    status          TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用，0停用',
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT chk_course_status CHECK (status IN (0, 1))
) COMMENT='课程表';

CREATE TABLE semester_info (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '学期ID',
    school_year     VARCHAR(20) NOT NULL COMMENT '学年',
    term_no         TINYINT NOT NULL COMMENT '学期号：1/2/3',
    semester_name   VARCHAR(30) NOT NULL UNIQUE COMMENT '学期名称',
    status          TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用，0停用',
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_semester_year_term (school_year, term_no),
    CONSTRAINT chk_semester_term CHECK (term_no IN (1, 2, 3)),
    CONSTRAINT chk_semester_status CHECK (status IN (0, 1))
) COMMENT='学期表';

CREATE TABLE student_score (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '成绩记录ID',
    student_id      BIGINT NOT NULL COMMENT '学生ID',
    course_id       BIGINT NOT NULL COMMENT '课程ID',
    semester_id     BIGINT NOT NULL COMMENT '学期ID',
    score           DECIMAL(5, 2) COMMENT '分数',
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_student_course_semester (student_id, course_id, semester_id),
    CONSTRAINT fk_student_score_student FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE,
    CONSTRAINT fk_student_score_course FOREIGN KEY (course_id) REFERENCES course(id),
    CONSTRAINT fk_student_score_semester FOREIGN KEY (semester_id) REFERENCES semester_info(id),
    CONSTRAINT chk_student_score_range CHECK (score >= 0 AND score <= 100)
) COMMENT='学生成绩表';

CREATE TABLE sensitive_field (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '敏感字段ID',
    entity_name         VARCHAR(50) NOT NULL COMMENT '业务实体标签',
    object_name         VARCHAR(100) NOT NULL COMMENT '目标对象名，可为表或视图',
    object_type         VARCHAR(20) NOT NULL COMMENT '对象类型：TABLE/VIEW',
    column_name         VARCHAR(100) NOT NULL COMMENT '字段名',
    column_comment      VARCHAR(255) COMMENT '字段中文说明',
    sensitive_type      VARCHAR(50) NOT NULL COMMENT '敏感类型',
    sensitive_level     VARCHAR(20) NOT NULL COMMENT '敏感级别：LOW/MEDIUM/HIGH',
    identify_method     VARCHAR(50) NOT NULL DEFAULT 'MANUAL' COMMENT '识别方式：MANUAL/FIELD_NAME/REGEX',
    enabled             TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用：1启用，0停用',
    create_time         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_sensitive_object_column (object_name, column_name),
    CONSTRAINT chk_sensitive_object_type CHECK (object_type IN ('TABLE', 'VIEW')),
    CONSTRAINT chk_sensitive_level CHECK (sensitive_level IN ('LOW', 'MEDIUM', 'HIGH')),
    CONSTRAINT chk_sensitive_identify_method CHECK (identify_method IN ('MANUAL', 'FIELD_NAME', 'REGEX')),
    CONSTRAINT chk_sensitive_enabled CHECK (enabled IN (0, 1))
) COMMENT='敏感字段元数据表';

CREATE TABLE masking_type_dict (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '脱敏方式ID',
    type_code           VARCHAR(50) NOT NULL UNIQUE COMMENT '脱敏方式编码',
    type_name           VARCHAR(100) NOT NULL COMMENT '脱敏方式名称',
    description         VARCHAR(255) COMMENT '脱敏方式说明',
    param_schema        JSON COMMENT '参数结构说明',
    default_params      JSON COMMENT '默认参数',
    status              TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用，0停用',
    create_time         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT chk_masking_type_status CHECK (status IN (0, 1))
) COMMENT='脱敏方式字典表';

CREATE TABLE masking_policy (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '策略ID',
    sensitive_field_id  BIGINT NOT NULL COMMENT '敏感字段ID',
    masking_type_id     BIGINT NOT NULL COMMENT '脱敏方式ID',
    policy_name         VARCHAR(100) NOT NULL COMMENT '策略名称',
    params              JSON COMMENT '策略参数',
    is_default          TINYINT NOT NULL DEFAULT 0 COMMENT '是否为默认策略：1是，0否',
    status              TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用，0停用',
    description         VARCHAR(255) COMMENT '策略说明',
    create_by           BIGINT NULL COMMENT '创建人ID',
    update_by           BIGINT NULL COMMENT '更新人ID',
    create_time         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_masking_policy_field_name (sensitive_field_id, policy_name),
    CONSTRAINT fk_masking_policy_field FOREIGN KEY (sensitive_field_id) REFERENCES sensitive_field(id) ON DELETE RESTRICT,
    CONSTRAINT fk_masking_policy_type FOREIGN KEY (masking_type_id) REFERENCES masking_type_dict(id) ON DELETE RESTRICT,
    CONSTRAINT fk_masking_policy_create_by FOREIGN KEY (create_by) REFERENCES sys_user(id) ON DELETE SET NULL,
    CONSTRAINT fk_masking_policy_update_by FOREIGN KEY (update_by) REFERENCES sys_user(id) ON DELETE SET NULL,
    CONSTRAINT chk_masking_policy_default CHECK (is_default IN (0, 1)),
    CONSTRAINT chk_masking_policy_status CHECK (status IN (0, 1))
) COMMENT='脱敏策略表';

CREATE TABLE masking_rule_assignment (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分配ID',
    role_id             BIGINT NOT NULL COMMENT '角色ID',
    policy_id           BIGINT NOT NULL COMMENT '策略ID',
    enabled             TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用：1启用，0停用',
    create_time         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_masking_assignment_role_policy (role_id, policy_id),
    CONSTRAINT fk_masking_assignment_role FOREIGN KEY (role_id) REFERENCES sys_role(id) ON DELETE CASCADE,
    CONSTRAINT fk_masking_assignment_policy FOREIGN KEY (policy_id) REFERENCES masking_policy(id) ON DELETE CASCADE,
    CONSTRAINT chk_masking_assignment_enabled CHECK (enabled IN (0, 1))
) COMMENT='角色脱敏策略分配表';

CREATE TABLE access_log (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '访问日志ID',
    user_id             BIGINT NULL COMMENT '用户ID',
    username_snapshot   VARCHAR(50) COMMENT '用户名快照',
    role_snapshot       VARCHAR(50) COMMENT '角色编码快照',
    operation_type      VARCHAR(50) NOT NULL COMMENT '操作类型',
    target_object       VARCHAR(100) NOT NULL COMMENT '访问对象',
    query_condition     VARCHAR(500) COMMENT '查询条件快照',
    sensitive_columns   VARCHAR(500) COMMENT '涉及敏感字段',
    masking_applied     TINYINT NOT NULL DEFAULT 0 COMMENT '是否应用脱敏',
    result_count        INT NOT NULL DEFAULT 0 COMMENT '返回记录数',
    access_time         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '访问时间',
    CONSTRAINT fk_access_log_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE SET NULL,
    CONSTRAINT chk_access_log_masking_applied CHECK (masking_applied IN (0, 1))
) COMMENT='敏感数据访问日志表';

CREATE TABLE rule_change_log (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '规则变更日志ID',
    policy_id           BIGINT NULL COMMENT '策略ID',
    operator_id         BIGINT NULL COMMENT '操作人ID',
    operator_name       VARCHAR(50) COMMENT '操作人姓名快照',
    operation_type      VARCHAR(20) NOT NULL COMMENT '操作类型：INSERT/UPDATE/DELETE',
    before_content      JSON COMMENT '变更前内容',
    after_content       JSON COMMENT '变更后内容',
    operate_time        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    CONSTRAINT fk_rule_change_policy FOREIGN KEY (policy_id) REFERENCES masking_policy(id) ON DELETE SET NULL,
    CONSTRAINT fk_rule_change_operator FOREIGN KEY (operator_id) REFERENCES sys_user(id) ON DELETE SET NULL
) COMMENT='脱敏策略变更日志表';

CREATE TABLE abnormal_access (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '异常访问ID',
    user_id             BIGINT NULL COMMENT '用户ID',
    username_snapshot   VARCHAR(50) COMMENT '用户名快照',
    role_snapshot       VARCHAR(50) COMMENT '角色快照',
    anomaly_type        VARCHAR(50) NOT NULL COMMENT '异常类型',
    description         VARCHAR(500) NOT NULL COMMENT '异常描述',
    detection_window    VARCHAR(100) COMMENT '检测时间窗口',
    related_count       INT NOT NULL DEFAULT 0 COMMENT '相关访问次数',
    discovered_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发现时间',
    status              VARCHAR(20) NOT NULL DEFAULT 'OPEN' COMMENT '处理状态：OPEN/CLOSED',
    CONSTRAINT fk_abnormal_access_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE SET NULL,
    CONSTRAINT chk_abnormal_access_status CHECK (status IN ('OPEN', 'CLOSED'))
) COMMENT='异常访问记录表';

DELIMITER $$

CREATE TRIGGER trg_masking_policy_default_ins
BEFORE INSERT ON masking_policy
FOR EACH ROW
BEGIN
    DECLARE v_count INT DEFAULT 0;

    IF NEW.is_default = 1 THEN
        SELECT COUNT(*)
          INTO v_count
          FROM masking_policy
         WHERE sensitive_field_id = NEW.sensitive_field_id
           AND is_default = 1;

        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = '同一敏感字段只能存在一条默认脱敏策略';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_masking_policy_default_upd
BEFORE UPDATE ON masking_policy
FOR EACH ROW
BEGIN
    DECLARE v_count INT DEFAULT 0;

    IF NEW.is_default = 1 THEN
        SELECT COUNT(*)
          INTO v_count
          FROM masking_policy
         WHERE sensitive_field_id = NEW.sensitive_field_id
           AND is_default = 1
           AND id <> NEW.id;

        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = '同一敏感字段只能存在一条默认脱敏策略';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_masking_assignment_unique_ins
BEFORE INSERT ON masking_rule_assignment
FOR EACH ROW
BEGIN
    DECLARE v_field_id BIGINT;
    DECLARE v_count INT DEFAULT 0;

    SELECT sensitive_field_id
      INTO v_field_id
      FROM masking_policy
     WHERE id = NEW.policy_id;

    SELECT COUNT(*)
      INTO v_count
      FROM masking_rule_assignment mra
      JOIN masking_policy mp ON mp.id = mra.policy_id
     WHERE mra.role_id = NEW.role_id
       AND mp.sensitive_field_id = v_field_id
       AND mra.enabled = 1;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '同一角色对同一敏感字段只能分配一条启用策略';
    END IF;
END$$

CREATE TRIGGER trg_masking_assignment_unique_upd
BEFORE UPDATE ON masking_rule_assignment
FOR EACH ROW
BEGIN
    DECLARE v_field_id BIGINT;
    DECLARE v_count INT DEFAULT 0;

    SELECT sensitive_field_id
      INTO v_field_id
      FROM masking_policy
     WHERE id = NEW.policy_id;

    SELECT COUNT(*)
      INTO v_count
      FROM masking_rule_assignment mra
      JOIN masking_policy mp ON mp.id = mra.policy_id
     WHERE mra.role_id = NEW.role_id
       AND mp.sensitive_field_id = v_field_id
       AND mra.enabled = 1
       AND mra.id <> NEW.id;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '同一角色对同一敏感字段只能分配一条启用策略';
    END IF;
END$$

CREATE FUNCTION FN_APPLY_MASK(
    p_raw_value TEXT,
    p_type_code VARCHAR(50),
    p_params JSON
) RETURNS TEXT
READS SQL DATA
BEGIN
    DECLARE v_len INT DEFAULT 0;
    DECLARE v_prefix INT DEFAULT 0;
    DECLARE v_suffix INT DEFAULT 0;
    DECLARE v_step DECIMAL(18, 2) DEFAULT 0;
    DECLARE v_level VARCHAR(20);
    DECLARE v_email_local VARCHAR(255);
    DECLARE v_email_domain VARCHAR(255);
    DECLARE v_start DECIMAL(18, 2);
    DECLARE v_end DECIMAL(18, 2);

    IF p_raw_value IS NULL THEN
        RETURN NULL;
    END IF;

    SET v_len = CHAR_LENGTH(p_raw_value);

    CASE p_type_code
        WHEN 'NO_MASK' THEN
            RETURN p_raw_value;

        WHEN 'FULL_MASK' THEN
            RETURN REPEAT('*', GREATEST(v_len, 1));

        WHEN 'KEEP_PREFIX' THEN
            SET v_prefix = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_params, '$.prefix')) AS UNSIGNED), 1);
            IF v_len <= v_prefix THEN
                RETURN p_raw_value;
            END IF;
            RETURN CONCAT(LEFT(p_raw_value, v_prefix), REPEAT('*', v_len - v_prefix));

        WHEN 'KEEP_SUFFIX' THEN
            SET v_suffix = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_params, '$.suffix')) AS UNSIGNED), 4);
            IF v_len <= v_suffix THEN
                RETURN p_raw_value;
            END IF;
            RETURN CONCAT(REPEAT('*', v_len - v_suffix), RIGHT(p_raw_value, v_suffix));

        WHEN 'KEEP_PREFIX_SUFFIX' THEN
            SET v_prefix = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_params, '$.prefix')) AS UNSIGNED), 3);
            SET v_suffix = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_params, '$.suffix')) AS UNSIGNED), 4);
            IF v_len <= v_prefix + v_suffix THEN
                RETURN REPEAT('*', GREATEST(v_len, 1));
            END IF;
            RETURN CONCAT(
                LEFT(p_raw_value, v_prefix),
                REPEAT('*', v_len - v_prefix - v_suffix),
                RIGHT(p_raw_value, v_suffix)
            );

        WHEN 'EMAIL_MASK' THEN
            IF LOCATE('@', p_raw_value) = 0 THEN
                RETURN REPEAT('*', GREATEST(v_len, 1));
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
            SET v_level = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_params, '$.level')), 'city');
            IF v_level = 'province' THEN
                IF LOCATE('省', p_raw_value) > 0 THEN
                    RETURN CONCAT(SUBSTRING_INDEX(p_raw_value, '省', 1), '省***');
                END IF;
                IF LOCATE('市', p_raw_value) > 0 THEN
                    RETURN CONCAT(SUBSTRING_INDEX(p_raw_value, '市', 1), '市***');
                END IF;
                RETURN REPEAT('*', GREATEST(v_len, 1));
            END IF;
            IF LOCATE('省', p_raw_value) > 0 AND LOCATE('市', p_raw_value) > LOCATE('省', p_raw_value) THEN
                RETURN CONCAT(
                    SUBSTRING(p_raw_value, 1, LOCATE('市', p_raw_value)),
                    '***'
                );
            END IF;
            IF LOCATE('市', p_raw_value) > 0 THEN
                RETURN CONCAT(SUBSTRING(p_raw_value, 1, LOCATE('市', p_raw_value)), '***');
            END IF;
            RETURN REPEAT('*', GREATEST(v_len, 1));

        WHEN 'GENERALIZATION' THEN
            SET v_step = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_params, '$.step')) AS DECIMAL(18, 2)), 10);
            IF v_step <= 0 THEN
                RETURN p_raw_value;
            END IF;
            SET v_start = FLOOR(CAST(p_raw_value AS DECIMAL(18, 2)) / v_step) * v_step;
            SET v_end = v_start + v_step;
            RETURN CONCAT(TRIM(TRAILING '.00' FROM FORMAT(v_start, 2)), '-', TRIM(TRAILING '.00' FROM FORMAT(v_end, 2)));

        WHEN 'KEEP_YEAR' THEN
            RETURN CONCAT(LEFT(p_raw_value, 4), '-**-**');

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
    DECLARE v_type_code VARCHAR(50);
    DECLARE v_params JSON;

    IF p_raw_value IS NULL THEN
        RETURN NULL;
    END IF;

    SELECT mtd.type_code, mp.params
      INTO v_type_code, v_params
      FROM sensitive_field sf
      JOIN masking_policy mp
        ON mp.sensitive_field_id = sf.id
       AND mp.status = 1
      JOIN masking_type_dict mtd
        ON mtd.id = mp.masking_type_id
       AND mtd.status = 1
      LEFT JOIN masking_rule_assignment mra
        ON mra.policy_id = mp.id
       AND mra.role_id = p_role_id
       AND mra.enabled = 1
     WHERE sf.object_name = p_object_name
       AND sf.column_name = p_column_name
       AND sf.enabled = 1
       AND (mra.id IS NOT NULL OR mp.is_default = 1)
     ORDER BY CASE WHEN mra.id IS NOT NULL THEN 0 ELSE 1 END, mp.id
     LIMIT 1;

    IF v_type_code IS NULL THEN
        RETURN p_raw_value;
    END IF;

    RETURN FN_APPLY_MASK(p_raw_value, v_type_code, v_params);
END$$

DELIMITER ;

CREATE VIEW v_student_profile AS
SELECT
    s.id AS student_id,
    s.student_no,
    s.name,
    s.gender,
    s.birth_date,
    s.status,
    ci.class_code,
    ci.class_name,
    gi.grade_name,
    gi.entry_year,
    m.major_code,
    m.major_name,
    c.college_code,
    c.college_name,
    ss.phone,
    ss.email,
    ss.id_card,
    ss.address,
    ss.family_income,
    ss.bank_card
FROM student s
JOIN class_info ci ON ci.id = s.class_id
JOIN grade_info gi ON gi.id = ci.grade_id
JOIN major m ON m.id = ci.major_id
JOIN college c ON c.id = m.college_id
LEFT JOIN student_sensitive ss ON ss.student_id = s.id;

CREATE VIEW v_student_score_detail AS
SELECT
    sc.id AS score_id,
    s.id AS student_id,
    s.student_no,
    s.name AS student_name,
    ci.class_name,
    m.major_name,
    c.college_name,
    co.course_code,
    co.course_name,
    sem.semester_name,
    sc.score,
    CASE
        WHEN sc.score >= 90 THEN 'A'
        WHEN sc.score >= 80 THEN 'B'
        WHEN sc.score >= 70 THEN 'C'
        WHEN sc.score >= 60 THEN 'D'
        ELSE 'E'
    END AS score_level
FROM student_score sc
JOIN student s ON s.id = sc.student_id
JOIN class_info ci ON ci.id = s.class_id
JOIN major m ON m.id = ci.major_id
JOIN college c ON c.id = m.college_id
JOIN course co ON co.id = sc.course_id
JOIN semester_info sem ON sem.id = sc.semester_id;

CREATE VIEW v_masking_config AS
SELECT
    COALESCE(r.role_code, 'DEFAULT') AS role_code,
    sf.object_name,
    sf.column_name,
    sf.column_comment,
    mp.policy_name,
    mtd.type_code,
    mp.params,
    mp.is_default,
    mp.status
FROM masking_policy mp
JOIN sensitive_field sf ON sf.id = mp.sensitive_field_id
JOIN masking_type_dict mtd ON mtd.id = mp.masking_type_id
LEFT JOIN masking_rule_assignment mra ON mra.policy_id = mp.id AND mra.enabled = 1
LEFT JOIN sys_role r ON r.id = mra.role_id;

DELIMITER $$

CREATE PROCEDURE SP_QUERY_STUDENTS(
    IN p_user_id BIGINT,
    IN p_role_code VARCHAR(50),
    IN p_student_no VARCHAR(30),
    IN p_name VARCHAR(50),
    IN p_class_name VARCHAR(100)
)
BEGIN
    DECLARE v_role_id BIGINT;
    DECLARE v_username VARCHAR(50);
    DECLARE v_result_count INT DEFAULT 0;
    DECLARE v_condition VARCHAR(500);

    SELECT id INTO v_role_id
      FROM sys_role
     WHERE role_code = p_role_code
       AND status = 1
     LIMIT 1;

    SELECT username INTO v_username
      FROM sys_user
     WHERE id = p_user_id
     LIMIT 1;

    SELECT COUNT(*)
      INTO v_result_count
      FROM v_student_profile v
     WHERE (p_student_no IS NULL OR p_student_no = '' OR v.student_no = p_student_no)
       AND (p_name IS NULL OR p_name = '' OR v.name LIKE CONCAT('%', p_name, '%'))
       AND (p_class_name IS NULL OR p_class_name = '' OR v.class_name = p_class_name);

    SET v_condition = CONCAT(
        'student_no=', COALESCE(p_student_no, 'NULL'),
        '; name=', COALESCE(p_name, 'NULL'),
        '; class_name=', COALESCE(p_class_name, 'NULL')
    );

    INSERT INTO access_log (
        user_id,
        username_snapshot,
        role_snapshot,
        operation_type,
        target_object,
        query_condition,
        sensitive_columns,
        masking_applied,
        result_count
    ) VALUES (
        p_user_id,
        v_username,
        p_role_code,
        'QUERY',
        'v_student_profile',
        v_condition,
        'name,phone,email,id_card,address,birth_date,family_income,bank_card',
        1,
        v_result_count
    );

    SELECT
        v.student_id,
        v.student_no,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'name', v.name) AS name,
        v.gender,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'birth_date', CAST(v.birth_date AS CHAR)) AS birth_date,
        v.status,
        v.class_code,
        v.class_name,
        v.grade_name,
        v.entry_year,
        v.major_code,
        v.major_name,
        v.college_code,
        v.college_name,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'phone', v.phone) AS phone,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'email', v.email) AS email,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'id_card', v.id_card) AS id_card,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'address', v.address) AS address,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'family_income', CAST(v.family_income AS CHAR)) AS family_income,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_profile', 'bank_card', v.bank_card) AS bank_card
    FROM v_student_profile v
    WHERE (p_student_no IS NULL OR p_student_no = '' OR v.student_no = p_student_no)
      AND (p_name IS NULL OR p_name = '' OR v.name LIKE CONCAT('%', p_name, '%'))
      AND (p_class_name IS NULL OR p_class_name = '' OR v.class_name = p_class_name)
    ORDER BY v.student_no;
END$$

CREATE PROCEDURE SP_QUERY_STUDENT_SCORES(
    IN p_user_id BIGINT,
    IN p_role_code VARCHAR(50),
    IN p_student_no VARCHAR(30),
    IN p_course_name VARCHAR(100),
    IN p_semester_name VARCHAR(30)
)
BEGIN
    DECLARE v_role_id BIGINT;
    DECLARE v_username VARCHAR(50);
    DECLARE v_result_count INT DEFAULT 0;
    DECLARE v_condition VARCHAR(500);

    SELECT id INTO v_role_id
      FROM sys_role
     WHERE role_code = p_role_code
       AND status = 1
     LIMIT 1;

    SELECT username INTO v_username
      FROM sys_user
     WHERE id = p_user_id
     LIMIT 1;

    SELECT COUNT(*)
      INTO v_result_count
      FROM v_student_score_detail v
     WHERE (p_student_no IS NULL OR p_student_no = '' OR v.student_no = p_student_no)
       AND (p_course_name IS NULL OR p_course_name = '' OR v.course_name = p_course_name)
       AND (p_semester_name IS NULL OR p_semester_name = '' OR v.semester_name = p_semester_name);

    SET v_condition = CONCAT(
        'student_no=', COALESCE(p_student_no, 'NULL'),
        '; course_name=', COALESCE(p_course_name, 'NULL'),
        '; semester_name=', COALESCE(p_semester_name, 'NULL')
    );

    INSERT INTO access_log (
        user_id,
        username_snapshot,
        role_snapshot,
        operation_type,
        target_object,
        query_condition,
        sensitive_columns,
        masking_applied,
        result_count
    ) VALUES (
        p_user_id,
        v_username,
        p_role_code,
        'QUERY',
        'v_student_score_detail',
        v_condition,
        'score',
        1,
        v_result_count
    );

    SELECT
        v.score_id,
        v.student_id,
        v.student_no,
        v.student_name,
        v.class_name,
        v.major_name,
        v.college_name,
        v.course_code,
        v.course_name,
        v.semester_name,
        FN_MASK_BY_ROLE(v_role_id, 'v_student_score_detail', 'score', CAST(v.score AS CHAR)) AS score,
        v.score_level
    FROM v_student_score_detail v
    WHERE (p_student_no IS NULL OR p_student_no = '' OR v.student_no = p_student_no)
      AND (p_course_name IS NULL OR p_course_name = '' OR v.course_name = p_course_name)
      AND (p_semester_name IS NULL OR p_semester_name = '' OR v.semester_name = p_semester_name)
    ORDER BY v.student_no, v.semester_name, v.course_code;
END$$

CREATE PROCEDURE SP_DETECT_ABNORMAL()
BEGIN
    INSERT INTO abnormal_access (
        user_id,
        username_snapshot,
        role_snapshot,
        anomaly_type,
        description,
        detection_window,
        related_count
    )
    SELECT
        al.user_id,
        MAX(al.username_snapshot),
        MAX(al.role_snapshot),
        'HIGH_FREQUENCY_QUERY',
        CONCAT('1小时内访问敏感视图 ', COUNT(*), ' 次'),
        CONCAT(
            DATE_FORMAT(DATE_SUB(NOW(), INTERVAL 1 HOUR), '%Y-%m-%d %H:%i:%s'),
            ' ~ ',
            DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
        ),
        COUNT(*)
    FROM access_log al
    WHERE al.access_time >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
      AND al.target_object IN ('v_student_profile', 'v_student_score_detail')
    GROUP BY al.user_id
    HAVING COUNT(*) >= 20;
END$$

CREATE TRIGGER trg_policy_change_log_ins
AFTER INSERT ON masking_policy
FOR EACH ROW
BEGIN
    INSERT INTO rule_change_log (
        policy_id,
        operator_id,
        operator_name,
        operation_type,
        before_content,
        after_content
    ) VALUES (
        NEW.id,
        @current_operator_id,
        @current_operator_name,
        'INSERT',
        NULL,
        JSON_OBJECT(
            'policy_name', NEW.policy_name,
            'sensitive_field_id', NEW.sensitive_field_id,
            'masking_type_id', NEW.masking_type_id,
            'params', NEW.params,
            'is_default', NEW.is_default,
            'status', NEW.status
        )
    );
END$$

CREATE TRIGGER trg_policy_change_log_upd
AFTER UPDATE ON masking_policy
FOR EACH ROW
BEGIN
    INSERT INTO rule_change_log (
        policy_id,
        operator_id,
        operator_name,
        operation_type,
        before_content,
        after_content
    ) VALUES (
        NEW.id,
        @current_operator_id,
        @current_operator_name,
        'UPDATE',
        JSON_OBJECT(
            'policy_name', OLD.policy_name,
            'sensitive_field_id', OLD.sensitive_field_id,
            'masking_type_id', OLD.masking_type_id,
            'params', OLD.params,
            'is_default', OLD.is_default,
            'status', OLD.status
        ),
        JSON_OBJECT(
            'policy_name', NEW.policy_name,
            'sensitive_field_id', NEW.sensitive_field_id,
            'masking_type_id', NEW.masking_type_id,
            'params', NEW.params,
            'is_default', NEW.is_default,
            'status', NEW.status
        )
    );
END$$

CREATE TRIGGER trg_policy_change_log_del
AFTER DELETE ON masking_policy
FOR EACH ROW
BEGIN
    INSERT INTO rule_change_log (
        policy_id,
        operator_id,
        operator_name,
        operation_type,
        before_content,
        after_content
    ) VALUES (
        OLD.id,
        @current_operator_id,
        @current_operator_name,
        'DELETE',
        JSON_OBJECT(
            'policy_name', OLD.policy_name,
            'sensitive_field_id', OLD.sensitive_field_id,
            'masking_type_id', OLD.masking_type_id,
            'params', OLD.params,
            'is_default', OLD.is_default,
            'status', OLD.status
        ),
        NULL
    );
END$$

DELIMITER ;

INSERT INTO sys_role (id, role_name, role_code, description, status) VALUES
(1, '超级管理员', 'SUPER_ADMIN', '拥有全部权限', 1),
(2, '系统管理员', 'SYSTEM_ADMIN', '管理用户、角色、权限', 1),
(3, '数据管理员', 'DATA_ADMIN', '维护业务主数据', 1),
(4, '安全管理员', 'SECURITY_ADMIN', '维护脱敏规则与安全策略', 1),
(5, '教师', 'TEACHER', '查询学生信息与成绩', 1),
(6, '数据分析师', 'ANALYST', '使用脱敏数据开展统计分析', 1),
(7, '安全审计员', 'AUDITOR', '审计访问日志与异常行为', 1),
(8, '普通用户', 'NORMAL', '仅可查看高度脱敏数据', 1);

INSERT INTO sys_user (id, username, password, real_name, status) VALUES
(1, 'super_admin', '$2a$10$7EqJtq98hPqEX7fNZaFWoOeB9n1kWeNseyX2VINeodIZ6Tn6Pvx6', '系统超级管理员', 1),
(2, 'system_admin', '$2a$10$7EqJtq98hPqEX7fNZaFWoOeB9n1kWeNseyX2VINeodIZ6Tn6Pvx6', '系统管理员', 1),
(3, 'data_admin', '$2a$10$7EqJtq98hPqEX7fNZaFWoOeB9n1kWeNseyX2VINeodIZ6Tn6Pvx6', '数据管理员', 1),
(4, 'security_admin', '$2a$10$7EqJtq98hPqEX7fNZaFWoOeB9n1kWeNseyX2VINeodIZ6Tn6Pvx6', '安全管理员', 1),
(5, 'teacher01', '$2a$10$7EqJtq98hPqEX7fNZaFWoOeB9n1kWeNseyX2VINeodIZ6Tn6Pvx6', '张老师', 1),
(6, 'analyst01', '$2a$10$7EqJtq98hPqEX7fNZaFWoOeB9n1kWeNseyX2VINeodIZ6Tn6Pvx6', '李分析师', 1),
(7, 'auditor01', '$2a$10$7EqJtq98hPqEX7fNZaFWoOeB9n1kWeNseyX2VINeodIZ6Tn6Pvx6', '王审计员', 1),
(8, 'normal01', '$2a$10$7EqJtq98hPqEX7fNZaFWoOeB9n1kWeNseyX2VINeodIZ6Tn6Pvx6', '普通用户', 1);

INSERT INTO sys_user_role (user_id, role_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8);

INSERT INTO sys_permission (id, permission_name, permission_code, permission_type, parent_id, sort_order, status) VALUES
(1, '系统首页', 'MENU:DASHBOARD', 'MENU', NULL, 1, 1),
(2, '学生信息查询页面', 'MENU:STUDENT_QUERY', 'MENU', NULL, 2, 1),
(3, '脱敏规则管理页面', 'MENU:MASKING_RULE', 'MENU', NULL, 3, 1),
(4, '审计日志页面', 'MENU:AUDIT_LOG', 'MENU', NULL, 4, 1),
(5, '用户角色管理页面', 'MENU:SYSTEM_ADMIN', 'MENU', NULL, 5, 1),
(6, '学生信息查询接口', 'API:STUDENT_QUERY', 'API', NULL, 11, 1),
(7, '成绩查询接口', 'API:STUDENT_SCORE_QUERY', 'API', NULL, 12, 1),
(8, '脱敏规则维护接口', 'API:MASKING_RULE_MAINTAIN', 'API', NULL, 13, 1),
(9, '审计查询接口', 'API:AUDIT_QUERY', 'API', NULL, 14, 1),
(10, '查看原始数据', 'DATA:VIEW_RAW', 'DATA', NULL, 21, 1),
(11, '查看脱敏数据', 'DATA:VIEW_MASKED', 'DATA', NULL, 22, 1),
(12, '维护业务主数据', 'DATA:MAINTAIN_MASTER_DATA', 'DATA', NULL, 23, 1),
(13, '维护脱敏策略', 'DATA:CONFIG_MASKING', 'DATA', NULL, 24, 1),
(14, '查看审计数据', 'DATA:VIEW_AUDIT', 'DATA', NULL, 25, 1);

INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 1, id FROM sys_permission;

INSERT INTO sys_role_permission (role_id, permission_id) VALUES
(2, 1), (2, 5), (2, 8),
(3, 1), (3, 2), (3, 6), (3, 10), (3, 11), (3, 12),
(4, 1), (4, 3), (4, 8), (4, 9), (4, 13), (4, 14),
(5, 1), (5, 2), (5, 6), (5, 7), (5, 11),
(6, 1), (6, 2), (6, 6), (6, 7), (6, 11),
(7, 1), (7, 4), (7, 9), (7, 14),
(8, 1), (8, 2), (8, 6), (8, 11);

INSERT INTO college (id, college_code, college_name, status) VALUES
(1, 'C01', '网络空间安全学院', 1),
(2, 'C02', '计算机学院', 1),
(3, 'C03', '经济学院', 1);

INSERT INTO major (id, college_id, major_code, major_name, status) VALUES
(1, 1, 'M0101', '网络空间安全', 1),
(2, 1, 'M0102', '信息安全', 1),
(3, 2, 'M0201', '软件工程', 1),
(4, 2, 'M0202', '人工智能', 1),
(5, 3, 'M0301', '金融学', 1);

INSERT INTO grade_info (id, grade_name, entry_year, status) VALUES
(1, '2022级', 2022, 1),
(2, '2023级', 2023, 1),
(3, '2024级', 2024, 1);

INSERT INTO class_info (id, major_id, grade_id, class_code, class_name, status) VALUES
(1, 1, 2, 'CLS230101', '网安1班', 1),
(2, 2, 1, 'CLS220201', '信安1班', 1),
(3, 3, 2, 'CLS230301', '软工1班', 1),
(4, 4, 3, 'CLS240401', '人工智能1班', 1),
(5, 5, 2, 'CLS230501', '金融1班', 1);

INSERT INTO student (id, class_id, student_no, name, gender, birth_date, status) VALUES
(1, 1, '20230101001', '张三', 'M', '2005-01-01', 0),
(2, 1, '20230101002', '李四', 'F', '2005-03-12', 0),
(3, 2, '20220102001', '王五', 'M', '2004-11-20', 0),
(4, 3, '20230103001', '赵六', 'F', '2005-07-08', 0),
(5, 4, '20240104001', '陈晨', 'F', '2006-04-18', 0),
(6, 5, '20230105001', '周航', 'M', '2005-09-03', 1);

INSERT INTO student_sensitive (student_id, phone, email, id_card, address, family_income, bank_card) VALUES
(1, '13812345678', 'zhangsan@school.edu.cn', '510104200501012345', '四川省成都市武侯区一环路南一段24号', 86000.00, '6222021234567890123'),
(2, '13987654321', 'lisi@school.edu.cn', '510105200503122468', '四川省成都市锦江区东大街88号', 120000.00, '6228480012345678901'),
(3, '13611112222', 'wangwu@school.edu.cn', '510106200411202399', '四川省成都市金牛区育才路16号', 65000.00, '6217001234567890123'),
(4, '13733334444', 'zhaoliu@school.edu.cn', '510107200507082256', '四川省成都市高新区天府大道中段1号', 98000.00, '6210985678901234567'),
(5, '13555556666', 'chenchen@school.edu.cn', '510108200604183311', '四川省成都市双流区航空港大学路99号', 54000.00, '6222623456789012345'),
(6, '13477778888', 'zhouhang@school.edu.cn', '510109200509033277', '四川省成都市龙泉驿区成龙大道二段56号', 135000.00, '6227009876543210987');

INSERT INTO course (id, course_code, course_name, credit, status) VALUES
(1, 'CS301', '数据库原理', 3.0, 1),
(2, 'CS302', '数据结构', 4.0, 1),
(3, 'CS303', '网络安全', 3.0, 1),
(4, 'CS304', '软件工程', 3.0, 1),
(5, 'CS305', '机器学习', 3.0, 1),
(6, 'EC301', '金融学', 3.0, 1);

INSERT INTO semester_info (id, school_year, term_no, semester_name, status) VALUES
(1, '2023-2024', 1, '2023-2024-1', 1),
(2, '2023-2024', 2, '2023-2024-2', 1),
(3, '2024-2025', 1, '2024-2025-1', 1);

INSERT INTO student_score (student_id, course_id, semester_id, score) VALUES
(1, 1, 1, 89.00),
(1, 2, 1, 93.00),
(1, 3, 2, 85.00),
(2, 1, 1, 76.00),
(2, 2, 1, 81.00),
(3, 3, 2, 88.00),
(3, 1, 2, 79.00),
(4, 4, 2, 91.00),
(4, 1, 1, 83.00),
(5, 5, 3, 95.00),
(5, 1, 3, 87.00),
(6, 6, 2, 78.00);

INSERT INTO masking_type_dict (id, type_code, type_name, description, param_schema, default_params, status) VALUES
(1, 'NO_MASK', '不脱敏', '直接返回原值', JSON_OBJECT(), JSON_OBJECT(), 1),
(2, 'FULL_MASK', '完全遮蔽', '使用星号完全遮蔽', JSON_OBJECT(), JSON_OBJECT(), 1),
(3, 'KEEP_PREFIX', '保留前缀', '保留前若干位，其余遮蔽', JSON_OBJECT('prefix', 'int'), JSON_OBJECT('prefix', 1), 1),
(4, 'KEEP_SUFFIX', '保留后缀', '保留后若干位，其余遮蔽', JSON_OBJECT('suffix', 'int'), JSON_OBJECT('suffix', 4), 1),
(5, 'KEEP_PREFIX_SUFFIX', '保留前后缀', '保留前后若干位，中间遮蔽', JSON_OBJECT('prefix', 'int', 'suffix', 'int'), JSON_OBJECT('prefix', 3, 'suffix', 4), 1),
(6, 'EMAIL_MASK', '邮箱脱敏', '仅保留邮箱前缀首字符与域名', JSON_OBJECT(), JSON_OBJECT(), 1),
(7, 'ADDRESS_LEVEL', '地址分级脱敏', '按省级或市级保留地址', JSON_OBJECT('level', 'string'), JSON_OBJECT('level', 'city'), 1),
(8, 'GENERALIZATION', '区间泛化', '将数值映射为区间', JSON_OBJECT('step', 'number'), JSON_OBJECT('step', 10), 1),
(9, 'KEEP_YEAR', '保留年份', '仅保留出生年份', JSON_OBJECT(), JSON_OBJECT(), 1);

INSERT INTO sensitive_field (id, entity_name, object_name, object_type, column_name, column_comment, sensitive_type, sensitive_level, identify_method, enabled) VALUES
(1, 'STUDENT', 'v_student_profile', 'VIEW', 'name', '姓名', 'NAME', 'MEDIUM', 'MANUAL', 1),
(2, 'STUDENT', 'v_student_profile', 'VIEW', 'phone', '手机号', 'PHONE', 'HIGH', 'MANUAL', 1),
(3, 'STUDENT', 'v_student_profile', 'VIEW', 'email', '邮箱', 'EMAIL', 'MEDIUM', 'MANUAL', 1),
(4, 'STUDENT', 'v_student_profile', 'VIEW', 'id_card', '身份证号', 'ID_CARD', 'HIGH', 'MANUAL', 1),
(5, 'STUDENT', 'v_student_profile', 'VIEW', 'address', '家庭住址', 'ADDRESS', 'HIGH', 'MANUAL', 1),
(6, 'STUDENT', 'v_student_profile', 'VIEW', 'birth_date', '出生日期', 'BIRTH_DATE', 'MEDIUM', 'MANUAL', 1),
(7, 'STUDENT', 'v_student_profile', 'VIEW', 'family_income', '家庭收入', 'INCOME', 'HIGH', 'MANUAL', 1),
(8, 'STUDENT', 'v_student_profile', 'VIEW', 'bank_card', '银行卡号', 'BANK_CARD', 'HIGH', 'MANUAL', 1),
(9, 'STUDENT_SCORE', 'v_student_score_detail', 'VIEW', 'score', '成绩', 'SCORE', 'MEDIUM', 'MANUAL', 1);

INSERT INTO masking_policy (id, sensitive_field_id, masking_type_id, policy_name, params, is_default, status, description, create_by, update_by) VALUES
(1, 1, 1, '姓名不脱敏', JSON_OBJECT(), 0, 1, '完整展示姓名', 4, 4),
(2, 1, 3, '姓名保留姓氏', JSON_OBJECT('prefix', 1), 0, 1, '仅保留姓氏', 4, 4),
(3, 1, 2, '姓名完全遮蔽', JSON_OBJECT(), 1, 1, '默认完全遮蔽姓名', 4, 4),
(4, 2, 1, '手机号不脱敏', JSON_OBJECT(), 0, 1, '完整展示手机号', 4, 4),
(5, 2, 5, '手机号保留前3后4', JSON_OBJECT('prefix', 3, 'suffix', 4), 0, 1, '教师和分析师使用', 4, 4),
(6, 2, 2, '手机号完全遮蔽', JSON_OBJECT(), 1, 1, '默认完全遮蔽手机号', 4, 4),
(7, 3, 1, '邮箱不脱敏', JSON_OBJECT(), 0, 1, '完整展示邮箱', 4, 4),
(8, 3, 6, '邮箱用户名脱敏', JSON_OBJECT(), 0, 1, '保留域名信息', 4, 4),
(9, 3, 2, '邮箱完全遮蔽', JSON_OBJECT(), 1, 1, '默认完全遮蔽邮箱', 4, 4),
(10, 4, 1, '身份证不脱敏', JSON_OBJECT(), 0, 1, '完整展示身份证', 4, 4),
(11, 4, 5, '身份证保留前6后4', JSON_OBJECT('prefix', 6, 'suffix', 4), 0, 1, '教师使用', 4, 4),
(12, 4, 2, '身份证完全遮蔽', JSON_OBJECT(), 1, 1, '默认完全遮蔽身份证', 4, 4),
(13, 5, 1, '地址不脱敏', JSON_OBJECT(), 0, 1, '完整展示地址', 4, 4),
(14, 5, 7, '地址保留到市级', JSON_OBJECT('level', 'city'), 0, 1, '教师使用', 4, 4),
(15, 5, 7, '地址保留到省级', JSON_OBJECT('level', 'province'), 0, 1, '分析师使用', 4, 4),
(16, 5, 2, '地址完全遮蔽', JSON_OBJECT(), 1, 1, '默认完全遮蔽地址', 4, 4),
(17, 6, 1, '出生日期不脱敏', JSON_OBJECT(), 0, 1, '完整展示出生日期', 4, 4),
(18, 6, 9, '出生日期保留年份', JSON_OBJECT(), 0, 1, '教师和分析师使用', 4, 4),
(19, 6, 2, '出生日期完全遮蔽', JSON_OBJECT(), 1, 1, '默认完全遮蔽出生日期', 4, 4),
(20, 7, 1, '家庭收入不脱敏', JSON_OBJECT(), 0, 1, '完整展示家庭收入', 4, 4),
(21, 7, 8, '家庭收入按1万元泛化', JSON_OBJECT('step', 10000), 0, 1, '教师和分析师使用', 4, 4),
(22, 7, 2, '家庭收入完全遮蔽', JSON_OBJECT(), 1, 1, '默认完全遮蔽家庭收入', 4, 4),
(23, 8, 1, '银行卡不脱敏', JSON_OBJECT(), 0, 1, '完整展示银行卡', 4, 4),
(24, 8, 4, '银行卡保留后4位', JSON_OBJECT('suffix', 4), 0, 1, '教师使用', 4, 4),
(25, 8, 2, '银行卡完全遮蔽', JSON_OBJECT(), 1, 1, '默认完全遮蔽银行卡', 4, 4),
(26, 9, 1, '成绩不脱敏', JSON_OBJECT(), 0, 1, '完整展示成绩', 4, 4),
(27, 9, 8, '成绩按10分区间泛化', JSON_OBJECT('step', 10), 0, 1, '分析师使用', 4, 4),
(28, 9, 2, '成绩完全遮蔽', JSON_OBJECT(), 1, 1, '默认完全遮蔽成绩', 4, 4);

INSERT INTO masking_rule_assignment (role_id, policy_id, enabled) VALUES
(1, 1, 1), (1, 4, 1), (1, 7, 1), (1, 10, 1), (1, 13, 1), (1, 17, 1), (1, 20, 1), (1, 23, 1), (1, 26, 1),
(3, 1, 1), (3, 4, 1), (3, 7, 1), (3, 10, 1), (3, 13, 1), (3, 17, 1), (3, 20, 1), (3, 23, 1), (3, 26, 1),
(5, 1, 1), (5, 5, 1), (5, 8, 1), (5, 11, 1), (5, 14, 1), (5, 18, 1), (5, 21, 1), (5, 24, 1), (5, 26, 1),
(6, 2, 1), (6, 5, 1), (6, 8, 1), (6, 12, 1), (6, 15, 1), (6, 18, 1), (6, 21, 1), (6, 25, 1), (6, 27, 1),
(8, 3, 1), (8, 6, 1), (8, 9, 1), (8, 12, 1), (8, 16, 1), (8, 19, 1), (8, 22, 1), (8, 25, 1), (8, 28, 1);

-- 使用示例：
-- CALL SP_QUERY_STUDENTS(5, 'TEACHER', NULL, NULL, NULL);
-- CALL SP_QUERY_STUDENT_SCORES(6, 'ANALYST', NULL, NULL, NULL);
-- CALL SP_DETECT_ABNORMAL();
