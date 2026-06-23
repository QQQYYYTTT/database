SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;

/*!999999\- enable the sandbox mode */ 

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

DROP TABLE IF EXISTS `abnormal_access`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `abnormal_access` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) DEFAULT NULL,
  `abnormal_type` varchar(50) DEFAULT NULL,
  `severity` varchar(20) DEFAULT NULL,
  `detail` text DEFAULT NULL,
  `create_time` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `abnormal_access` WRITE;
/*!40000 ALTER TABLE `abnormal_access` DISABLE KEYS */;
/*!40000 ALTER TABLE `abnormal_access` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `access_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) DEFAULT NULL,
  `role_code` varchar(50) DEFAULT NULL,
  `operation_type` varchar(50) DEFAULT NULL,
  `table_name` varchar(100) DEFAULT NULL,
  `sensitive_columns` text DEFAULT NULL,
  `masking_applied` tinyint(4) DEFAULT NULL,
  `access_time` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `access_log` WRITE;
/*!40000 ALTER TABLE `access_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `access_log` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `class_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `class_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `major_id` bigint(20) DEFAULT NULL,
  `grade_id` bigint(20) DEFAULT NULL,
  `class_code` varchar(30) DEFAULT NULL,
  `class_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `class_code` (`class_code`) USING BTREE,
  KEY `major_id` (`major_id`) USING BTREE,
  KEY `grade_id` (`grade_id`) USING BTREE,
  CONSTRAINT `class_info_ibfk_1` FOREIGN KEY (`major_id`) REFERENCES `major` (`id`),
  CONSTRAINT `class_info_ibfk_2` FOREIGN KEY (`grade_id`) REFERENCES `grade_info` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `class_info` WRITE;
/*!40000 ALTER TABLE `class_info` DISABLE KEYS */;
INSERT INTO `class_info` VALUES
(1,1,1,'CS2301','计算机科学2301班'),
(2,2,1,'NS2301','网安2301班'),
(3,3,2,'EI2401','电子信息2401班'),
(4,4,3,'AI2501','人工智能2501班'),
(5,5,4,'LAW2601','法学2601班');
/*!40000 ALTER TABLE `class_info` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `college`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `college` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `college_code` varchar(30) DEFAULT NULL,
  `college_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `college_code` (`college_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `college` WRITE;
/*!40000 ALTER TABLE `college` DISABLE KEYS */;
INSERT INTO `college` VALUES
(1,'C01','计算机学院'),
(2,'C02','网络空间安全学院'),
(3,'C03','电子信息学院'),
(4,'C04','人工智能学院'),
(5,'C05','法学院');
/*!40000 ALTER TABLE `college` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `course` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `course_code` varchar(30) DEFAULT NULL,
  `course_name` varchar(100) DEFAULT NULL,
  `credit` decimal(4,1) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `course_code` (`course_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `course` WRITE;
/*!40000 ALTER TABLE `course` DISABLE KEYS */;
INSERT INTO `course` VALUES
(1,'C001','数据结构',4.0),
(2,'C002','操作系统',3.5),
(3,'C003','计算机网络',3.5),
(4,'C004','数据库系统',4.0),
(5,'C005','信息安全导论',3.0);
/*!40000 ALTER TABLE `course` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `grade_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `grade_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `grade_name` varchar(30) DEFAULT NULL,
  `entry_year` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `grade_name` (`grade_name`) USING BTREE,
  UNIQUE KEY `entry_year` (`entry_year`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `grade_info` WRITE;
/*!40000 ALTER TABLE `grade_info` DISABLE KEYS */;
INSERT INTO `grade_info` VALUES
(1,'2023级',2023),
(2,'2024级',2024),
(3,'2025级',2025),
(4,'2026级',2026),
(5,'2027级',2027);
/*!40000 ALTER TABLE `grade_info` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `login_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `login_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(50) NOT NULL,
  `login_status` varchar(20) NOT NULL,
  `login_ip` varchar(64) DEFAULT NULL,
  `login_message` varchar(255) DEFAULT NULL,
  `login_time` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `login_log` WRITE;
/*!40000 ALTER TABLE `login_log` DISABLE KEYS */;
INSERT INTO `login_log` VALUES
(1,'admin','SUCCESS','127.0.0.1','登录成功','2026-06-21 17:07:10'),
(2,'admin','SUCCESS','127.0.0.1','登录成功','2026-06-21 17:07:10'),
(3,'admin','SUCCESS','127.0.0.1','登录成功','2026-06-21 17:07:10'),
(4,'admin','SUCCESS','127.0.0.1','登录成功','2026-06-21 17:07:36'),
(5,'admin','FAIL','127.0.0.1','用户名或密码错误','2026-06-21 17:08:05'),
(6,'admin','SUCCESS','127.0.0.1','登录成功','2026-06-21 17:08:05'),
(7,'admin','SUCCESS','127.0.0.1','登录成功','2026-06-21 17:10:43'),
(8,'admin','SUCCESS','0:0:0:0:0:0:0:1','登录成功','2026-06-21 17:14:17'),
(9,'admin','SUCCESS','0:0:0:0:0:0:0:1','Login success','2026-06-21 18:34:39'),
(10,'admin','SUCCESS','0:0:0:0:0:0:0:1','Login success','2026-06-21 18:34:51'),
(11,'admin','SUCCESS','0:0:0:0:0:0:0:1','Login success','2026-06-21 18:38:47'),
(12,'lily','SUCCESS','0:0:0:0:0:0:0:1','Login success','2026-06-21 18:40:29'),
(13,'admin','SUCCESS','0:0:0:0:0:0:0:1','登录成功','2026-06-21 19:05:40'),
(14,'admin','SUCCESS','0:0:0:0:0:0:0:1','登录成功','2026-06-21 19:06:00'),
(15,'admin','SUCCESS','0:0:0:0:0:0:0:1','登录成功','2026-06-21 19:06:00'),
(16,'admin','SUCCESS','0:0:0:0:0:0:0:1','登录成功','2026-06-21 19:06:13'),
(17,'admin','SUCCESS','0:0:0:0:0:0:0:1','登录成功','2026-06-21 19:10:10'),
(18,'admin','SUCCESS','0:0:0:0:0:0:0:1','登录成功','2026-06-21 19:10:23'),
(19,'admin','SUCCESS','0:0:0:0:0:0:0:1','登录成功','2026-06-21 19:11:38'),
(20,'lily','SUCCESS','0:0:0:0:0:0:0:1','登录成功','2026-06-21 19:30:03');
/*!40000 ALTER TABLE `login_log` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `major`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `major` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `college_id` bigint(20) DEFAULT NULL,
  `major_code` varchar(30) DEFAULT NULL,
  `major_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `major_code` (`major_code`) USING BTREE,
  KEY `college_id` (`college_id`) USING BTREE,
  CONSTRAINT `major_ibfk_1` FOREIGN KEY (`college_id`) REFERENCES `college` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `major` WRITE;
/*!40000 ALTER TABLE `major` DISABLE KEYS */;
INSERT INTO `major` VALUES
(1,1,'M01','计算机科学与技术'),
(2,2,'M02','网络空间安全'),
(3,3,'M03','电子信息工程'),
(4,4,'M04','人工智能'),
(5,5,'M05','法学');
/*!40000 ALTER TABLE `major` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `masking_policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `masking_policy` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sensitive_field_id` bigint(20) DEFAULT NULL,
  `masking_type` varchar(50) DEFAULT NULL,
  `params` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`params`)),
  `is_default` tinyint(4) DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `sensitive_field_id` (`sensitive_field_id`) USING BTREE,
  KEY `masking_type` (`masking_type`) USING BTREE,
  CONSTRAINT `masking_policy_ibfk_1` FOREIGN KEY (`sensitive_field_id`) REFERENCES `sensitive_field` (`id`),
  CONSTRAINT `masking_policy_ibfk_2` FOREIGN KEY (`masking_type`) REFERENCES `masking_type_dict` (`type_code`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `masking_policy` WRITE;
/*!40000 ALTER TABLE `masking_policy` DISABLE KEYS */;
INSERT INTO `masking_policy` VALUES
(1,1,'FULL_MASK','{}',1),
(2,1,'NO_MASK','{}',0),
(3,1,'KEEP_PREFIX','{\"prefix\": 1}',0),
(4,2,'FULL_MASK','{}',1),
(5,2,'NO_MASK','{}',0),
(6,2,'KEEP_YEAR','{}',0),
(7,3,'FULL_MASK','{}',1),
(8,3,'NO_MASK','{}',0),
(9,3,'KEEP_PREFIX_SUFFIX','{\"prefix\": 3, \"suffix\": 4}',0),
(10,4,'FULL_MASK','{}',1),
(11,4,'NO_MASK','{}',0),
(12,4,'EMAIL_MASK','{}',0),
(13,5,'FULL_MASK','{}',1),
(14,5,'NO_MASK','{}',0),
(15,5,'KEEP_PREFIX_SUFFIX','{\"prefix\": 6, \"suffix\": 4}',0),
(16,6,'FULL_MASK','{}',1),
(17,6,'NO_MASK','{}',0),
(18,6,'ADDRESS_LEVEL','{\"level\": \"city\"}',0),
(19,6,'ADDRESS_LEVEL','{\"level\": \"province\"}',0),
(20,7,'FULL_MASK','{}',1),
(21,7,'NO_MASK','{}',0),
(22,7,'GENERALIZATION','{\"step\": 10000}',0),
(23,8,'FULL_MASK','{}',1),
(24,8,'NO_MASK','{}',0),
(25,8,'KEEP_SUFFIX','{\"suffix\": 4}',0),
(32,9,'FULL_MASK','{}',1),
(33,9,'NO_MASK','{}',0),
(34,9,'GENERALIZATION','{\"step\": 10}',0);
/*!40000 ALTER TABLE `masking_policy` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `masking_rule_assignment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `masking_rule_assignment` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `role_id` bigint(20) DEFAULT NULL,
  `policy_id` bigint(20) DEFAULT NULL,
  `enabled` tinyint(4) DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `role_id` (`role_id`,`policy_id`) USING BTREE,
  KEY `policy_id` (`policy_id`) USING BTREE,
  CONSTRAINT `fk_masking_rule_assignment_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`),
  CONSTRAINT `masking_rule_assignment_ibfk_2` FOREIGN KEY (`policy_id`) REFERENCES `masking_policy` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `masking_rule_assignment` WRITE;
/*!40000 ALTER TABLE `masking_rule_assignment` DISABLE KEYS */;
INSERT INTO `masking_rule_assignment` VALUES
(1,3,2,1),
(2,3,5,1),
(3,3,8,1),
(4,3,11,1),
(5,3,14,1),
(6,3,17,1),
(7,3,21,1),
(8,3,24,1),
(9,4,2,1),
(10,4,5,1),
(11,4,8,1),
(12,4,11,1),
(13,4,14,1),
(14,4,17,1),
(15,4,21,1),
(16,4,24,1),
(17,5,3,1),
(18,5,6,1),
(19,5,9,1),
(20,5,12,1),
(21,5,15,1),
(22,5,18,1),
(23,5,22,1),
(24,5,25,1),
(25,6,3,1),
(26,6,6,1),
(27,6,9,1),
(28,6,12,1),
(29,6,13,1),
(30,6,19,1),
(31,6,22,1),
(32,6,23,1),
(64,8,2,1),
(65,8,5,1),
(66,8,8,1),
(67,8,11,1),
(68,8,14,1),
(69,8,17,1),
(70,8,21,1),
(71,8,24,1),
(72,3,33,1),
(73,4,33,1),
(74,5,33,1),
(75,6,34,1),
(76,8,33,1);
/*!40000 ALTER TABLE `masking_rule_assignment` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `masking_type_dict`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `masking_type_dict` (
  `type_code` varchar(50) NOT NULL,
  `type_name` varchar(100) DEFAULT NULL,
  `param_schema` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`param_schema`)),
  PRIMARY KEY (`type_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `masking_type_dict` WRITE;
/*!40000 ALTER TABLE `masking_type_dict` DISABLE KEYS */;
INSERT INTO `masking_type_dict` VALUES
('ADDRESS_LEVEL','地址层级脱敏','{\"level\": \"string\"}'),
('EMAIL_MASK','邮箱脱敏','{\"description\": \"保留首字符和域名\"}'),
('FULL_MASK','完全遮蔽','{\"description\": \"使用星号完全遮蔽\"}'),
('GENERALIZATION','区间泛化','{\"step\": \"number\"}'),
('HASH_MASK','哈希脱敏','{\"salt\": \"string\", \"algorithm\": \"string\", \"description\": \"使用指定哈希算法生成不可逆摘要\"}'),
('KEEP_PREFIX','保留前缀','{\"prefix\": \"integer\"}'),
('KEEP_PREFIX_SUFFIX','保留前后缀','{\"prefix\": \"integer\", \"suffix\": \"integer\"}'),
('KEEP_SUFFIX','保留后缀','{\"suffix\": \"integer\"}'),
('KEEP_YEAR','仅保留年份','{\"description\": \"日期仅保留年份\"}'),
('NONE','不脱敏','{\"description\": \"返回原始数据，不进行脱敏\"}'),
('NO_MASK','不脱敏','{\"description\": \"返回原始数据\"}'),
('NULL_MASK','置空脱敏','{\"description\": \"将敏感字段返回为空值\"}'),
('PARTIAL_MASK','部分遮盖','{\"mask_char\": \"string\", \"description\": \"保留前后部分字符，中间字符进行遮盖\", \"prefix_keep\": \"integer\", \"suffix_keep\": \"integer\"}'),
('RANGE_MASK','区间泛化','{\"range_size\": \"number\", \"description\": \"将数值转换为所属区间\"}');
/*!40000 ALTER TABLE `masking_type_dict` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permission` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `permission_code` varchar(100) NOT NULL,
  `permission_name` varchar(100) NOT NULL,
  `permission_type` varchar(20) NOT NULL,
  `parent_id` bigint(20) NOT NULL DEFAULT 0,
  `menu_key` varchar(50) DEFAULT NULL,
  `route_path` varchar(120) DEFAULT NULL,
  `component_path` varchar(120) DEFAULT NULL,
  `icon` varchar(50) DEFAULT NULL,
  `api_pattern` varchar(255) DEFAULT NULL,
  `http_method` varchar(20) DEFAULT NULL,
  `sort_num` int(11) NOT NULL DEFAULT 0,
  `visible` tinyint(1) NOT NULL DEFAULT 1,
  `description` varchar(255) DEFAULT NULL,
  `create_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_permission_code` (`permission_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `permission` WRITE;
/*!40000 ALTER TABLE `permission` DISABLE KEYS */;
INSERT INTO `permission` VALUES
(1,'menu:dashboard','Dashboard','MENU',0,'dashboard','/dashboard','dashboard','dashboard',NULL,NULL,1,1,'Dashboard menu','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(2,'menu:profile','Profile','MENU',0,'profile','/profile','profile','profile',NULL,NULL,2,1,'Current user profile menu','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(3,'menu:user','User Management','MENU',0,'user','/users','user','user',NULL,NULL,10,1,'User management menu','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(4,'menu:role','Role Management','MENU',0,'role','/roles','role','role',NULL,NULL,11,1,'Role management menu','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(5,'menu:permission','Permission Management','MENU',0,'permission','/permissions','permission','permission',NULL,NULL,12,1,'Permission management menu','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(6,'menu:log','Login Logs','MENU',0,'log','/login-logs','log','log',NULL,NULL,13,1,'Login log menu','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(7,'sys:user:view','View Users','API',3,NULL,NULL,NULL,NULL,'/api/users/**','GET',101,1,'View users','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(8,'sys:user:create','Create User','API',3,NULL,NULL,NULL,NULL,'/api/users','POST',102,1,'Create users','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(9,'sys:user:update','Update User','API',3,NULL,NULL,NULL,NULL,'/api/users/**','PUT',103,1,'Update users','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(10,'sys:user:delete','Delete User','API',3,NULL,NULL,NULL,NULL,'/api/users/**','DELETE',104,1,'Delete users','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(11,'sys:role:view','View Roles','API',4,NULL,NULL,NULL,NULL,'/api/roles/**','GET',201,1,'View roles','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(12,'sys:role:create','Create Role','API',4,NULL,NULL,NULL,NULL,'/api/roles','POST',202,1,'Create roles','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(13,'sys:role:update','Update Role','API',4,NULL,NULL,NULL,NULL,'/api/roles/**','PUT',203,1,'Update roles','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(14,'sys:role:delete','Delete Role','API',4,NULL,NULL,NULL,NULL,'/api/roles/**','DELETE',204,1,'Delete roles','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(15,'sys:permission:view','View Permissions','API',5,NULL,NULL,NULL,NULL,'/api/permissions/**','GET',301,1,'View permissions','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(16,'sys:permission:create','Create Permission','API',5,NULL,NULL,NULL,NULL,'/api/permissions','POST',302,1,'Create permissions','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(17,'sys:permission:update','Update Permission','API',5,NULL,NULL,NULL,NULL,'/api/permissions/**','PUT',303,1,'Update permissions','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(18,'sys:permission:delete','Delete Permission','API',5,NULL,NULL,NULL,NULL,'/api/permissions/**','DELETE',304,1,'Delete permissions','2026-06-21 18:33:32','2026-06-21 18:33:32'),
(19,'sys:log:view','View Login Logs','API',6,NULL,NULL,NULL,NULL,'/api/login-logs/**','GET',401,1,'View login logs','2026-06-21 18:33:32','2026-06-21 18:33:32');
/*!40000 ALTER TABLE `permission` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `role_code` varchar(50) NOT NULL,
  `role_name` varchar(100) NOT NULL,
  `role_description` varchar(255) DEFAULT NULL,
  `sort_num` int(11) NOT NULL DEFAULT 0,
  `enabled` tinyint(1) NOT NULL DEFAULT 1,
  `create_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_role_code` (`role_code`) USING BTREE,
  UNIQUE KEY `uk_role_name` (`role_name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES
(1,'ADMIN','Administrator','System administrator role',1,1,'2026-06-21 18:33:32','2026-06-21 18:33:32'),
(2,'USER','Normal User','Default user role',2,1,'2026-06-21 18:33:32','2026-06-21 18:33:32'),
(3,'SUPER_ADMIN','Super Admin','动态脱敏：超级管理员，可查看原始敏感数据',101,1,'2026-06-21 21:35:29','2026-06-21 21:35:29'),
(4,'DATA_ADMIN','Data Admin','动态脱敏：数据管理员，可查看原始敏感数据',102,1,'2026-06-21 21:35:29','2026-06-21 21:35:29'),
(5,'TEACHER','Teacher','动态脱敏：教师，按教学场景部分脱敏',103,1,'2026-06-21 21:35:29','2026-06-21 21:35:29'),
(6,'ANALYST','Analyst','动态脱敏：分析师，按统计分析场景脱敏/泛化',104,1,'2026-06-21 21:35:29','2026-06-21 21:35:29'),
(7,'NORMAL','Normal','动态脱敏：普通用户，使用高强度默认脱敏',105,1,'2026-06-21 21:35:29','2026-06-21 21:35:29'),
(8,'STUDENT','Student','动态脱敏：学生查看本人信息与成绩',106,1,'2026-06-21 22:38:54','2026-06-21 22:38:54');
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `role_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role_permission` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `role_id` bigint(20) NOT NULL,
  `permission_id` bigint(20) NOT NULL,
  `create_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_role_permission` (`role_id`,`permission_id`) USING BTREE,
  KEY `fk_role_permission_permission` (`permission_id`) USING BTREE,
  CONSTRAINT `fk_role_permission_permission` FOREIGN KEY (`permission_id`) REFERENCES `permission` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_role_permission_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `role_permission` WRITE;
/*!40000 ALTER TABLE `role_permission` DISABLE KEYS */;
INSERT INTO `role_permission` VALUES
(1,1,1,'2026-06-21 18:33:32'),
(2,1,6,'2026-06-21 18:33:32'),
(3,1,5,'2026-06-21 18:33:32'),
(4,1,2,'2026-06-21 18:33:32'),
(5,1,4,'2026-06-21 18:33:32'),
(6,1,3,'2026-06-21 18:33:32'),
(7,1,19,'2026-06-21 18:33:32'),
(8,1,16,'2026-06-21 18:33:32'),
(9,1,18,'2026-06-21 18:33:32'),
(10,1,17,'2026-06-21 18:33:32'),
(11,1,15,'2026-06-21 18:33:32'),
(12,1,12,'2026-06-21 18:33:32'),
(13,1,14,'2026-06-21 18:33:32'),
(14,1,13,'2026-06-21 18:33:32'),
(15,1,11,'2026-06-21 18:33:32'),
(16,1,8,'2026-06-21 18:33:32'),
(17,1,10,'2026-06-21 18:33:32'),
(18,1,9,'2026-06-21 18:33:32'),
(19,1,7,'2026-06-21 18:33:32'),
(32,2,1,'2026-06-21 18:33:32'),
(33,2,2,'2026-06-21 18:33:32');
/*!40000 ALTER TABLE `role_permission` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `rule_change_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rule_change_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `policy_id` bigint(20) DEFAULT NULL,
  `operator_name` varchar(50) DEFAULT NULL,
  `operation_type` varchar(50) DEFAULT NULL,
  `before_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`before_content`)),
  `after_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`after_content`)),
  `operate_time` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `rule_change_log` WRITE;
/*!40000 ALTER TABLE `rule_change_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `rule_change_log` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `semester_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `semester_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `school_year` varchar(20) DEFAULT NULL,
  `term_no` tinyint(4) DEFAULT NULL,
  `semester_name` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `semester_name` (`semester_name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `semester_info` WRITE;
/*!40000 ALTER TABLE `semester_info` DISABLE KEYS */;
INSERT INTO `semester_info` VALUES
(1,'2023-2024',1,'2023秋'),
(2,'2023-2024',2,'2024春'),
(3,'2024-2025',1,'2024秋'),
(4,'2024-2025',2,'2025春'),
(5,'2025-2026',1,'2025秋');
/*!40000 ALTER TABLE `semester_info` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `sensitive_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sensitive_field` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `table_name` varchar(100) DEFAULT NULL,
  `column_name` varchar(100) DEFAULT NULL,
  `sensitive_type` varchar(50) DEFAULT NULL,
  `sensitive_level` varchar(20) DEFAULT NULL,
  `enabled` tinyint(4) DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `table_name` (`table_name`,`column_name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `sensitive_field` WRITE;
/*!40000 ALTER TABLE `sensitive_field` DISABLE KEYS */;
INSERT INTO `sensitive_field` VALUES
(1,'v_student_profile','name','NAME','MEDIUM',1),
(2,'v_student_profile','birth_date','BIRTH_DATE','HIGH',1),
(3,'v_student_profile','phone','PHONE','HIGH',1),
(4,'v_student_profile','email','EMAIL','HIGH',1),
(5,'v_student_profile','id_card','ID_CARD','HIGH',1),
(6,'v_student_profile','address','ADDRESS','HIGH',1),
(7,'v_student_profile','family_income','INCOME','HIGH',1),
(8,'v_student_profile','bank_card','BANK_CARD','HIGH',1),
(9,'v_student_score_detail','score','SCORE','HIGH',1);
/*!40000 ALTER TABLE `sensitive_field` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `student`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `class_id` bigint(20) DEFAULT NULL,
  `student_no` varchar(30) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `gender` char(1) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `status` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `student_no` (`student_no`) USING BTREE,
  KEY `class_id` (`class_id`) USING BTREE,
  CONSTRAINT `student_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `class_info` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `student` WRITE;
/*!40000 ALTER TABLE `student` DISABLE KEYS */;
INSERT INTO `student` VALUES
(1,1,'2023001','张伟','M','2005-03-12',1),
(2,2,'2023002','李娜','F','2005-06-21',1),
(3,3,'2024001','王强','M','2006-01-18',1),
(4,4,'2025001','赵敏','F','2007-02-10',1),
(5,5,'2026001','陈浩','M','2008-09-05',1);
/*!40000 ALTER TABLE `student` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `student_score`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student_score` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `student_id` bigint(20) DEFAULT NULL,
  `course_id` bigint(20) DEFAULT NULL,
  `semester_id` bigint(20) DEFAULT NULL,
  `score` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `student_id` (`student_id`,`course_id`,`semester_id`) USING BTREE,
  KEY `course_id` (`course_id`) USING BTREE,
  KEY `semester_id` (`semester_id`) USING BTREE,
  CONSTRAINT `student_score_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `student` (`id`),
  CONSTRAINT `student_score_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`),
  CONSTRAINT `student_score_ibfk_3` FOREIGN KEY (`semester_id`) REFERENCES `semester_info` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `student_score` WRITE;
/*!40000 ALTER TABLE `student_score` DISABLE KEYS */;
INSERT INTO `student_score` VALUES
(1,1,1,1,92.50),
(2,2,2,2,88.00),
(3,3,3,3,90.00),
(4,4,4,4,85.50),
(5,5,5,5,93.00);
/*!40000 ALTER TABLE `student_score` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `student_sensitive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student_sensitive` (
  `student_id` bigint(20) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `id_card` varchar(30) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `family_income` decimal(10,2) DEFAULT NULL,
  `bank_card` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`student_id`) USING BTREE,
  CONSTRAINT `student_sensitive_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `student` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `student_sensitive` WRITE;
/*!40000 ALTER TABLE `student_sensitive` DISABLE KEYS */;
INSERT INTO `student_sensitive` VALUES
(1,'13800000001','zhangwei@edu.com','510101200503120011','成都高新区',120000.00,'6222020000000001'),
(2,'13800000002','lina@edu.com','510101200506210022','成都武侯区',98000.00,'6222020000000002'),
(3,'13800000003','wangqiang@edu.com','510101200601180033','成都锦江区',150000.00,'6222020000000003'),
(4,'13800000004','zhaomin@edu.com','510101200702100044','成都成华区',110000.00,'6222020000000004'),
(5,'13800000005','chenhao@edu.com','510101200809050055','成都双流区',130000.00,'6222020000000005');
/*!40000 ALTER TABLE `student_sensitive` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `test` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `age` int(11) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `created_time` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `test` WRITE;
/*!40000 ALTER TABLE `test` DISABLE KEYS */;
INSERT INTO `test` VALUES
(1,'demo',20,'demo@example.com','2026-06-21 14:33:32','2026-06-21 14:33:32');
/*!40000 ALTER TABLE `test` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(50) NOT NULL,
  `user_pwd` varchar(255) NOT NULL,
  `user_header` varchar(255) DEFAULT NULL,
  `user_phonenum` varchar(20) DEFAULT NULL,
  `user_email` varchar(100) DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 1,
  `is_super_admin` tinyint(1) NOT NULL DEFAULT 0,
  `create_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_login_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_user_user_name` (`user_name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES
(1,'admin','$2a$10$wKXbyzf.TQ5u9/EoZ//H0.eT7rj2sOgOjbXQjDiBcou8aO7A/tAGq',NULL,NULL,NULL,1,1,'2026-06-21 14:54:38','2026-06-21 19:11:37','2026-06-21 19:11:37'),
(5,'lily','$2a$10$ybsmLwBcGNvPf1HuXjIkbOmLwrl7wlyWntAe4R/1UQgsfUtREqJMi',NULL,'13145678900',NULL,1,0,'2026-06-21 17:15:08','2026-06-21 19:30:03','2026-06-21 19:30:03');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_role` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `role_id` bigint(20) NOT NULL,
  `create_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_user_role` (`user_id`,`role_id`) USING BTREE,
  KEY `fk_user_role_role` (`role_id`) USING BTREE,
  CONSTRAINT `fk_user_role_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_role_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `user_role` WRITE;
/*!40000 ALTER TABLE `user_role` DISABLE KEYS */;
INSERT INTO `user_role` VALUES
(1,1,1,'2026-06-21 18:33:32'),
(2,5,2,'2026-06-21 18:40:06');
/*!40000 ALTER TABLE `user_role` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `v_student_profile`;
/*!50001 DROP VIEW IF EXISTS `v_student_profile`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_student_profile` AS SELECT
 1 AS `student_id`,
  1 AS `student_no`,
  1 AS `name`,
  1 AS `gender`,
  1 AS `birth_date`,
  1 AS `status`,
  1 AS `class_name`,
  1 AS `grade_name`,
  1 AS `entry_year`,
  1 AS `major_name`,
  1 AS `college_name`,
  1 AS `phone`,
  1 AS `email`,
  1 AS `id_card`,
  1 AS `address`,
  1 AS `family_income`,
  1 AS `bank_card` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `v_student_score_detail`;
/*!50001 DROP VIEW IF EXISTS `v_student_score_detail`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_student_score_detail` AS SELECT
 1 AS `score_id`,
  1 AS `student_id`,
  1 AS `student_no`,
  1 AS `student_name`,
  1 AS `course_code`,
  1 AS `course_name`,
  1 AS `semester_name`,
  1 AS `score`,
  1 AS `score_level` */;
SET character_set_client = @saved_cs_client;

/*!50001 DROP VIEW IF EXISTS `v_student_profile`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_student_profile` AS select `s`.`id` AS `student_id`,`s`.`student_no` AS `student_no`,`s`.`name` AS `name`,`s`.`gender` AS `gender`,`s`.`birth_date` AS `birth_date`,`s`.`status` AS `status`,`ci`.`class_name` AS `class_name`,`gi`.`grade_name` AS `grade_name`,`gi`.`entry_year` AS `entry_year`,`m`.`major_name` AS `major_name`,`c`.`college_name` AS `college_name`,`ss`.`phone` AS `phone`,`ss`.`email` AS `email`,`ss`.`id_card` AS `id_card`,`ss`.`address` AS `address`,`ss`.`family_income` AS `family_income`,`ss`.`bank_card` AS `bank_card` from (((((`student` `s` join `class_info` `ci` on(`ci`.`id` = `s`.`class_id`)) join `grade_info` `gi` on(`gi`.`id` = `ci`.`grade_id`)) join `major` `m` on(`m`.`id` = `ci`.`major_id`)) join `college` `c` on(`c`.`id` = `m`.`college_id`)) left join `student_sensitive` `ss` on(`ss`.`student_id` = `s`.`id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_student_score_detail`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_student_score_detail` AS select `sc`.`id` AS `score_id`,`s`.`id` AS `student_id`,`s`.`student_no` AS `student_no`,`s`.`name` AS `student_name`,`co`.`course_code` AS `course_code`,`co`.`course_name` AS `course_name`,`sem`.`semester_name` AS `semester_name`,`sc`.`score` AS `score`,case when `sc`.`score` >= 90 then 'A' when `sc`.`score` >= 80 then 'B' when `sc`.`score` >= 70 then 'C' when `sc`.`score` >= 60 then 'D' else 'E' end AS `score_level` from (((`student_score` `sc` join `student` `s` on(`s`.`id` = `sc`.`student_id`)) join `course` `co` on(`co`.`id` = `sc`.`course_id`)) join `semester_info` `sem` on(`sem`.`id` = `sc`.`semester_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;
SET UNIQUE_CHECKS = 1;
SET FOREIGN_KEY_CHECKS = 1;
