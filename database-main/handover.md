# 项目交接文档

## 1. 当前阶段概况

本项目当前已经完成并可基本演示的能力：

- 登录、权限、菜单基础后台框架已存在
- 学生信息页、成绩页、动态脱敏展示页已基本打通
- 脱敏规则管理已接入后端与前端，支持按角色/字段查看与修改策略，且修改后可立即生效
- 用户管理、学生信息、成绩页面的“单条新增 + Excel 批量导入”共用链路已完成主要实现

当前最主要的问题不是新增/导入功能本身，而是：

- 数据库动态脱敏 SQL 例程仍存在兼容性/字符集问题
- 数据库初始化与运行期同步策略仍有“重置数据”的风险
- 部分 Java / SQL / 前端文案存在乱码

## 2. 最近一次明确需求

用户最近明确提出的工作方向是：

- 用户管理、学生信息、成绩页面均需支持单条新增与 Excel 批量导入
- 这三个页面的数据录入功能在交互流程上较为一致
- 需要复用同一套弹窗容器和同一套导入解析引擎
- 不要重构当前代码
- 不要影响当前功能

在继续这个需求的同时，用户又要求先“汇报目前暴露出的问题”。

因此本轮没有继续写业务代码，而是完成了现状核查，并整理了问题清单。

## 3. 当前已完成但尚未提交的改动

当前工作区有未提交改动，主要集中在“单条新增 + Excel 批量导入”这条链路。

### 3.1 后端新增/修改

已新增：

- `src/main/java/com/cd/controller/DataEntryController.java`
- `src/main/java/com/cd/controller/DataImportController.java`
- `src/main/java/com/cd/dto/ClassOptionResponse.java`
- `src/main/java/com/cd/dto/CourseOptionResponse.java`
- `src/main/java/com/cd/dto/DataEntryOptionsResponse.java`
- `src/main/java/com/cd/dto/DataImportErrorResponse.java`
- `src/main/java/com/cd/dto/DataImportResultResponse.java`
- `src/main/java/com/cd/dto/DataImportType.java`
- `src/main/java/com/cd/dto/SemesterOptionResponse.java`
- `src/main/java/com/cd/dto/StudentCreateRequest.java`
- `src/main/java/com/cd/dto/StudentScoreCreateRequest.java`
- `src/main/java/com/cd/service/DataEntryService.java`
- `src/main/java/com/cd/service/DataImportService.java`
- `src/main/java/com/cd/service/impl/DataEntryServiceImpl.java`
- `src/main/java/com/cd/service/impl/DataImportServiceImpl.java`
- `src/test/java/com/cd/DataEntryAndImportIntegrationTest.java`

已修改：

- `src/main/java/com/cd/controller/StudentAdminController.java`
- `src/main/java/com/cd/mapper/StudentAdminMapper.java`
- `src/main/java/com/cd/service/StudentAdminService.java`
- `src/main/java/com/cd/service/UserService.java`
- `src/main/java/com/cd/service/impl/StudentAdminServiceImpl.java`
- `src/main/java/com/cd/service/impl/UserServiceImpl.java`
- `src/main/resources/mapper/StudentAdminMapper.xml`

后端能力现状：

- 新增统一的数据录入选项接口
- 新增统一的 Excel 导入接口
- 支持用户新增
- 支持学生新增
- 支持成绩新增/更新
- Excel 导入支持 `USER` / `STUDENT` / `SCORE` 三类
- 复用同一套导入解析服务，而不是分别写三套逻辑

### 3.2 前端新增/修改

已修改：

- `src/main/resources/static/index.html`
- `src/main/resources/static/assets/js/index.js`
- `src/main/resources/static/assets/css/app.css`

前端能力现状：

- 用户、学生、成绩页面已接入共用“新增”弹窗
- 用户、学生、成绩页面已接入共用“Excel 批量导入”弹窗
- 前端可根据 `type` 切换不同表单与导入逻辑
- 前端会请求：
  - `GET /api/data-entry/options`
  - `POST /api/import/{type}`

## 4. 已完成验证

已验证通过：

- `./mvnw.cmd -q -DskipTests compile`
- `./mvnw.cmd -q -Dtest=DataEntryAndImportIntegrationTest test`

说明：

- “单条新增 + Excel 批量导入”这条新增链路在定向集成测试中是通过的
- 当前全量失败不是这条新增/导入链路直接导致的

## 5. 当前暴露出的主要问题

### 5.1 动态脱敏 SQL 链路仍不稳定

全量测试命令：

- `./mvnw.cmd test`

当前结果：

- 总体失败
- 失败集中在 `StudentMaskingApiIntegrationTest`

失败现象包括：

- 中文传入脱敏函数时报错：
  - `Data truncation: Incorrect string value ... for column p_raw_value`
