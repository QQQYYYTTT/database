# 数据库建表相关信息 - 3NF重构最终版

> 项目名称：基于 RBAC 的高校学生信息动态脱敏系统
>
> 当前状态：你前面提到的“后续任务”，这次已经实际做了，不再只是建议。

---

## 一、这次已经完成了什么

围绕你之前指出的数据库课程重点，我已经把后续任务真正落下来了：

1. 已按 3NF 思路重写业务主数据结构
2. 已基于新结构重画 CDM
3. 已同步更新脱敏配置设计
4. 已同步更新查询视图设计
5. 已同步更新存储过程设计
6. 已额外落一份完整 SQL 脚本，便于你直接导入验证

当前目录里的关键交付文件：

- CDM 文件：[高校学生信息动态脱敏系统-CDM.cdm](C:\DATA\database\高校学生信息动态脱敏系统-CDM.cdm)
- 备用 ASCII 路径 CDM：[student_masking_system_cdm.cdm](C:\DATA\database\student_masking_system_cdm.cdm)
- CDM 生成脚本：[generate_student_masking_cdm.ps1](C:\DATA\database\generate_student_masking_cdm.ps1)
- 3NF 完整 SQL：[高校学生信息动态脱敏系统-3NF完整版.sql](C:\DATA\database\高校学生信息动态脱敏系统-3NF完整版.sql)

---

## 二、为什么必须从旧版结构重构

你这个项目如果按“数据库课程设计”来要求，旧版 `student_info` 大表确实不够规范，核心问题主要有这几类：

1. `student_info` 同时保存 `college`、`major`、`grade`、`class_name`
   这会产生明显的传递依赖，不符合严格 3NF。

2. `student_score` 直接保存 `course_name`、`semester`
   课程和学期本身应该是独立业务实体，直接存文本容易产生更新异常。

3. 旧版虽然能演示“动态脱敏”，但业务主数据层次不清楚
   从数据库课答辩角度，这会被看成更像 demo，而不是规范化设计。

---

## 三、重构后的业务主线

这版 3NF 设计的核心主线是：

```text
学院 -> 专业 -> 班级 -> 学生 -> 学生敏感信息
学生 -> 成绩 -> 课程
成绩 -> 学期
```

对应实体为：

1. `college`
2. `major`
3. `grade_info`
4. `class_info`
5. `student`
6. `student_sensitive`
7. `course`
8. `semester_info`
9. `student_score`

这样拆分后，业务层级更清楚，也更符合你们老师强调的规范化要求。

---

## 四、重构后的完整表清单

### 4.1 RBAC 权限体系

1. `sys_user`
2. `sys_role`
3. `sys_permission`
4. `sys_user_role`
5. `sys_role_permission`

### 4.2 业务主数据体系

6. `college`
7. `major`
8. `grade_info`
9. `class_info`
10. `student`
11. `student_sensitive`
12. `course`
13. `semester_info`
14. `student_score`

### 4.3 脱敏配置体系

15. `sensitive_field`
16. `masking_type_dict`
17. `masking_policy`
18. `masking_rule_assignment`

### 4.4 审计体系

19. `access_log`
20. `rule_change_log`
21. `abnormal_access`

### 4.5 视图

22. `v_student_profile`
23. `v_student_score_detail`
24. `v_masking_config`

### 4.6 函数与存储过程

25. `FN_APPLY_MASK`
26. `FN_MASK_BY_ROLE`
27. `SP_QUERY_STUDENTS`
28. `SP_QUERY_STUDENT_SCORES`
29. `SP_DETECT_ABNORMAL`

---

## 五、这版结构如何满足 3NF

重构后的关键依赖链如下：

```text
student_id -> class_id, student_no, name, gender, birth_date, status
class_id -> major_id, grade_id, class_code, class_name
major_id -> college_id, major_code, major_name
college_id -> college_code, college_name
grade_id -> grade_name, entry_year
student_id -> phone, email, id_card, address, family_income, bank_card
course_id -> course_code, course_name, credit
semester_id -> school_year, term_no, semester_name
score_id -> student_id, course_id, semester_id, score
```

