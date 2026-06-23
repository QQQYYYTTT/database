SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS abnormal_access (
    id bigint(20) NOT NULL AUTO_INCREMENT,
    user_id bigint(20) DEFAULT NULL,
    abnormal_type varchar(50) DEFAULT NULL,
    severity varchar(20) DEFAULT NULL,
    detail text DEFAULT NULL,
    create_time datetime DEFAULT current_timestamp(),
    PRIMARY KEY (id) USING BTREE
);

ALTER TABLE abnormal_access
    ADD COLUMN IF NOT EXISTS rule_name varchar(100) DEFAULT NULL AFTER user_id,
    ADD COLUMN IF NOT EXISTS trigger_count int(11) DEFAULT NULL AFTER severity,
    ADD COLUMN IF NOT EXISTS window_start datetime DEFAULT NULL AFTER trigger_count,
    ADD COLUMN IF NOT EXISTS window_end datetime DEFAULT NULL AFTER window_start;

UPDATE semester_info SET semester_name = '2023秋' WHERE id = 1;
UPDATE semester_info SET semester_name = '2024春' WHERE id = 2;
UPDATE semester_info SET semester_name = '2024秋' WHERE id = 3;
UPDATE semester_info SET semester_name = '2025春' WHERE id = 4;
UPDATE semester_info SET semester_name = '2025秋' WHERE id = 5;

UPDATE login_log
SET login_message = '登录成功'
WHERE id IN (1, 2, 3, 4, 6, 7, 8, 13, 14, 15, 16, 17, 18, 19, 20);

UPDATE login_log
SET login_message = '用户名或密码错误'
WHERE id = 5;

UPDATE permission SET permission_name = '首页', description = '首页菜单' WHERE permission_code = 'menu:dashboard';
UPDATE permission SET permission_name = '个人信息', description = '当前用户个人信息菜单' WHERE permission_code = 'menu:profile';
UPDATE permission SET permission_name = '用户管理', description = '用户管理菜单' WHERE permission_code = 'menu:user';
UPDATE permission SET permission_name = '角色管理', description = '角色管理菜单' WHERE permission_code = 'menu:role';
UPDATE permission SET permission_name = '权限管理', description = '权限管理菜单' WHERE permission_code = 'menu:permission';
UPDATE permission SET permission_name = '登录日志', description = '登录日志菜单' WHERE permission_code = 'menu:log';
UPDATE permission SET permission_name = '学生信息', description = '学生脱敏信息菜单' WHERE permission_code = 'menu:student';
UPDATE permission SET permission_name = '学生成绩', description = '学生脱敏成绩菜单' WHERE permission_code = 'menu:score';
UPDATE permission SET permission_name = '查看用户', description = '查看用户' WHERE permission_code = 'sys:user:view';
UPDATE permission SET permission_name = '新增用户', description = '创建用户' WHERE permission_code = 'sys:user:create';
UPDATE permission SET permission_name = '编辑用户', description = '更新用户' WHERE permission_code = 'sys:user:update';
UPDATE permission SET permission_name = '删除用户', description = '删除用户' WHERE permission_code = 'sys:user:delete';
UPDATE permission SET permission_name = '查看角色', description = '查看角色' WHERE permission_code = 'sys:role:view';
UPDATE permission SET permission_name = '新增角色', description = '创建角色' WHERE permission_code = 'sys:role:create';
UPDATE permission SET permission_name = '编辑角色', description = '更新角色' WHERE permission_code = 'sys:role:update';
UPDATE permission SET permission_name = '删除角色', description = '删除角色' WHERE permission_code = 'sys:role:delete';
UPDATE permission SET permission_name = '查看权限', description = '查看权限' WHERE permission_code = 'sys:permission:view';
UPDATE permission SET permission_name = '新增权限', description = '创建权限' WHERE permission_code = 'sys:permission:create';
UPDATE permission SET permission_name = '编辑权限', description = '更新权限' WHERE permission_code = 'sys:permission:update';
UPDATE permission SET permission_name = '删除权限', description = '删除权限' WHERE permission_code = 'sys:permission:delete';
UPDATE permission SET permission_name = '查看登录日志', description = '查看登录日志' WHERE permission_code = 'sys:log:view';
UPDATE permission SET permission_name = '查看学生信息', description = '查看脱敏学生信息' WHERE permission_code = 'biz:student:view';
UPDATE permission SET permission_name = '查看学生成绩', description = '查看脱敏学生成绩' WHERE permission_code = 'biz:score:view';

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'menu:student-data-center', '学生数据中心', 'MENU', 0, 'student-data-center', '/student-data-center', 'studentDataCenter', 'team', NULL, NULL, 20, 1, '学生数据中心父菜单'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'menu:student-data-center'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'menu:analytics-center', '数据统计分析中心', 'MENU', 0, 'analytics-center', '/analytics-center', 'analyticsCenter', 'bar-chart', NULL, NULL, 30, 1, '数据统计分析中心父菜单'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'menu:analytics-center'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'menu:grade-analytics', '学生成绩分析', 'MENU',
       (SELECT id FROM permission WHERE permission_code = 'menu:analytics-center'),
       'grade-analytics', '/analytics/grades', 'gradeAnalytics', 'bar-chart', NULL, NULL, 31, 1, '学生成绩分析占位菜单'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'menu:grade-analytics'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'menu:sensitive-analytics', '敏感数据分析', 'MENU',
       (SELECT id FROM permission WHERE permission_code = 'menu:analytics-center'),
       'sensitive-analytics', '/analytics/sensitive-data', 'sensitiveAnalytics', 'bar-chart', NULL, NULL, 32, 1, '敏感数据分析占位菜单'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'menu:sensitive-analytics'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'biz:analytics:score:view', '查看学生成绩分析', 'API',
       (SELECT id FROM permission WHERE permission_code = 'menu:grade-analytics'),
       NULL, NULL, NULL, NULL, '/api/analytics/score', 'GET', 331, 1, '查看学生成绩分析聚合统计接口'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'biz:analytics:score:view'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'biz:analytics:sensitive:view', '查看敏感数据分析', 'API',
       (SELECT id FROM permission WHERE permission_code = 'menu:sensitive-analytics'),
       NULL, NULL, NULL, NULL, '/api/analytics/sensitive', 'GET', 332, 1, '查看敏感数据分析聚合统计接口'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'biz:analytics:sensitive:view'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'menu:security-center', '数据安全中心', 'MENU', 0, 'security-center', '/security-center', 'securityCenter', 'permission', NULL, NULL, 40, 1, '数据安全中心父菜单'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'menu:security-center'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'menu:system-management', '系统管理', 'MENU', 0, 'system-management', '/system-management', 'systemManagement', 'user', NULL, NULL, 50, 1, '系统管理父菜单'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'menu:system-management'
);

