SET NAMES utf8mb4;

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
