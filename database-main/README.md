# 高校学生数据脱敏管理平台

English: `College Student Data Desensitization Management Platform`

这是一个基于 `Spring Boot 3.x + MyBatis XML + Vue 3` 的前后端一体化项目，核心目标是演示“数据库动态脱敏 + Spring Boot 安全接入 + 前端按角色展示差异”的完整链路。当前已包含：

- 用户登录、JWT 鉴权、当前用户信息、退出登录
- 用户、角色、权限、登录日志管理
- 学生信息脱敏查询页
- 学生成绩脱敏查询页
- 基于 MySQL 函数与存储过程的动态脱敏实现
- Spring Boot 静态资源托管，无需额外启动前端服务

## 技术栈

- 后端：Spring Boot 3.5.3
- 持久层：MyBatis 3.0.4
- 数据库：MySQL 8+
- 安全：Spring Security + JWT
- 前端：Vue 3（静态页面）
- 构建：Maven Wrapper

## 启动方式

请先确保本地 MySQL 可用，连接信息如下：

- 地址：`127.0.0.1:3306`
- 用户名：`root`
- 密码：`root`
- 数据库：`stu_info2026`

启动命令：

```powershell
.\mvnw.cmd spring-boot:run
```

默认访问地址：

```text
http://localhost:8081
```

执行测试：

```powershell
.\mvnw.cmd test
```

## 页面入口

登录页：

```text
http://localhost:8081/login.html
```

后台首页：

```text
http://localhost:8081/index.html
```

说明：

- 登录成功后会将 `token` 保存到 `localStorage`
- 未登录或登录态失效时访问后台会自动跳转到登录页
- 后台菜单根据当前角色动态返回
- 学生信息页和成绩页会按当前角色展示不同脱敏结果

## 当前后台页面

当前已落地的页面：

- 后台主页：展示统计信息与最近登录日志
- 个人信息：展示当前登录用户信息、角色、权限编码
- 学生信息：展示按角色脱敏后的学生资料
- 学生成绩：展示按角色脱敏后的成绩明细
- 用户管理：支持分页、按用户名搜索、新增、编辑、删除
- 角色管理：支持角色维护与权限分配
- 权限管理：支持菜单/API 权限维护
- 登录日志：展示登录日志，支持分页与按用户名搜索

## 动态脱敏链路

项目会按以下顺序初始化数据库：

```text
src/main/resources/schema.sql
src/main/resources/schema-routines.sql
src/main/resources/schema-post-data.sql
```

其中动态脱敏核心数据库对象包括：

- `FN_APPLY_MASK`
- `FN_MASK_BY_ROLE`
- `SP_QUERY_STUDENTS`
- `SP_QUERY_STUDENT_SCORES`

说明：

- `FN_APPLY_MASK` 负责具体脱敏算法，如全遮蔽、保留前后缀、邮箱脱敏、地址层级脱敏、分数区间泛化等
- `FN_MASK_BY_ROLE` 根据角色与字段策略选择具体脱敏规则
- `SP_QUERY_STUDENTS` 统一返回按角色处理后的学生资料
- `SP_QUERY_STUDENT_SCORES` 统一返回按角色处理后的成绩数据
- Spring Boot 不接受前端传入角色，实际角色只来自当前登录态
- `STUDENT` 角色在后端会被收敛为“仅查看本人”

## 动态脱敏接口

学生信息接口：

```text
GET /api/student-profiles
```

可选查询参数：

- `studentNo`
- `name`
- `className`

成绩信息接口：

```text
GET /api/student-scores
```

可选查询参数：

- `studentNo`
- `courseName`
- `semesterName`

说明：

- 两个接口都需要登录
- 两个接口都由 Spring Boot 直接调用数据库存储过程
- 角色无权限时返回 `403`
- 数据库存储过程返回业务错误时会映射为明确的 4xx 响应

## 示例账号

默认管理员账号：

- 用户名：`admin`
- 密码：`admin`

用于演示不同脱敏效果的账号已经通过初始化脚本写入数据库：

- `mask_teacher`
- `mask_analyst`
- `mask_normal`
- `2023001`（学生账号，对应本人学号）

这些账号会在初始化后绑定对应角色，可直接用于前端演示“不同角色看到不同结果”。

## 接口联调示例

接口联调示例文件：

```text
src/main/resources/api-examples.http
```

其中已经包含：

- 登录、当前用户、退出登录
- 用户分页接口
- 登录日志分页接口
- 学生信息脱敏查询接口
- 学生成绩脱敏查询接口

## 已完成的验证

- `.\mvnw.cmd test`
- 数据库脱敏函数与存储过程存在性检查
- `FN_APPLY_MASK` 典型脱敏分支验证
- `FN_MASK_BY_ROLE` 角色差异与默认回退验证
- 学生信息/成绩接口按角色返回差异验证
- `STUDENT` 角色仅查看本人验证
- 受保护接口 `401 / 403` 验证
- 前端学生信息页与成绩页联动接口验证
