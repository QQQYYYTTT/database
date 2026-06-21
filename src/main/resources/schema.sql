CREATE TABLE IF NOT EXISTS test (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    age INT,
    email VARCHAR(100),
    created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO test (name, age, email)
SELECT 'demo', 20, 'demo@example.com'
WHERE NOT EXISTS (
    SELECT 1 FROM test WHERE email = 'demo@example.com'
);

CREATE TABLE IF NOT EXISTS `user` (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_name VARCHAR(50) NOT NULL,
    user_pwd VARCHAR(255) NOT NULL,
    user_header VARCHAR(255),
    user_phonenum VARCHAR(20),
    user_email VARCHAR(100),
    enabled TINYINT(1) NOT NULL DEFAULT 1,
    is_super_admin TINYINT(1) NOT NULL DEFAULT 0,
    create_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_time DATETIME NULL,
    UNIQUE KEY uk_user_user_name (user_name)
);

ALTER TABLE `user`
    MODIFY COLUMN user_pwd VARCHAR(255) NOT NULL;

SET @add_enabled_sql = IF(
    EXISTS (
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'user'
          AND COLUMN_NAME = 'enabled'
    ),
    'SELECT 1',
    'ALTER TABLE `user` ADD COLUMN enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER user_email'
);
PREPARE stmt_add_enabled FROM @add_enabled_sql;
EXECUTE stmt_add_enabled;
DEALLOCATE PREPARE stmt_add_enabled;

SET @add_super_admin_sql = IF(
    EXISTS (
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'user'
          AND COLUMN_NAME = 'is_super_admin'
    ),
    'SELECT 1',
    'ALTER TABLE `user` ADD COLUMN is_super_admin TINYINT(1) NOT NULL DEFAULT 0 AFTER enabled'
);
PREPARE stmt_add_super_admin FROM @add_super_admin_sql;
EXECUTE stmt_add_super_admin;
DEALLOCATE PREPARE stmt_add_super_admin;

CREATE TABLE IF NOT EXISTS role (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    role_code VARCHAR(50) NOT NULL,
    role_name VARCHAR(100) NOT NULL,
    role_description VARCHAR(255),
    sort_num INT NOT NULL DEFAULT 0,
    enabled TINYINT(1) NOT NULL DEFAULT 1,
    create_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_role_code (role_code),
    UNIQUE KEY uk_role_name (role_name)
);

CREATE TABLE IF NOT EXISTS permission (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    permission_code VARCHAR(100) NOT NULL,
    permission_name VARCHAR(100) NOT NULL,
    permission_type VARCHAR(20) NOT NULL,
    parent_id BIGINT NOT NULL DEFAULT 0,
    menu_key VARCHAR(50),
    route_path VARCHAR(120),
    component_path VARCHAR(120),
    icon VARCHAR(50),
    api_pattern VARCHAR(255),
    http_method VARCHAR(20),
    sort_num INT NOT NULL DEFAULT 0,
    visible TINYINT(1) NOT NULL DEFAULT 1,
    description VARCHAR(255),
    create_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_permission_code (permission_code)
);

CREATE TABLE IF NOT EXISTS user_role (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    create_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_role (user_id, role_id),
    CONSTRAINT fk_user_role_user FOREIGN KEY (user_id) REFERENCES `user` (id) ON DELETE CASCADE,
    CONSTRAINT fk_user_role_role FOREIGN KEY (role_id) REFERENCES role (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS role_permission (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    create_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_role_permission (role_id, permission_id),
    CONSTRAINT fk_role_permission_role FOREIGN KEY (role_id) REFERENCES role (id) ON DELETE CASCADE,
    CONSTRAINT fk_role_permission_permission FOREIGN KEY (permission_id) REFERENCES permission (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS login_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_name VARCHAR(50) NOT NULL,
    login_status VARCHAR(20) NOT NULL,
    login_ip VARCHAR(64),
    login_message VARCHAR(255),
    login_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO role (role_code, role_name, role_description, sort_num, enabled)
SELECT 'ADMIN', 'Administrator', 'System administrator role', 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM role WHERE role_code = 'ADMIN'
);

INSERT INTO role (role_code, role_name, role_description, sort_num, enabled)
SELECT 'USER', 'Normal User', 'Default user role', 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM role WHERE role_code = 'USER'
);

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key, route_path,
    component_path, icon, api_pattern, http_method, sort_num, visible, description
)
SELECT 'menu:dashboard', 'Dashboard', 'MENU', 0, 'dashboard', '/dashboard', 'dashboard', 'dashboard', NULL, NULL, 1, 1, 'Dashboard menu'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'menu:dashboard');

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key, route_path,
    component_path, icon, api_pattern, http_method, sort_num, visible, description
)
SELECT 'menu:profile', 'Profile', 'MENU', 0, 'profile', '/profile', 'profile', 'profile', NULL, NULL, 2, 1, 'Current user profile menu'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'menu:profile');

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key, route_path,
    component_path, icon, api_pattern, http_method, sort_num, visible, description
)
SELECT 'menu:user', 'User Management', 'MENU', 0, 'user', '/users', 'user', 'user', NULL, NULL, 10, 1, 'User management menu'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'menu:user');

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key, route_path,
    component_path, icon, api_pattern, http_method, sort_num, visible, description
)
SELECT 'menu:role', 'Role Management', 'MENU', 0, 'role', '/roles', 'role', 'role', NULL, NULL, 11, 1, 'Role management menu'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'menu:role');

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key, route_path,
    component_path, icon, api_pattern, http_method, sort_num, visible, description
)
SELECT 'menu:permission', 'Permission Management', 'MENU', 0, 'permission', '/permissions', 'permission', 'permission', NULL, NULL, 12, 1, 'Permission management menu'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'menu:permission');

