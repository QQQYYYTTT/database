SET NAMES utf8mb4;

UPDATE college SET college_name = '计算机学院' WHERE id = 1;
UPDATE college SET college_name = '网络空间安全学院' WHERE id = 2;
UPDATE college SET college_name = '电子信息学院' WHERE id = 3;
UPDATE college SET college_name = '人工智能学院' WHERE id = 4;
UPDATE college SET college_name = '法学院' WHERE id = 5;

UPDATE major SET major_name = '计算机科学与技术' WHERE id = 1;
UPDATE major SET major_name = '网络空间安全' WHERE id = 2;
UPDATE major SET major_name = '电子信息工程' WHERE id = 3;
UPDATE major SET major_name = '人工智能' WHERE id = 4;
UPDATE major SET major_name = '法学' WHERE id = 5;

UPDATE class_info SET class_name = '计算机科学2301班' WHERE id = 1;
UPDATE class_info SET class_name = '网安2301班' WHERE id = 2;
UPDATE class_info SET class_name = '电子信息2401班' WHERE id = 3;
UPDATE class_info SET class_name = '人工智能2501班' WHERE id = 4;
UPDATE class_info SET class_name = '法学2601班' WHERE id = 5;

UPDATE course SET course_name = '数据结构' WHERE id = 1;
UPDATE course SET course_name = '操作系统' WHERE id = 2;
UPDATE course SET course_name = '计算机网络' WHERE id = 3;
UPDATE course SET course_name = '数据库系统' WHERE id = 4;
UPDATE course SET course_name = '信息安全导论' WHERE id = 5;

UPDATE grade_info SET grade_name = '2023级' WHERE id = 1;
UPDATE grade_info SET grade_name = '2024级' WHERE id = 2;
UPDATE grade_info SET grade_name = '2025级' WHERE id = 3;
UPDATE grade_info SET grade_name = '2026级' WHERE id = 4;
UPDATE grade_info SET grade_name = '2027级' WHERE id = 5;

UPDATE semester_info SET semester_name = '2023秋' WHERE id = 1;
UPDATE semester_info SET semester_name = '2024春' WHERE id = 2;
UPDATE semester_info SET semester_name = '2024秋' WHERE id = 3;
UPDATE semester_info SET semester_name = '2025春' WHERE id = 4;
UPDATE semester_info SET semester_name = '2025秋' WHERE id = 5;

UPDATE role SET role_description = '动态脱敏：超级管理员，可查看原始敏感数据' WHERE role_code = 'SUPER_ADMIN';
UPDATE role SET role_description = '动态脱敏：数据管理员，可查看原始敏感数据' WHERE role_code = 'DATA_ADMIN';
UPDATE role SET role_description = '动态脱敏：教师，按教学场景部分脱敏' WHERE role_code = 'TEACHER';
UPDATE role SET role_description = '动态脱敏：分析师，按统计分析场景脱敏/泛化' WHERE role_code = 'ANALYST';
UPDATE role SET role_description = '动态脱敏：普通用户，使用高强度默认脱敏' WHERE role_code = 'NORMAL';
UPDATE role SET role_description = '动态脱敏：学生查看本人信息与成绩' WHERE role_code = 'STUDENT';
UPDATE role SET role_name = '系统管理员' WHERE role_code = 'ADMIN';
UPDATE role SET role_name = '基础用户' WHERE role_code = 'USER';
UPDATE role SET role_name = '超级管理员' WHERE role_code = 'SUPER_ADMIN';
UPDATE role SET role_name = '数据管理员' WHERE role_code = 'DATA_ADMIN';
UPDATE role SET role_name = '教师' WHERE role_code = 'TEACHER';
UPDATE role SET role_name = '分析师' WHERE role_code = 'ANALYST';
UPDATE role SET role_name = '普通访客' WHERE role_code = 'NORMAL';
UPDATE role SET role_name = '学生' WHERE role_code = 'STUDENT';

UPDATE student SET name = '张伟' WHERE id = 1;
UPDATE student SET name = '李娜' WHERE id = 2;
UPDATE student SET name = '王强' WHERE id = 3;
UPDATE student SET name = '赵敏' WHERE id = 4;
UPDATE student SET name = '陈浩' WHERE id = 5;

