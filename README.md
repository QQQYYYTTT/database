# 高校学生数据脱敏管理平台

English: `College Student Data Desensitization Management Platform`

这是一个基于 `Spring Boot 3.x + MyBatis XML + Vue` 的前后端一体化项目，当前已包含：

- `test` 模块 CRUD 示例
- `user` 模块真实登录、当前用户、退出登录、分页查询、按用户名搜索、增删改查
- `login_log` 模块登录日志记录、分页查询、按用户名搜索
- 基于 Vue 的登录页与后台管理页面
- Spring Boot 静态资源托管，无需额外启动前端服务

## 技术栈

- 后端：Spring Boot 3.5.3
- 持久层：MyBatis 3.0.4
- 数据库：MySQL 8+
- 参数校验：Jakarta Validation
- 前端：Vue 3
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

- 登录页默认测试数据为 `admin / admin`
- 登录成功后会将 `token` 保存到 `localStorage`
- 未登录或登录态失效时访问后台会自动跳转到登录页
- 后台右上角显示当前登录用户
- 点击右上角退出登录会调用后端退出接口并清除本地 `token`
- 左侧菜单支持折叠，折叠后右侧主内容区域会同步左移

## 当前后台页面

当前已落地的真实页面：

- 后台主页：展示统计信息与最近登录日志
- 个人信息：展示当前登录用户全部信息，除密码外
- 用户管理：支持分页、按用户名搜索、新增、编辑、删除
- 系统日志：展示登录日志，支持分页与按用户名搜索

当前保留占位结构但未扩展业务的页面：

- 角色管理
- 权限管理
- 学生信息

## 前端静态资源结构

```text
src/main/resources/static
├─ index.html
├─ login.html
└─ assets
   ├─ css
   │  └─ app.css
   ├─ js
   │  ├─ index.js
   │  └─ login.js
   └─ vendor
      └─ vue.global.prod.js
```

## 后端包结构

```text
src/main/java/com/cd
├─ common
│  └─ Result.java
├─ config
│  └─ WebConfig.java
├─ controller
│  ├─ AuthController.java
│  ├─ LoginLogController.java
│  ├─ TestController.java
│  └─ UserController.java
├─ dto
│  ├─ LoginLogResponse.java
│  ├─ LoginResponse.java
│  ├─ PageResponse.java
│  ├─ TestRequest.java
│  ├─ UserCreateRequest.java
│  ├─ UserLoginRequest.java
│  ├─ UserResponse.java
│  └─ UserUpdateRequest.java
├─ entity
│  ├─ LoginLogEntity.java
│  ├─ TestEntity.java
│  └─ UserEntity.java
├─ exception
│  └─ UserExceptionHandler.java
├─ interceptor
│  └─ AuthInterceptor.java
├─ mapper
│  ├─ LoginLogMapper.java
│  ├─ TestMapper.java
│  └─ UserMapper.java
├─ service
│  ├─ AuthTokenService.java
│  ├─ LoginLogService.java
│  ├─ TestService.java
│  └─ UserService.java
├─ service/impl
│  ├─ AuthTokenServiceImpl.java
│  ├─ LoginLogServiceImpl.java
│  ├─ TestServiceImpl.java
│  └─ UserServiceImpl.java
└─ util
   ├─ Md5Utils.java
   └─ TokenUtils.java
```

## 数据库初始化

数据库初始化脚本：

```text
src/main/resources/schema.sql
```

当前会初始化以下数据表：

- `test`
- `user`
- `login_log`

`user` 表字段：

- `id`
- `user_name`
- `user_pwd`
- `user_header`
- `user_phonenum`
- `user_email`
- `create_at`
- `updated_at`
- `last_login_time`

`login_log` 表字段：

- `id`
- `user_name`
- `login_status`
- `login_ip`
- `login_message`
- `login_time`

默认管理员账号：

- 用户名：`admin`
- 密码：`admin`

注意：

- 数据库存储的是 MD5 加密后的密码
- 不以明文形式保存密码

## 登录接口

接口地址：

```text
POST /api/user/login
```

请求体：

```json
{
  "userName": "admin",
  "userPwd": "admin"
}
```

成功响应示例：

```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "userId": 1,
    "userName": "admin"
  }
}
```

说明：

- 后端根据 `user_name` 查询用户
- 使用数据库中的 `user_pwd`（MD5 密文）完成密码校验
- 登录成功后更新 `last_login_time`
- 登录成功或失败都会写入 `login_log`
- 登录成功后生成 token 并在后端内存中保存登录态
- 前端将 token 保存到 `localStorage`

前端表单校验规则：

- 用户名不能为空
- 密码不能为空

## 当前用户接口

接口地址：

```text
GET /api/user/me
```

请求头：

```text
Authorization: Bearer {token}
```

说明：

- 用于获取当前登录用户信息
- 返回结果不包含 `user_pwd`
- 个人信息页与右上角当前用户展示都依赖该接口

## 退出登录接口

接口地址：

```text
POST /api/user/logout
```

请求头：

```text
Authorization: Bearer {token}
```

说明：

- 调用后会移除后端保存的登录态
- 前端会同步清除本地 token 并跳转回登录页

## 用户管理接口

基础路径：

```text
http://localhost:8081/api/users
```

接口列表：

- `GET /api/users?page=1&size=10`
- `GET /api/users?page=1&size=10&userName=admin`
- `GET /api/users/{id}`
- `POST /api/users`
- `PUT /api/users/{id}`
- `DELETE /api/users/{id}`

说明：

- 所有接口统一返回 `Result`
- 查询结果不返回 `user_pwd`
- `GET /api/users` 支持分页与按用户名模糊搜索
- 所有 `/api/users/**` 接口都需要登录后访问
- 修改或删除不存在用户时返回 `404`

分页响应结构示例：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [],
    "total": 0,
    "page": 1,
    "size": 10,
    "totalPages": 0
  }
}
```

## 登录日志接口

基础路径：

```text
http://localhost:8081/api/login-logs
```

接口列表：

- `GET /api/login-logs?page=1&size=10`
- `GET /api/login-logs?page=1&size=10&userName=admin`

说明：

- 支持分页
- 支持按用户名模糊搜索
- 仅记录登录日志
- 当前实现会记录成功登录和失败登录

## 接口示例文件

接口联调示例可参考：

```text
src/main/resources/api-examples.http
```

## 已完成的基础验证

- `.\mvnw.cmd test`
- 登录接口调用验证
- 当前用户接口调用验证
- 退出登录接口调用验证
- 用户分页查询验证
- 用户按用户名搜索验证
- 用户新增、修改、删除验证
- 登录日志分页与搜索验证
- 匿名访问受保护接口返回 `401` 验证
- 登录页与后台页静态资源可访问验证