INSERT INTO permission (
    permission_code, permission_name, permission_type, parent_id, menu_key, route_path,
    component_path, icon, api_pattern, http_method, sort_num, visible, description
)
SELECT 'menu:log', 'Login Logs', 'MENU', 0, 'log', '/login-logs', 'log', 'log', NULL, NULL, 13, 1, 'Login log menu'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'menu:log');

INSERT INTO permission (permission_code, permission_name, permission_type, parent_id, api_pattern, http_method, sort_num, visible, description)
SELECT 'sys:user:view', 'View Users', 'API', (SELECT id FROM permission WHERE permission_code = 'menu:user'), '/api/users/**', 'GET', 101, 1, 'View users'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'sys:user:view');

INSERT INTO permission (permission_code, permission_name, permission_type, parent_id, api_pattern, http_method, sort_num, visible, description)
SELECT 'sys:user:create', 'Create User', 'API', (SELECT id FROM permission WHERE permission_code = 'menu:user'), '/api/users', 'POST', 102, 1, 'Create users'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'sys:user:create');

INSERT INTO permission (permission_code, permission_name, permission_type, parent_id, api_pattern, http_method, sort_num, visible, description)
SELECT 'sys:user:update', 'Update User', 'API', (SELECT id FROM permission WHERE permission_code = 'menu:user'), '/api/users/**', 'PUT', 103, 1, 'Update users'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'sys:user:update');

INSERT INTO permission (permission_code, permission_name, permission_type, parent_id, api_pattern, http_method, sort_num, visible, description)
SELECT 'sys:user:delete', 'Delete User', 'API', (SELECT id FROM permission WHERE permission_code = 'menu:user'), '/api/users/**', 'DELETE', 104, 1, 'Delete users'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'sys:user:delete');

INSERT INTO permission (permission_code, permission_name, permission_type, parent_id, api_pattern, http_method, sort_num, visible, description)
SELECT 'sys:role:view', 'View Roles', 'API', (SELECT id FROM permission WHERE permission_code = 'menu:role'), '/api/roles/**', 'GET', 201, 1, 'View roles'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'sys:role:view');

INSERT INTO permission (permission_code, permission_name, permission_type, parent_id, api_pattern, http_method, sort_num, visible, description)
SELECT 'sys:role:create', 'Create Role', 'API', (SELECT id FROM permission WHERE permission_code = 'menu:role'), '/api/roles', 'POST', 202, 1, 'Create roles'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'sys:role:create');