这样可以避免：

1. 学院改名时批量修改学生表
2. 专业调整时学生表重复更新
3. 班级、年级信息在学生表中冗余存储
4. 课程名称修改导致成绩表大面积更新

---

## 六、你前面提出的几条数据库设计意见，这版都已经吸收

1. `student_sensitive.phone` 改为字符串类型
   已采用 `VARCHAR(20)`。

2. `student_score.score` 保持数值类型
   已采用 `DECIMAL(5,2)`，后续可在视图中映射为 `A/B/C/D/E`。

3. `class` 避免使用保留字
   已改为 `class_info`。

4. `student_no` 必须唯一
   已加唯一约束。

5. `student.status` 明确业务语义
   已定义为：
   - `0` 在读
   - `1` 休学
   - `2` 毕业

---

## 七、脱敏配置如何适配重构后的 3NF 结构

为了兼顾“底层规范化”和“上层查询方便”，这版采用了一个很适合课程设计答辩的思路：

1. 底层业务表严格规范化
2. 上层通过聚合视图提供统一查询出口
3. 脱敏元数据不再优先面向旧大表，而是面向查询视图

### 7.1 学生信息聚合视图

`v_student_profile`

用于把这些表汇总起来：

- `student`
- `class_info`
- `grade_info`
- `major`
- `college`
- `student_sensitive`

### 7.2 成绩聚合视图

`v_student_score_detail`

用于把这些表汇总起来：

- `student_score`
- `student`
- `course`
- `semester_info`

### 7.3 敏感字段配置对象

这版 `sensitive_field` 的目标对象，已经同步改到：

```text
v_student_profile.name
v_student_profile.phone
v_student_profile.email
v_student_profile.id_card
v_student_profile.address
v_student_profile.birth_date
v_student_profile.family_income
v_student_profile.bank_card
v_student_score_detail.score
```

这样做的优点是：

1. 业务底层继续保持规范化
2. 脱敏配置面向统一查询出口
3. 存储过程实现更清晰
4. 课程答辩时容易说明“逻辑分层”

---

## 八、`masking_rule_assignment` 为什么改成去冗余版本

你前面也注意到一个问题：旧设计里 `masking_rule_assignment` 保存 `sensitive_field_id` 是冗余的。

这次我采用的是更规范的版本：

```text
masking_rule_assignment
    role_id
    policy_id
    enabled
```

因为：

```text
policy_id -> masking_policy -> sensitive_field_id
```

本来就能推导出目标敏感字段。

为了保证“同一角色对同一敏感字段只能分配一条启用策略”，这版 SQL 里额外使用了触发器校验，而不是靠冗余字段硬做唯一约束。这一点非常适合数据库课答辩，因为你可以明确说明：

1. 我们优先消除冗余
2. 跨表业务约束由触发器保证
3. 这是规范化设计和完整性约束的配合

---

## 九、哪些表允许保留冗余

以下表仍然允许保留快照字段：

1. `access_log`
2. `rule_change_log`
3. `abnormal_access`

原因不是“设计不规范”，而是：

1. 它们属于审计与留痕表
2. 本质是历史快照
3. 快照冗余是安全追溯需要

所以像下面这些字段保留快照是合理的：

- `username_snapshot`
- `role_snapshot`
- `operator_name`

---

## 十、这次已经同步完成的数据库对象

这部分正是你刚刚追问我的重点。

### 10.1 已重写完整 DDL

已完成，并写入：

[高校学生信息动态脱敏系统-3NF完整版.sql](C:\DATA\database\高校学生信息动态脱敏系统-3NF完整版.sql)

其中包含：

1. 全部表的 `DROP + CREATE`
2. 主键、唯一约束、外键、检查约束
3. 触发器
4. 视图
5. 函数
6. 存储过程
7. 初始化测试数据

### 10.2 已同步 `sensitive_field`

已经从旧的 `student_info.*` 为主，改成面向：

- `v_student_profile.*`
- `v_student_score_detail.score`