- 泛化逻辑报错：
  - `FUNCTION stu_info2026_test.REGEXP_LIKE does not exist`
- 字符串拼接存在排序规则冲突：
  - `Illegal mix of collations ... for operation 'concat'`

涉及核心文件：

- `src/main/resources/schema-routines.sql`
- `src/test/java/com/cd/StudentMaskingApiIntegrationTest.java`

重点关注对象：

- `FN_APPLY_MASK`
- `FN_MASK_BY_ROLE`
- `SP_QUERY_STUDENTS`
- `SP_QUERY_STUDENT_SCORES`

### 5.2 数据库存在“重置/覆盖数据”的风险

虽然主配置里：

- `src/main/resources/application.yml`

设置了：

- `spring.sql.init.mode: never`

但项目中仍有启动时主动执行 SQL 的逻辑：

- `src/main/java/com/cd/config/DatabaseBootstrapRunner.java`

关键行为：

- 若启动时检测不到 `user` 表，则执行：
  - `schema.sql`
  - `schema-routines.sql`
  - `schema-post-data.sql`
- 然后还会执行：
  - `schema-routines.sql`
  - `schema-runtime-sync.sql`

这意味着：

- 一旦库判断条件失效，可能重新建表/灌初始数据
- 用户提到“登录日志和修改记录重启后没了”，这一点高度可疑与初始化流程有关

另外，测试环境更明确会重刷：

- `src/test/resources/application.yml`

其中：

- `spring.sql.init.mode: always`

这会导致测试库每次测试都重建。

### 5.3 乱码问题仍较广

当前乱码不只在页面文案，而是分散在：

- SQL 文件
- Java 异常消息
- Java 业务提示
- 测试断言
- 可能还有静态页面旧文案

已确认有乱码的典型文件：

- `src/main/resources/schema-routines.sql`
- `src/main/java/com/cd/exception/UserExceptionHandler.java`
- `src/main/java/com/cd/service/impl/DataImportServiceImpl.java`
- `src/main/java/com/cd/service/impl/StudentAdminServiceImpl.java`
- `src/test/java/com/cd/StudentMaskingApiIntegrationTest.java`

风险：

- 不只是“显示难看”
- 还可能影响 SQL 字符串判断分支、测试断言、错误提示语义

### 5.4 动态脱敏业务错误映射未完全闭环

原目标是：

- 数据库 `SQLSTATE 45000` 类业务错误映射为 4xx
- 其他数据库异常映射为 5xx

但当前实际表现中：

- `StudentMaskingApiIntegrationTest.routineBusinessErrorShouldReturn400WhenResolvedRoleIsDisabled`

仍然失败，表现为：

- 期望 400
- 实际返回 500

已确认：

- `src/main/java/com/cd/exception/UserExceptionHandler.java`

已经有：

- `DatabaseRoutineException` 的异常处理器

这说明问题更可能在于：

- 数据库异常到 `DatabaseRoutineException` 的转换逻辑不稳定
- 或者 SQL 例程先被其他 500 错误打断，没走到正确的业务错误分支

### 5.5 一些次级代码质量问题

这些问题不一定阻断功能，但建议顺手处理：

- `src/main/java/com/cd/service/impl/DataImportServiceImpl.java`
  - 有未使用导入：
    - `com.cd.entity.UserEntity`
    - `java.util.LinkedHashMap`
- `src/main/java/com/cd/service/impl/StudentAdminServiceImpl.java`
  - 仍有旧写法：
    - `BigDecimal.ROUND_HALF_UP`
  - `validateClassExists / validateCourseExists / validateSemesterExists`
    - 同一个 `countXxxById()` 被重复调用

## 6. 当前测试状态

### 6.1 通过

- `DataEntryAndImportIntegrationTest`
- `StuInfoApiApplicationTests`

### 6.2 失败

`StudentMaskingApiIntegrationTest` 当前至少有以下失败：

- `studentProfilesShouldReturnDifferentMaskingByRole`
- `studentScoresShouldReturnDifferentMaskingByRole`
- `studentRoleShouldOnlySeeSelfEvenWhenPassingAnotherStudentNo`
- `updatingMaskingRuleShouldTakeEffectImmediately`
- `routineBusinessErrorShouldReturn400WhenResolvedRoleIsDisabled`

失败根因目前看仍集中在：

- 动态脱敏 SQL 例程
- 字符集 / 排序规则
- 数据库业务错误映射

## 7. 与用户最新目标的关系判断

### 7.1 用户新增/导入目标

这部分目前状态是：

- 主体功能已完成
- 共用弹窗容器已接上
- 共用导入解析引擎已接上
- 定向测试已通过

### 7.2 当前真正阻塞继续演示/验收的点

如果继续往前推进，真正优先级更高的阻塞项不是继续堆新功能，而是：