UPDATE student_sensitive SET address = '成都高新区' WHERE student_id = 1;
UPDATE student_sensitive SET address = '成都武侯区' WHERE student_id = 2;
UPDATE student_sensitive SET address = '成都锦江区' WHERE student_id = 3;
UPDATE student_sensitive SET address = '成都成华区' WHERE student_id = 4;
UPDATE student_sensitive SET address = '成都双流区' WHERE student_id = 5;

UPDATE login_log
SET login_message = '登录成功'
WHERE id IN (1, 2, 3, 4, 6, 7, 8, 13, 14, 15, 16, 17, 18, 19, 20);

UPDATE login_log
SET login_message = '用户名或密码错误'
WHERE id = 5;

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'menu:student', 'Student Profiles', 'MENU', 0, 'student', '/student-profiles', 'studentProfiles', 'team', NULL, NULL, 20, 1, 'Student masking menu'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'menu:student'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'menu:score', 'Student Scores', 'MENU', 0, 'score', '/student-scores', 'studentScores', 'bar-chart', NULL, NULL, 21, 1, 'Student score masking menu'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'menu:score'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'biz:student:view', 'View Student Profiles', 'API',
       (SELECT id FROM permission WHERE permission_code = 'menu:student'),
       NULL, NULL, NULL, NULL, '/api/student-profiles/**', 'GET', 501, 1, 'View masked student profiles'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'biz:student:view'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key,
    route_path, component_path, icon, api_pattern, http_method, sort_num,
    visible, description
)
SELECT 'biz:score:view', 'View Student Scores', 'API',
       (SELECT id FROM permission WHERE permission_code = 'menu:score'),
       NULL, NULL, NULL, NULL, '/api/student-scores/**', 'GET', 502, 1, 'View masked student scores'
WHERE NOT EXISTS (
    SELECT 1 FROM permission WHERE permission_code = 'biz:score:view'
);

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
  JOIN permission p ON p.permission_code = 'menu:student'
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
  JOIN permission p ON p.permission_code = 'menu:score'
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
  JOIN permission p ON p.permission_code = 'biz:student:view'
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
  JOIN permission p ON p.permission_code = 'biz:score:view'
 WHERE r.role_code IN ('SUPER_ADMIN', 'DATA_ADMIN', 'TEACHER', 'ANALYST', 'NORMAL', 'STUDENT')
   AND NOT EXISTS (
       SELECT 1
         FROM role_permission rp
        WHERE rp.role_id = r.id
          AND rp.permission_id = p.id
   );

INSERT INTO user (
    user_name, user_pwd, user_header, user_phonenum, user_email,
    enabled, is_super_admin, last_login_time
)
SELECT 'mask_super_admin', 'f91e15dbec69fc40f81f0876e7009648', NULL, '13100000001', 'mask_super_admin@edu.com', 1, 0, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM user WHERE user_name = 'mask_super_admin'
);

INSERT INTO user (
    user_name, user_pwd, user_header, user_phonenum, user_email,
    enabled, is_super_admin, last_login_time
)
SELECT 'mask_teacher', 'f91e15dbec69fc40f81f0876e7009648', NULL, '13100000002', 'mask_teacher@edu.com', 1, 0, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM user WHERE user_name = 'mask_teacher'
);

INSERT INTO user (
    user_name, user_pwd, user_header, user_phonenum, user_email,
    enabled, is_super_admin, last_login_time
)
SELECT 'mask_analyst', 'f91e15dbec69fc40f81f0876e7009648', NULL, '13100000003', 'mask_analyst@edu.com', 1, 0, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM user WHERE user_name = 'mask_analyst'
);

INSERT INTO user (
    user_name, user_pwd, user_header, user_phonenum, user_email,
    enabled, is_super_admin, last_login_time
)
SELECT 'mask_normal', 'f91e15dbec69fc40f81f0876e7009648', NULL, '13100000004', 'mask_normal@edu.com', 1, 0, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM user WHERE user_name = 'mask_normal'
);