UPDATE permission
SET parent_id = (SELECT id FROM permission WHERE permission_code = 'menu:student-data-center'),
    sort_num = 21
WHERE permission_code = 'menu:student';

UPDATE permission
SET parent_id = (SELECT id FROM permission WHERE permission_code = 'menu:student-data-center'),
    sort_num = 22
WHERE permission_code = 'menu:score';

UPDATE permission
SET parent_id = (SELECT id FROM permission WHERE permission_code = 'menu:security-center'),
    sort_num = 41
WHERE permission_code = 'menu:masking-rule';

UPDATE permission
SET parent_id = (SELECT id FROM permission WHERE permission_code = 'menu:security-center'),
    sort_num = 42
WHERE permission_code = 'menu:access-log';

UPDATE permission
SET parent_id = (SELECT id FROM permission WHERE permission_code = 'menu:security-center'),
    sort_num = 43
WHERE permission_code = 'menu:rule-change-log';

UPDATE permission
SET parent_id = (SELECT id FROM permission WHERE permission_code = 'menu:security-center'),
    sort_num = 44
WHERE permission_code = 'menu:abnormal-access';

UPDATE permission
SET parent_id = (SELECT id FROM permission WHERE permission_code = 'menu:system-management'),
    sort_num = 51
WHERE permission_code = 'menu:user';

UPDATE permission
SET parent_id = (SELECT id FROM permission WHERE permission_code = 'menu:system-management'),
    sort_num = 52
WHERE permission_code = 'menu:role';

UPDATE permission
SET parent_id = (SELECT id FROM permission WHERE permission_code = 'menu:system-management'),
    sort_num = 53
WHERE permission_code = 'menu:permission';

