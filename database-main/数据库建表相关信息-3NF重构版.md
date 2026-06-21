# 数据库建表相关信息 - 3NF重构版

> 项目名称：基于 RBAC 的高校学生信息动态脱敏系统
> 
> 目标：在保证动态脱敏、RBAC、审计闭环的前提下，对业务主数据做严格规范化设计，使核心业务表尽量符合第三范式（3NF）

---

## 一、为什么要重构

当前版本更像“能演示动态脱敏流程的 Demo”，但从数据库课程设计角度，业务主数据还不够规范。

最典型的问题有三类：

1. `student_info` 同时保存 `college`、`major`、`grade`、`class_name`
   这会形成传递依赖，不符合严格 3NF。

2. `student_score` 直接保存 `course_name`、`semester`
   课程和学期本身是独立业务对象，直接放文本字段会带来更新异常。

3. `masking_rule_assignment` 里的 `sensitive_field_id`
   可通过 `policy_id -> masking_policy -> sensitive_field_id` 推出，属于冗余设计。

因此，本版重构原则是：

- 业务主数据严格规范化
- 审计日志允许保留快照冗余
- 动态脱敏查询通过“视图层”兼容规范化后的底层结构

---

## 二、重构后的总体结构

建议拆分为四大部分：

1. RBAC 权限体系
2. 业务主数据体系
3. 脱敏配置体系
4. 审计与异常检测体系

其中，数据库课程设计的重点放在“业务主数据体系”的规范化。

---

## 三、业务主数据体系（3NF核心）

### 3.1 学院表 `college`

```sql
CREATE TABLE college (
    id           BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '学院ID',
    college_code VARCHAR(30) NOT NULL UNIQUE       COMMENT '学院编码',
    college_name VARCHAR(100) NOT NULL UNIQUE      COMMENT '学院名称',
    status       TINYINT NOT NULL DEFAULT 1        COMMENT '状态：1启用，0停用'
) COMMENT='学院表';
```

说明：

- 学院是独立实体，不能直接作为学生表中的普通文本字段保存

### 3.2 专业表 `major`

```sql
CREATE TABLE major (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '专业ID',
    college_id  BIGINT NOT NULL                   COMMENT '所属学院ID',
    major_code  VARCHAR(30) NOT NULL UNIQUE       COMMENT '专业编码',
    major_name  VARCHAR(100) NOT NULL             COMMENT '专业名称',
    status      TINYINT NOT NULL DEFAULT 1        COMMENT '状态：1启用，0停用',

    CONSTRAINT fk_major_college
        FOREIGN KEY (college_id) REFERENCES college(id)
) COMMENT='专业表';
```

说明：

- 专业从属于学院
- `major -> college` 是清晰的函数依赖

### 3.3 年级表 `grade_info`

```sql
CREATE TABLE grade_info (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '年级ID',
    grade_name  VARCHAR(30) NOT NULL UNIQUE       COMMENT '年级名称，如2023级',
    entry_year  INT NOT NULL UNIQUE               COMMENT '入学年份，如2023',
    status      TINYINT NOT NULL DEFAULT 1        COMMENT '状态：1启用，0停用'
) COMMENT='年级表';
```

说明：

- `grade` 也建议实体化，而不是直接在学生表中保存字符串
- 如果想进一步简化，也可以只保留 `entry_year`，但课程设计里单独建表更利于表达业务结构

### 3.4 班级表 `class_info`

```sql
CREATE TABLE class_info (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '班级ID',
    major_id    BIGINT NOT NULL                   COMMENT '所属专业ID',
    grade_id    BIGINT NOT NULL                   COMMENT '所属年级ID',
    class_code  VARCHAR(30) NOT NULL UNIQUE       COMMENT '班级编码',
    class_name  VARCHAR(100) NOT NULL             COMMENT '班级名称',
    status      TINYINT NOT NULL DEFAULT 1        COMMENT '状态：1启用，0停用',

    CONSTRAINT fk_class_major
        FOREIGN KEY (major_id) REFERENCES major(id),
    CONSTRAINT fk_class_grade
        FOREIGN KEY (grade_id) REFERENCES grade_info(id),
    CONSTRAINT uk_class_major_grade_name
        UNIQUE (major_id, grade_id, class_name)
) COMMENT='班级表';
```