INSERT INTO user (
    user_name, user_pwd, user_header, user_phonenum, user_email,
    enabled, is_super_admin, last_login_time
)
SELECT '2023001', 'f91e15dbec69fc40f81f0876e7009648', NULL, '13100000005', 'student2023001@edu.com', 1, 0, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM user WHERE user_name = '2023001'
);

UPDATE user SET user_pwd = 'f91e15dbec69fc40f81f0876e7009648', enabled = 1, is_super_admin = 0 WHERE user_name = 'mask_super_admin';
UPDATE user SET user_pwd = 'f91e15dbec69fc40f81f0876e7009648', enabled = 1, is_super_admin = 0 WHERE user_name = 'mask_teacher';
UPDATE user SET user_pwd = 'f91e15dbec69fc40f81f0876e7009648', enabled = 1, is_super_admin = 0 WHERE user_name = 'mask_analyst';
UPDATE user SET user_pwd = 'f91e15dbec69fc40f81f0876e7009648', enabled = 1, is_super_admin = 0 WHERE user_name = 'mask_normal';
UPDATE user SET user_pwd = 'f91e15dbec69fc40f81f0876e7009648', enabled = 1, is_super_admin = 0 WHERE user_name = '2023001';

INSERT INTO user_role (user_id, role_id)
SELECT u.id, r.id
  FROM user u
  JOIN role r ON r.role_code = 'SUPER_ADMIN'
 WHERE u.user_name = 'mask_super_admin'
   AND NOT EXISTS (
       SELECT 1
         FROM user_role ur
        WHERE ur.user_id = u.id
          AND ur.role_id = r.id
   );

INSERT INTO user_role (user_id, role_id)
SELECT u.id, r.id
  FROM user u
  JOIN role r ON r.role_code = 'TEACHER'
 WHERE u.user_name = 'mask_teacher'
   AND NOT EXISTS (
       SELECT 1
         FROM user_role ur
        WHERE ur.user_id = u.id
          AND ur.role_id = r.id
   );

INSERT INTO user_role (user_id, role_id)
SELECT u.id, r.id
  FROM user u
  JOIN role r ON r.role_code = 'ANALYST'
 WHERE u.user_name = 'mask_analyst'
   AND NOT EXISTS (
       SELECT 1
         FROM user_role ur
        WHERE ur.user_id = u.id
          AND ur.role_id = r.id
   );

INSERT INTO user_role (user_id, role_id)
SELECT u.id, r.id
  FROM user u
  JOIN role r ON r.role_code = 'NORMAL'
 WHERE u.user_name = 'mask_normal'
   AND NOT EXISTS (
       SELECT 1
         FROM user_role ur
        WHERE ur.user_id = u.id
          AND ur.role_id = r.id
   );

INSERT INTO user_role (user_id, role_id)
SELECT u.id, r.id
  FROM user u
  JOIN role r ON r.role_code = 'STUDENT'
 WHERE u.user_name = '2023001'
   AND NOT EXISTS (
       SELECT 1
         FROM user_role ur
        WHERE ur.user_id = u.id
          AND ur.role_id = r.id
   );

UPDATE permission SET permission_name = '访问日志', description = '查看敏感数据访问日志' WHERE permission_code = 'menu:access-log';
UPDATE permission SET permission_name = '规则变更日志', description = '查看脱敏规则变更日志' WHERE permission_code = 'menu:rule-change-log';
UPDATE permission SET permission_name = '异常访问监控', description = '查看异常访问监控结果' WHERE permission_code = 'menu:abnormal-access';
UPDATE permission SET permission_name = '查看访问日志', description = '查看访问日志' WHERE permission_code = 'sys:access-log:view';
UPDATE permission SET permission_name = '查看规则变更日志', description = '查看规则变更日志' WHERE permission_code = 'sys:rule-change-log:view';
UPDATE permission SET permission_name = '查看异常访问', description = '查看异常访问记录' WHERE permission_code = 'sys:abnormal-access:view';
UPDATE permission SET permission_name = '执行异常检测', description = '执行异常访问检测' WHERE permission_code = 'sys:abnormal-access:detect';
