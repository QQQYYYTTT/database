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

UPDATE role SET role_description = '动态脱敏：超级管理员，可查看原始敏感数据' WHERE role_code = 'SUPER_ADMIN';
UPDATE role SET role_description = '动态脱敏：数据管理员，可查看原始敏感数据' WHERE role_code = 'DATA_ADMIN';
UPDATE role SET role_description = '动态脱敏：教师，按教学场景部分脱敏' WHERE role_code = 'TEACHER';
UPDATE role SET role_description = '动态脱敏：分析师，按统计分析场景脱敏/泛化' WHERE role_code = 'ANALYST';
UPDATE role SET role_description = '动态脱敏：普通用户，使用高强度默认脱敏' WHERE role_code = 'NORMAL';
UPDATE role SET role_description = '动态脱敏：学生查看本人信息与成绩' WHERE role_code = 'STUDENT';

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

UPDATE login_log SET login_message = '登录成功' WHERE login_message LIKE '閻%' OR login_message LIKE '鐧%';
UPDATE login_log SET login_message = '用户名或密码错误' WHERE id = 5;

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