说明：

- 表名不用 `class`，避免保留字问题
- 采用 `class_info` 更稳
- 班级依赖于“专业 + 年级”

### 3.5 学生基本信息表 `student`

```sql
CREATE TABLE student (
    id           BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '学生ID',
    class_id     BIGINT NOT NULL                   COMMENT '班级ID',
    student_no   VARCHAR(30) NOT NULL UNIQUE       COMMENT '学号',
    name         VARCHAR(50) NOT NULL              COMMENT '姓名',
    gender       CHAR(1)                           COMMENT '性别：M/F/U',
    birth_date   DATE                              COMMENT '出生日期',
    status       TINYINT NOT NULL DEFAULT 0        COMMENT '状态：0在读，1休学，2毕业',

    CONSTRAINT fk_student_class
        FOREIGN KEY (class_id) REFERENCES class_info(id)
) COMMENT='学生基本信息表';
```

说明：

- `student_no` 必须唯一
- `status` 明确语义：
  - `0` 在读
  - `1` 休学
  - `2` 毕业
- 学生表只保存学生自身属性和 `class_id`
- 不再冗余保存学院、专业、年级、班级名称

### 3.6 学生敏感信息表 `student_sensitive`

```sql
CREATE TABLE student_sensitive (
    student_id      BIGINT PRIMARY KEY             COMMENT '学生ID',
    phone           VARCHAR(20)                    COMMENT '手机号',
    email           VARCHAR(100)                   COMMENT '邮箱',
    id_card         VARCHAR(30)                    COMMENT '身份证号',
    address         VARCHAR(255)                   COMMENT '家庭住址',
    family_income   DECIMAL(10,2)                  COMMENT '家庭年收入',
    bank_card       VARCHAR(30)                    COMMENT '银行卡号',

    CONSTRAINT fk_student_sensitive_student
        FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE
) COMMENT='学生敏感信息表';
```

说明：

- `phone` 统一使用字符串类型，避免前导 0 被截断
- 将敏感信息单独拆出，对数据库课和信息安全课两个角度都更合理
- `student` 与 `student_sensitive` 为 1:1 关系

### 3.7 课程表 `course`

```sql
CREATE TABLE course (
    id           BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '课程ID',
    course_code  VARCHAR(30) NOT NULL UNIQUE       COMMENT '课程编码',
    course_name  VARCHAR(100) NOT NULL             COMMENT '课程名称',
    credit       DECIMAL(4,1)                      COMMENT '学分',
    status       TINYINT NOT NULL DEFAULT 1        COMMENT '状态：1启用，0停用'
) COMMENT='课程表';
```

说明：

- `student_score` 不应直接存 `course_name`
- 应通过 `course_id` 关联课程实体

### 3.8 学期表 `semester_info`

```sql
CREATE TABLE semester_info (
    id            BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '学期ID',
    school_year   VARCHAR(20) NOT NULL              COMMENT '学年，如2024-2025',
    term_no       TINYINT NOT NULL                  COMMENT '学期号：1/2/3',
    semester_name VARCHAR(30) NOT NULL UNIQUE       COMMENT '学期名称，如2024-2025-1',
    status        TINYINT NOT NULL DEFAULT 1        COMMENT '状态：1启用，0停用'
) COMMENT='学期表';
```

说明：

- 学期是独立业务对象
- 不建议在成绩表里直接保存自由文本 `semester`

### 3.9 学生成绩表 `student_score`