INSERT INTO permission (permission_code, permission_name, permission_type, parent_id, api_pattern, http_method, sort_num, visible, description)
SELECT 'sys:role:update', 'Update Role', 'API', (SELECT id FROM permission WHERE permission_code = 'menu:role'), '/api/roles/**', 'PUT', 203, 1, 'Update roles'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'sys:role:update');

INSERT INTO permission (permission_code, permission_name, permission_type, parent_id, api_pattern, http_method, sort_num, visible, description)
SELECT 'sys:role:delete', 'Delete Role', 'API', (SELECT id FROM permission WHERE permission_code = 'menu:role'), '/api/roles/**', 'DELETE', 204, 1, 'Delete roles'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'sys:role:delete');

INSERT INTO permission (permission_code, permission_name, permission_type, parent_id, api_pattern, http_method, sort_num, visible, description)
SELECT 'sys:permission:view', 'View Permissions', 'API', (SELECT id FROM permission WHERE permission_code = 'menu:permission'), '/api/permissions/**', 'GET', 301, 1, 'View permissions'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'sys:permission:view');

INSERT INTO permission (permission_code, permission_name, permission_type, parent_id, api_pattern, http_method, sort_num, visible, description)
SELECT 'sys:permission:create', 'Create Permission', 'API', (SELECT id FROM permission WHERE permission_code = 'menu:permission'), '/api/permissions', 'POST', 302, 1, 'Create permissions'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'sys:permission:create');

INSERT INTO permission (permission_code, permission_name, permission_type, parent_id, api_pattern, http_method, sort_num, visible, description)
SELECT 'sys:permission:update', 'Update Permission', 'API', (SELECT id FROM permission WHERE permission_code = 'menu:permission'), '/api/permissions/**', 'PUT', 303, 1, 'Update permissions'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'sys:permission:update');

INSERT INTO permission (permission_code, permission_name, permission_type, parent_id, api_pattern, http_method, sort_num, visible, description)
SELECT 'sys:permission:delete', 'Delete Permission', 'API', (SELECT id FROM permission WHERE permission_code = 'menu:permission'), '/api/permissions/**', 'DELETE', 304, 1, 'Delete permissions'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'sys:permission:delete');

INSERT INTO permission (permission_code, permission_name, permission_type, parent_id, api_pattern, http_method, sort_num, visible, description)
SELECT 'sys:log:view', 'View Login Logs', 'API', (SELECT id FROM permission WHERE permission_code = 'menu:log'), '/api/login-logs/**', 'GET', 401, 1, 'View login logs'
WHERE NOT EXISTS (SELECT 1 FROM permission WHERE permission_code = 'sys:log:view');

INSERT INTO `user` (user_name, user_pwd, user_header, user_phonenum, user_email, enabled, is_super_admin, last_login_time)
SELECT 'admin', '21232f297a57a5a743894a0e4a801fc3', NULL, NULL, NULL, 1, 1, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM `user` WHERE user_name = 'admin'
);

UPDATE `user`
SET is_super_admin = 1, enabled = 1
WHERE user_name = 'admin';

INSERT INTO user_role (user_id, role_id)
SELECT u.id, r.id
FROM `user` u
JOIN role r ON r.role_code = 'ADMIN'
WHERE u.user_name = 'admin'
  AND NOT EXISTS (
      SELECT 1
      FROM user_role ur
      WHERE ur.user_id = u.id
        AND ur.role_id = r.id
  );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
FROM role r
JOIN permission p
WHERE r.role_code = 'ADMIN'
  AND NOT EXISTS (
      SELECT 1
      FROM role_permission rp
      WHERE rp.role_id = r.id
        AND rp.permission_id = p.id
  );

INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
FROM role r
JOIN permission p
WHERE r.role_code = 'USER'
  AND p.permission_code IN ('menu:dashboard', 'menu:profile')
  AND NOT EXISTS (
      SELECT 1
      FROM role_permission rp
      WHERE rp.role_id = r.id
        AND rp.permission_id = p.id
  );