1. 修动态脱敏 SQL 链路
2. 收紧数据库初始化策略，避免数据重置
3. 修本链路相关乱码
4. 清理新增/导入链路的小问题并回归

## 8. 推荐下一步执行顺序

建议新窗口按下面顺序继续：

### 第一步：先止住“重启丢数据/数据库重置”问题

优先检查：

- `src/main/java/com/cd/config/DatabaseBootstrapRunner.java`
- `src/main/resources/application.yml`
- `src/test/resources/application.yml`

建议目标：

- 明确生产运行时是否应该自动建库/重刷
- 运行期只做必要同步，避免再次执行破坏性脚本
- 分清“首次初始化”和“后续启动”的行为边界

### 第二步：修复动态脱敏 SQL 兼容性

重点文件：

- `src/main/resources/schema-routines.sql`

重点问题：

- 去掉对 `REGEXP_LIKE` 的依赖，改为兼容写法
- 统一 `utf8mb4` 与排序规则，避免 `concat` collation 冲突
- 修正中文字符字面量乱码
- 检查 `FN_APPLY_MASK` 对中文和数值输入的处理

### 第三步：回归脱敏 API 测试

执行：

- `./mvnw.cmd -q -Dtest=StudentMaskingApiIntegrationTest test`
- `./mvnw.cmd test`

目标：

- 先让脱敏链路测试转绿
- 再确认新增/导入链路没有被带坏

### 第四步：清理新增/导入链路的小问题

建议处理：

- 删除未使用导入
- 把 `BigDecimal.ROUND_HALF_UP` 换成 `RoundingMode.HALF_UP`
- 减少重复 `count` 查询
- 只修当前链路直接可见的乱码

## 9. 本次核查时用到的关键命令

### 工作区状态

```powershell
git status --short
```

### 仅跑新增/导入链路测试

```powershell
./mvnw.cmd -q -Dtest=DataEntryAndImportIntegrationTest test
```

### 跑动态脱敏测试

```powershell
./mvnw.cmd -q -Dtest=StudentMaskingApiIntegrationTest test
```

### 跑全量测试

```powershell
./mvnw.cmd test
```

### 搜索动态脱敏对象位置

```powershell
rg -n "REGEXP_LIKE|FN_APPLY_MASK|FN_MASK_BY_ROLE|SP_QUERY_STUDENTS|SP_QUERY_STUDENT_SCORES" src/main/resources/schema-routines.sql src/test/java/com/cd/StudentMaskingApiIntegrationTest.java
```

### 搜索数据库初始化/重刷路径

```powershell
rg -n "schema.sql|schema-routines.sql|schema-post-data.sql|spring\\.sql\\.init|ddl-auto|DROP TABLE IF EXISTS|DROP VIEW IF EXISTS|DROP FUNCTION IF EXISTS|DROP PROCEDURE IF EXISTS" src/main/resources src/test/resources src/main/java
```

## 10. 重要文件索引

### 数据库与初始化

- `src/main/resources/schema.sql`
- `src/main/resources/schema-routines.sql`
- `src/main/resources/schema-post-data.sql`
- `src/main/resources/schema-runtime-sync.sql`
- `src/main/resources/application.yml`
- `src/test/resources/application.yml`
- `src/main/java/com/cd/config/DatabaseBootstrapRunner.java`

### 动态脱敏后端

- `src/main/java/com/cd/controller/StudentMaskingController.java`
- `src/main/java/com/cd/service/impl/StudentMaskingServiceImpl.java`
- `src/main/java/com/cd/exception/UserExceptionHandler.java`
- `src/test/java/com/cd/StudentMaskingApiIntegrationTest.java`

### 新增/导入链路

- `src/main/java/com/cd/controller/DataEntryController.java`
- `src/main/java/com/cd/controller/DataImportController.java`
- `src/main/java/com/cd/service/impl/DataEntryServiceImpl.java`
- `src/main/java/com/cd/service/impl/DataImportServiceImpl.java`
- `src/main/java/com/cd/controller/StudentAdminController.java`
- `src/main/java/com/cd/service/impl/StudentAdminServiceImpl.java`
- `src/main/resources/mapper/StudentAdminMapper.xml`
- `src/main/resources/static/index.html`
- `src/main/resources/static/assets/js/index.js`
- `src/main/resources/static/assets/css/app.css`
- `src/test/java/com/cd/DataEntryAndImportIntegrationTest.java`

## 11. 交接结论

如果新窗口继续接手，这里最重要的判断是：

- “用户/学生/成绩的新增 + Excel 导入”主功能已经做到了可继续完善的阶段
- 当前最严重的问题不在新增/导入，而在动态脱敏 SQL 和数据库初始化策略
- 后续应先修“数据重置 + 脱敏测试失败”，否则前面新功能越多，回归成本越高