```sql
CREATE TABLE student_score (
    id           BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '成绩记录ID',
    student_id   BIGINT NOT NULL                   COMMENT '学生ID',
    course_id    BIGINT NOT NULL                   COMMENT '课程ID',
    semester_id  BIGINT NOT NULL                   COMMENT '学期ID',
    score        DECIMAL(5,2)                      COMMENT '成绩分数',

    CONSTRAINT fk_score_student
        FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE,
    CONSTRAINT fk_score_course
        FOREIGN KEY (course_id) REFERENCES course(id),
    CONSTRAINT fk_score_semester
        FOREIGN KEY (semester_id) REFERENCES semester_info(id),
    CONSTRAINT uk_student_course_semester
        UNIQUE (student_id, course_id, semester_id)
) COMMENT='学生成绩表';
```

说明：

- `score` 用 `DECIMAL(5,2)` 没问题
- 如果后续要体现“成绩脱敏为 A/B/C 等级”，建议在查询视图中通过 `CASE WHEN` 映射
- `GPA` 不再直接落表，避免与详细成绩产生冗余

---

## 四、业务主数据为什么更符合 3NF

重构后的依赖链如下：

```text
student_id -> class_id, student_no, name, gender, birth_date, status
class_id -> major_id, grade_id, class_code, class_name
major_id -> college_id, major_code, major_name
college_id -> college_code, college_name
grade_id -> grade_name, entry_year
student_id -> phone, email, id_card, address, family_income, bank_card   (student_sensitive)
course_id -> course_code, course_name, credit
semester_id -> school_year, term_no, semester_name
score_id -> student_id, course_id, semester_id, score
```

这样可以避免：

- 学院改名时批量修改学生表
- 专业调整时学生表大量重复更新
- 班级和年级信息在学生表中重复存储
- 课程名称修改导致成绩表重复维护

---

## 五、动态脱敏系统如何适配规范化后的业务表

规范化后，底层业务表变多了，但这不代表前端查询必须变复杂。

建议做两层：

1. 底层表严格规范化
2. 查询层通过视图聚合

### 5.1 学生信息聚合视图 `v_student_profile`

```sql
CREATE VIEW v_student_profile AS
SELECT
    s.id              AS student_id,
    s.student_no,
    s.name,
    s.gender,
    s.birth_date,
    s.status,
    ci.class_name,
    gi.grade_name,
    gi.entry_year,
    m.major_name,
    c.college_name,
    ss.phone,
    ss.email,
    ss.id_card,
    ss.address,
    ss.family_income,
    ss.bank_card
FROM student s
JOIN class_info ci       ON ci.id = s.class_id
JOIN grade_info gi       ON gi.id = ci.grade_id
JOIN major m             ON m.id = ci.major_id
JOIN college c           ON c.id = m.college_id
LEFT JOIN student_sensitive ss ON ss.student_id = s.id;
```

作用：

- 前端仍可像以前一样查询“完整学生画像”
- 但底层主数据仍保持规范化

### 5.2 成绩聚合视图 `v_student_score_detail`

```sql
CREATE VIEW v_student_score_detail AS
SELECT
    sc.id             AS score_id,
    s.id              AS student_id,
    s.student_no,
    s.name            AS student_name,
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
JOIN student s        ON s.id = sc.student_id
JOIN course co        ON co.id = sc.course_id
JOIN semester_info sem ON sem.id = sc.semester_id;
```

作用：

- 原始分数仍用数值存储
- 查询时可以给分析师展示等级或区间
- 更适合“动态脱敏 + 课程成绩展示”的双重需求

---

## 六、RBAC 表是否需要改

RBAC 主体结构可以基本保留：

- `sys_user`
- `sys_role`
- `sys_permission`
- `sys_user_role`
- `sys_role_permission`

这部分设计本身问题不大，主要问题还是业务主数据层。

---

## 七、脱敏配置表建议如何调整

### 7.1 敏感字段表 `sensitive_field`

可以保留，但建议把目标对象从旧表改为聚合视图或规范化后的真实字段：