### 10.3 已同步 `masking_policy`

已经根据新视图对象重配策略，并区分了：

1. 默认策略
2. 教师策略
3. 分析师策略
4. 普通用户策略
5. 管理员/数据管理员原值可见策略

### 10.4 已同步查询视图

已设计并写入 SQL：

1. `v_student_profile`
2. `v_student_score_detail`
3. `v_masking_config`

### 10.5 已同步存储过程

已设计并写入 SQL：

1. `SP_QUERY_STUDENTS`
2. `SP_QUERY_STUDENT_SCORES`
3. `SP_DETECT_ABNORMAL`

其中查询过程已经改为面向新视图，而不是旧 `student_info` 大表。

---

## 十一、CDM 这一步是否已经做了

做了。

目前 CDM 已按新 3NF 主线重画，关键实体和关系已经切换到新的结构，不再是以旧版 `student_info` 为核心。

你当前目录里可直接使用：

- [高校学生信息动态脱敏系统-CDM.cdm](C:\DATA\database\高校学生信息动态脱敏系统-CDM.cdm)

我也保留了一份英文路径版本，主要是为了规避 PowerDesigner 对中文路径偶发不稳定的问题：

- [student_masking_system_cdm.cdm](C:\DATA\database\student_masking_system_cdm.cdm)

---

## 十二、LDM/PDM 是否已经完全同步

这一步目前我没有确认“已经从新 CDM 自动重新生成成功”。

当前目录里虽然已有：

- [高校学生信息动态脱敏系统概念模型.ldm](C:\DATA\database\高校学生信息动态脱敏系统概念模型.ldm)
- [高校学生信息动态脱敏系统概念模型.pdm](C:\DATA\database\高校学生信息动态脱敏系统概念模型.pdm)

但它们很可能还带有旧版结构痕迹，暂时不能默认视为完全可信的最终版本。

也就是说：

1. `CDM` 已经重画
2. `SQL` 已经重写
3. `LDM/PDM` 我建议你在 PowerDesigner 里基于当前新 CDM 再执行一次生成

你现在最稳的做法是：

1. 先打开新的 CDM
2. 执行 `CDM -> Generate LDM`
3. 再执行 `LDM -> Generate PDM`
4. 核对实体名、外键名、表名是否与 SQL 一致

---

## 十三、你现在可以怎么继续往下做

如果你准备继续推进课程设计，我建议按这个顺序：

1. 先用 [高校学生信息动态脱敏系统-3NF完整版.sql](C:\DATA\database\高校学生信息动态脱敏系统-3NF完整版.sql) 建库
2. 用新的 CDM 在 PowerDesigner 里生成 LDM/PDM
3. 对照 SQL 检查 PDM 中的表名、字段、外键
4. 在答辩材料里重点强调业务主数据 3NF
5. 把“动态脱敏”作为这套规范化数据库上的安全扩展能力去讲

---

## 十四、这版最适合数据库课答辩的表达方式

你们后面可以直接这样讲：

1. 原方案能演示动态脱敏，但业务主数据不够规范
2. 重构后把学院、专业、年级、班级、学生、成绩、课程、学期都实体化
3. 业务主数据按 3NF 进行规范化设计
4. 敏感信息独立拆表，体现最小暴露思想
5. 动态脱敏通过视图层与存储过程兼容规范化结构
6. 审计日志允许保留快照冗余，这是面向安全追溯的有意设计

---

## 十五、结论

你之前问我的那句“你有没有做这些后续任务”，答案是：

之前没有全部做完；
这次已经把最关键的后续任务真正做了，至少已经完成了：

1. 3NF 完整 DDL
2. 新 CDM
3. 新的敏感字段配置
4. 新的脱敏策略配置
5. 新的视图
6. 新的查询存储过程

如果你下一步要，我可以继续帮你做两件事里的任意一件：

1. 继续给你出一版“PowerDesigner 里按这个新 3NF 结构怎么一步一步画 LDM/PDM”
2. 继续帮你把这份 SQL 对应地整理成“课程设计报告里的数据库设计章节”