UPDATE permission
SET visible = 0
WHERE permission_code = 'menu:profile';

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'menu:masking-rule', '脱敏规则管理', 'MENU', 0, 'masking-rule', '/masking-rules', 'maskingRules', 'permission', NULL, NULL, 22, 1, '脱敏规则管理菜单'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'menu:masking-rule'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'sys:masking-rule:view', '查看脱敏规则', 'API',
       (SELECT id FROM permission WHERE permission_code = 'menu:masking-rule'),
       NULL, NULL, NULL, NULL, '/api/masking-rules/**', 'GET', 503, 1, '查看脱敏规则'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'sys:masking-rule:view'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'sys:masking-rule:update', '修改脱敏规则', 'API',
       (SELECT id FROM permission WHERE permission_code = 'menu:masking-rule'),
       NULL, NULL, NULL, NULL, '/api/masking-rules', 'PUT', 504, 1, '修改脱敏规则'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'sys:masking-rule:update'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'menu:access-log', '访问日志', 'MENU', 0, 'access-log', '/access-logs', 'accessLogs', 'log', NULL, NULL, 23, 1, '访问日志菜单'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'menu:access-log'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'sys:access-log:view', '查看访问日志', 'API',
       (SELECT id FROM permission WHERE permission_code = 'menu:access-log'),
       NULL, NULL, NULL, NULL, '/api/access-logs/**', 'GET', 505, 1, '查看访问日志'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'sys:access-log:view'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'menu:rule-change-log', '规则变更日志', 'MENU', 0, 'rule-change-log', '/rule-change-logs', 'ruleChangeLogs', 'log', NULL, NULL, 24, 1, '规则变更日志菜单'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'menu:rule-change-log'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'sys:rule-change-log:view', '查看规则变更日志', 'API',
       (SELECT id FROM permission WHERE permission_code = 'menu:rule-change-log'),
       NULL, NULL, NULL, NULL, '/api/rule-change-logs/**', 'GET', 506, 1, '查看规则变更日志'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'sys:rule-change-log:view'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'menu:abnormal-access', '异常访问监控', 'MENU', 0, 'abnormal-access', '/abnormal-access', 'abnormalAccess', 'log', NULL, NULL, 25, 1, '异常访问监控菜单'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'menu:abnormal-access'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'sys:abnormal-access:view', '查看异常访问', 'API',
       (SELECT id FROM permission WHERE permission_code = 'menu:abnormal-access'),
       NULL, NULL, NULL, NULL, '/api/abnormal-access/**', 'GET', 507, 1, '查看异常访问记录'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'sys:abnormal-access:view'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'sys:abnormal-access:detect', '执行异常检测', 'API',
       (SELECT id FROM permission WHERE permission_code = 'menu:abnormal-access'),
       NULL, NULL, NULL, NULL, '/api/abnormal-access/detect', 'POST', 508, 1, '执行异常访问检测'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'sys:abnormal-access:detect'
);

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'menu:student-data-center'
 WHERE r.role_code IN ('SUPER_ADMIN', 'DATA_ADMIN', 'TEACHER', 'ANALYST', 'NORMAL', 'STUDENT')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'menu:analytics-center'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN', 'TEACHER', 'ANALYST')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'menu:grade-analytics'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN', 'TEACHER', 'ANALYST')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
       WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'biz:analytics:score:view'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN', 'TEACHER', 'ANALYST')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'menu:sensitive-analytics'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN', 'TEACHER', 'ANALYST')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'menu:security-center'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'menu:system-management'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'menu:masking-rule'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'sys:masking-rule:view'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'sys:masking-rule:update'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
       WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'biz:analytics:sensitive:view'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN', 'TEACHER', 'ANALYST')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'menu:access-log'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'sys:access-log:view'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'menu:rule-change-log'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'sys:rule-change-log:view'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'menu:abnormal-access'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'sys:abnormal-access:view'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
  FROM role r
  JOIN permission p ON p.permission_code = 'sys:abnormal-access:detect'
 WHERE r.role_code IN ('ADMIN', 'SUPER_ADMIN', 'DATA_ADMIN')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

DROP VIEW IF EXISTS `v_student_profile`;
CREATE VIEW `v_student_profile` AS
SELECT
    s.id AS student_id,
    s.student_no AS student_no,
    s.name AS name,
    s.gender AS gender,
    s.birth_date AS birth_date,
    s.status AS status,
    ci.class_name AS class_name,
    gi.grade_name AS grade_name,
    gi.entry_year AS entry_year,
    m.major_name AS major_name,
    c.college_name AS college_name,
    ss.phone AS phone,
    ss.email AS email,
    ss.id_card AS id_card,
    ss.address AS address,
    ss.family_income AS family_income,
    ss.bank_card AS bank_card
FROM student s
JOIN class_info ci ON ci.id = s.class_id
JOIN grade_info gi ON gi.id = ci.grade_id
JOIN major m ON m.id = ci.major_id
JOIN college c ON c.id = m.college_id
LEFT JOIN student_sensitive ss ON ss.student_id = s.id;

DROP VIEW IF EXISTS `v_student_score_detail`;
CREATE VIEW `v_student_score_detail` AS
SELECT
    sc.id AS score_id,
    s.id AS student_id,
    s.student_no AS student_no,
    s.name AS student_name,
    co.course_code AS course_code,
    co.course_name AS course_name,
    sem.semester_name AS semester_name,
    sc.score AS score,
    CASE
        WHEN sc.score >= 90 THEN 'A'
        WHEN sc.score >= 80 THEN 'B'
        WHEN sc.score >= 70 THEN 'C'
        WHEN sc.score >= 60 THEN 'D'
        ELSE 'E'
    END AS score_level
FROM student_score sc
JOIN student s ON s.id = sc.student_id
JOIN course co ON co.id = sc.course_id
JOIN semester_info sem ON sem.id = sc.semester_id;