```text
v_student_profile.phone
v_student_profile.email
v_student_profile.id_card
v_student_profile.address
v_student_profile.family_income
v_student_profile.bank_card
v_student_score_detail.score
```

这样做的好处是：

- 底层保持规范化
- 脱敏配置仍面向统一查询出口

### 7.2 脱敏策略表 `masking_policy`

可以保留原思路，但建议 `masking_type` 改为引用 `masking_type_dict.id`

### 7.3 脱敏规则分配表 `masking_rule_assignment`

建议去掉冗余的 `sensitive_field_id`：

```sql
CREATE TABLE masking_rule_assignment (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分配ID',
    role_id     BIGINT NOT NULL                   COMMENT '角色ID',
    policy_id   BIGINT NOT NULL                   COMMENT '策略ID',
    enabled     TINYINT NOT NULL DEFAULT 1        COMMENT '是否启用',

    CONSTRAINT fk_mra_role
        FOREIGN KEY (role_id) REFERENCES sys_role(id),
    CONSTRAINT fk_mra_policy
        FOREIGN KEY (policy_id) REFERENCES masking_policy(id),
    CONSTRAINT uk_role_policy
        UNIQUE (role_id, policy_id)
) COMMENT='脱敏规则分配表';
```

说明：

- 这是更规范的版本
- “同一角色对同一字段只能有一条策略”可通过触发器或应用层校验
- 数据库课答辩时可以明确说明：
  - 为了消除冗余，放弃直接保存 `sensitive_field_id`
  - 用触发器/过程保证跨表业务约束

---

## 八、哪些表允许适度反规范化

以下表可以保留快照字段，不必强行追求纯 3NF：

- `access_log`
- `rule_change_log`
- `abnormal_access`

原因：

- 它们是审计与留痕表
- 本质上是“历史快照”
- 快照冗余是合理设计，不属于业务主数据冗余

例如：

- `username`
- `role_code`
- `operator_name`

保留这些字段有助于日志在用户被删除后仍可追溯。

---

## 九、重构后建议的表清单

### 9.1 权限体系

1. `sys_user`
2. `sys_role`
3. `sys_permission`
4. `sys_user_role`
5. `sys_role_permission`

### 9.2 业务主数据体系

6. `college`
7. `major`
8. `grade_info`
9. `class_info`
10. `student`
11. `student_sensitive`
12. `course`
13. `semester_info`
14. `student_score`

### 9.3 脱敏配置体系

15. `sensitive_field`
16. `masking_type_dict`
17. `masking_policy`
18. `masking_rule_assignment`

### 9.4 审计体系

19. `access_log`
20. `rule_change_log`
21. `abnormal_access`

### 9.5 查询视图

22. `v_student_profile`
23. `v_student_score_detail`

---

## 十、这版更适合数据库课程答辩的点

你们后面可以这样表述：

1. 业务主数据按 3NF 规范化设计
2. 学生、班级、专业、学院之间的层级关系清晰
3. 敏感信息单独拆表，体现最小暴露思想
4. 课程和学期独立实体化，避免成绩表文本冗余
5. 动态脱敏通过视图层兼容规范化后的底层表
6. 审计日志保留快照冗余，是出于安全追溯需要的有意设计

---

## 十一、下一步建议

最推荐的后续动作是：

1. 按这版结构重写 DDL
2. 基于这版重新绘制 CDM
3. 再由 CDM 转 LDM/PDM
4. 最后同步修改：
   - `sensitive_field` 预置数据
   - `masking_policy`
   - 查询存储过程
   - 视图定义

如果继续往下做，建议优先围绕这几个核心实体重画概念模型：

```text
学院 -> 专业 -> 班级 -> 学生 -> 学生敏感信息
学生 -> 成绩 -> 课程
成绩 -> 学期
```

这条主线会比原来的 `student_info` 大表结构更符合数据库课程设计要求。
