const { createApp, computed, nextTick, onBeforeUnmount, onMounted, reactive, ref, watch } = Vue;

const TOKEN_KEY = "platform_token";
const USER_KEY = "platform_user";

const menuIcons = {
    dashboard: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <path d="M4 5H10V11H4Z" />
            <path d="M14 5H20V9H14Z" />
            <path d="M14 13H20V19H14Z" />
            <path d="M4 15H10V19H4Z" />
        </svg>
    `,
    profile: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <circle cx="12" cy="8" r="4" />
            <path d="M4 20C4 16.686 7.582 14 12 14C16.418 14 20 16.686 20 20" />
        </svg>
    `,
    user: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <path d="M4 19C4 16.239 6.686 14 10 14" />
            <path d="M14 14C17.314 14 20 16.239 20 19" />
            <circle cx="10" cy="8" r="3" />
            <circle cx="17" cy="9" r="2" />
        </svg>
    `,
    role: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <path d="M12 3L21 8L12 13L3 8L12 3Z" />
            <path d="M7 10.5V15.5C7 17.985 9.239 20 12 20C14.761 20 17 17.985 17 15.5V10.5" />
        </svg>
    `,
    permission: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <path d="M12 3L19 6V11C19 15.418 16.119 19.223 12 20.5C7.881 19.223 5 15.418 5 11V6L12 3Z" />
            <path d="M9.5 12L11.3 13.8L14.8 10.3" />
        </svg>
    `,
    log: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <path d="M7 4H17V20H7Z" />
            <path d="M9.5 8H14.5" />
            <path d="M9.5 12H14.5" />
            <path d="M9.5 16H13" />
        </svg>
    `,
    team: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <circle cx="9" cy="8" r="3" />
            <circle cx="17" cy="9" r="2.5" />
            <path d="M3.5 19C3.5 15.962 6.186 13.5 9.5 13.5C12.814 13.5 15.5 15.962 15.5 19" />
            <path d="M15 14.5C17.526 14.899 19.5 16.936 19.5 19.5" />
        </svg>
    `,
    "bar-chart": `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <path d="M4 20H20" />
            <path d="M7 20V11" />
            <path d="M12 20V7" />
            <path d="M17 20V14" />
        </svg>
    `,
    "masking-rule": `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <path d="M12 3L19 6V11C19 15.418 16.119 19.223 12 20.5C7.881 19.223 5 15.418 5 11V6L12 3Z" />
            <path d="M8 12H16" />
            <path d="M9.5 8.5H14.5" />
            <path d="M9.5 15.5H14.5" />
        </svg>
    `,
    default: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <circle cx="12" cy="12" r="8" />
            <path d="M12 8V12L15 15" />
        </svg>
    `
};

const pageIcons = {
    user: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <circle cx="12" cy="8" r="4" />
            <path d="M4 20C4 16.686 7.582 14 12 14C16.418 14 20 16.686 20 20" />
        </svg>
    `,
    logout: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <path d="M10 7V5H5V19H10V17" />
            <path d="M14 8L19 12L14 16" />
            <path d="M9 12H19" />
        </svg>
    `,
    refresh: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <path d="M20 11A8 8 0 1 0 17.66 17.66" />
            <path d="M20 4V11H13" />
        </svg>
    `
};

const ROLE_SUPER_ADMIN = "SUPER_ADMIN";
const ROLE_DATA_ADMIN = "DATA_ADMIN";
const ROLE_TEACHER = "TEACHER";
const ROLE_ANALYST = "ANALYST";
const ROLE_NORMAL = "NORMAL";
const ROLE_STUDENT = "STUDENT";

const DATA_ENTRY_TYPE_USER = "user";
const DATA_ENTRY_TYPE_STUDENT = "student";
const DATA_ENTRY_TYPE_SCORE = "score";

const dataEntryMeta = {
    [DATA_ENTRY_TYPE_USER]: {
        label: "用户",
        createTitle: "新增用户",
        importTitle: "批量导入用户",
        menuKey: "user",
        successMessage: "用户创建成功",
        importHint: "请上传 .xlsx 文件，首行表头需与系统约定完全一致。角色编码支持多个值，使用逗号分隔。",
        headers: ["用户名", "密码", "手机号", "邮箱", "头像地址", "角色编码"]
    },
    [DATA_ENTRY_TYPE_STUDENT]: {
        label: "学生",
        createTitle: "新增学生",
        importTitle: "批量导入学生",
        menuKey: "student",
        successMessage: "学生信息创建成功",
        importHint: "班级需填写班级代码，出生日期格式为 yyyy-MM-dd，家庭收入可填写小数。",
        headers: ["学号", "姓名", "性别", "出生日期", "班级代码", "手机号", "邮箱", "身份证号", "住址", "家庭收入", "银行卡号"]
    },
    [DATA_ENTRY_TYPE_SCORE]: {
        label: "成绩",
        createTitle: "新增成绩",
        importTitle: "批量导入成绩",
        menuKey: "score",
        successMessage: "成绩保存成功",
        importHint: "课程请填写课程代码，学期请填写学期名称。若同一学号、课程、学期已存在记录，系统会直接更新成绩。",
        headers: ["学号", "课程代码", "学期名称", "成绩"]
    }
};

const defaultPageData = () => ({
    records: [],
    total: 0,
    page: 1,
    size: 10,
    totalPages: 0
});

const getToken = () => localStorage.getItem(TOKEN_KEY);

const clearLoginState = () => {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
};

const redirectToLogin = () => {
    clearLoginState();
    window.location.replace("/login.html");
};

const buildQuery = (params) => {
    const searchParams = new URLSearchParams();
    Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null && value !== "") {
            searchParams.set(key, value);
        }
    });
    return searchParams.toString();
};

const flattenMenuTree = (nodes, depth = 0, result = []) => {
    (nodes || []).forEach((node) => {
        result.push({ ...node, depth });
        if (node.children && node.children.length > 0) {
            flattenMenuTree(node.children, depth + 1, result);
        }
    });
    return result;
};

const flattenPermissionTree = (nodes, depth = 0, result = []) => {
    (nodes || []).forEach((node) => {
        result.push({ ...node, depth });
        if (node.children && node.children.length > 0) {
            flattenPermissionTree(node.children, depth + 1, result);
        }
    });
    return result;
};

const findMenuNodeByKey = (nodes, menuKey) => {
    for (const node of nodes || []) {
        if (node.menuKey === menuKey) {
            return node;
        }
        const matchedChild = findMenuNodeByKey(node.children || [], menuKey);
        if (matchedChild) {
            return matchedChild;
        }
    }
    return null;
};

const defaultScoreAnalytics = () => ({
    roleCode: "",
    roleName: "",
    granularity: "",
    scopeNote: "",
    summaryCards: [],
    collegeRanking: [],
    majorRanking: [],
    courseRanking: [],
    scoreDistribution: []
});

const defaultSensitiveAnalytics = () => ({
    roleCode: "",
    roleName: "",
    granularity: "",
    scopeNote: "",
    summaryCards: [],
    levelDistribution: [],
    coverage: [],
    fieldCatalog: [],
    visibilitySamples: []
});

createApp({
    setup() {
        if (!getToken()) {
            redirectToLogin();
        }

        const currentUser = ref(JSON.parse(localStorage.getItem(USER_KEY) || "{}"));
        const isCollapsed = ref(false);
        const activeMenu = ref(null);
        const expandedMenuKeys = ref([]);

        const homeUserTotal = ref(null);
        const homeLogTotal = ref(null);
        const homeRecentLogs = ref([]);

        const userLoading = ref(false);
        const userError = ref("");
        const userPage = ref(defaultPageData());
        const userQuery = reactive({
            userName: "",
            page: 1,
            size: 10
        });
        const showUserModal = ref(false);
        const userSubmitting = ref(false);
        const userFormError = ref("");
        const userForm = reactive({
            id: null,
            userName: "",
            userPwd: "",
            userHeader: "",
            userPhonenum: "",
            userEmail: "",
            roleIds: []
        });

        const roleLoading = ref(false);
        const roleError = ref("");
        const roleList = ref([]);
        const roleOptions = ref([]);
        const roleQuery = reactive({
            roleName: ""
        });
        const showRoleModal = ref(false);
        const roleSubmitting = ref(false);
        const roleFormError = ref("");
        const roleForm = reactive({
            id: null,
            roleCode: "",
            roleName: "",
            roleDescription: "",
            sortNum: 0,
            enabled: true,
            permissionIds: []
        });

        const permissionLoading = ref(false);
        const permissionError = ref("");
        const permissionTree = ref([]);
        const showPermissionModal = ref(false);
        const permissionSubmitting = ref(false);
        const permissionFormError = ref("");
        const permissionForm = reactive({
            id: null,
            permissionCode: "",
            permissionName: "",
            permissionType: "MENU",
            parentId: 0,
            menuKey: "",
            routePath: "",
            componentPath: "",
            icon: "",
            apiPattern: "",
            httpMethod: "",
            sortNum: 0,
            visible: true,
            description: ""
        });

        const profileSubmitting = ref(false);
        const profileFormError = ref("");
        const showProfileModal = ref(false);
        const profileForm = reactive({
            userName: "",
            userHeader: "",
            userPhonenum: "",
            userEmail: "",
            address: ""
        });

        const passwordSubmitting = ref(false);
        const passwordFormError = ref("");
        const showPasswordModal = ref(false);
        const passwordForm = reactive({
            oldPassword: "",
            newPassword: "",
            confirmPassword: ""
        });

        const logLoading = ref(false);
        const logError = ref("");
        const logPage = ref(defaultPageData());
        const logQuery = reactive({
            userName: "",
            page: 1,
            size: 10
        });
        const accessLogLoading = ref(false);
        const accessLogError = ref("");
        const accessLogPage = ref(defaultPageData());
        const accessLogQuery = reactive({
            userName: "",
            roleCode: "",
            operationType: "",
            page: 1,
            size: 10
        });
        const ruleChangeLogLoading = ref(false);
        const ruleChangeLogError = ref("");
        const ruleChangeLogPage = ref(defaultPageData());
        const ruleChangeLogQuery = reactive({
            operatorName: "",
            page: 1,
            size: 10
        });
        const abnormalAccessLoading = ref(false);
        const abnormalAccessError = ref("");
        const abnormalAccessPage = ref(defaultPageData());
        const abnormalAccessQuery = reactive({
            userName: "",
            ruleName: "",
            severity: "",
            page: 1,
            size: 10
        });

        const studentProfileLoading = ref(false);
        const studentProfileError = ref("");
        const studentProfiles = ref([]);
        const selectedStudentProfile = ref(null);
        const showStudentDetailModal = ref(false);
        const showStudentEditModal = ref(false);
        const studentEditSubmitting = ref(false);
        const studentEditFormError = ref("");
        const studentProfileQuery = reactive({
            studentNo: "",
            name: "",
            className: ""
        });
        const studentEditForm = reactive({
            studentId: null,
            studentNo: "",
            name: "",
            gender: "M",
            birthDate: "",
            phone: "",
            email: "",
            address: ""
        });

        const studentScoreLoading = ref(false);
        const studentScoreError = ref("");
        const studentScores = ref([]);
        const studentScoreQuery = reactive({
            studentNo: "",
            courseName: "",
            semesterName: ""
        });
        const gradeAnalyticsLoading = ref(false);
        const gradeAnalyticsError = ref("");
        const gradeAnalytics = ref(defaultScoreAnalytics());
        const sensitiveAnalyticsLoading = ref(false);
        const sensitiveAnalyticsError = ref("");
        const sensitiveAnalytics = ref(defaultSensitiveAnalytics());
        const dataEntryOptionsLoading = ref(false);
        const dataEntryOptionsLoaded = ref(false);
        const dataEntryOptions = reactive({
            roles: [],
            classes: [],
            courses: [],
            semesters: []
        });
        const showDataEntryModal = ref(false);
        const dataEntrySubmitting = ref(false);
        const dataEntryFormError = ref("");
        const dataEntryMode = ref(DATA_ENTRY_TYPE_USER);
        const dataEntryForm = reactive({
            userName: "",
            userPwd: "",
            userPhonenum: "",
            userEmail: "",
            userHeader: "",
            roleIds: [],
            studentNo: "",
            name: "",
            gender: "M",
            birthDate: "",
            classId: "",
            phone: "",
            email: "",
            idCard: "",
            address: "",
            familyIncome: "",
            bankCard: "",
            scoreStudentNo: "",
            courseId: "",
            semesterId: "",
            score: ""
        });
        const showDataImportModal = ref(false);
        const dataImportSubmitting = ref(false);
        const dataImportError = ref("");
        const dataImportMode = ref(DATA_ENTRY_TYPE_USER);
        const dataImportFile = ref(null);
        const dataImportFileName = ref("");
        const dataImportInputKey = ref(0);
        const dataImportResult = ref(null);
        const maskingRuleLoading = ref(false);
        const maskingRuleError = ref("");
        const maskingRulePage = ref(defaultPageData());
        const maskingRuleRoleOptions = ref([]);
        const maskingRuleFieldOptions = ref([]);
        const showMaskingRuleModal = ref(false);
        const maskingRuleSubmitting = ref(false);
        const maskingRuleFormError = ref("");
        const maskingRuleQuery = reactive({
            roleId: "",
            sensitiveFieldId: "",
            page: 1,
            size: 10
        });
        const maskingRuleForm = reactive({
            roleId: "",
            roleName: "",
            sensitiveFieldId: "",
            fieldLabel: "",
            policyId: "",
            availablePolicies: []
        });

        const sectionMap = {
            dashboard: {
                title: "首页概览",
                headerTitle: "首页概览",
                description: "登录后首页会根据当前账号权限动态加载统计信息与登录日志概览。",
                actionText: "刷新首页"
            },
            profile: {
                title: "个人信息",
                headerTitle: "个人信息",
                description: "查看并维护当前登录用户资料，同时支持单独修改密码。",
                actionText: "刷新资料"
            },
            student: {
                title: "学生信息脱敏查询",
                headerTitle: "学生信息",
                description: "按当前登录角色动态展示学生资料，敏感字段会由数据库脱敏链路自动处理。",
                actionText: "刷新学生信息"
            },
            score: {
                title: "学生成绩脱敏查询",
                headerTitle: "学生成绩",
                description: "按当前登录角色动态展示成绩明细，敏感分数字段会按角色返回不同粒度。",
                actionText: "刷新成绩信息"
            },
            "masking-rule": {
                title: "脱敏规则管理",
                headerTitle: "脱敏规则管理",
                description: "按角色和敏感字段查看当前生效的脱敏策略，并支持直接修改角色对应字段的脱敏规则。",
                actionText: "刷新脱敏规则"
            },
            user: {
                title: "用户管理",
                headerTitle: "用户管理",
                description: "管理系统用户并分配一个或多个角色。",
                actionText: "刷新用户"
            },
            role: {
                title: "角色管理",
                headerTitle: "角色管理",
                description: "通过权限树为角色分配菜单权限和接口权限。",
                actionText: "刷新角色"
            },
            permission: {
                title: "权限管理",
                headerTitle: "权限管理",
                description: "统一维护中文菜单、权限名称与接口权限，驱动动态菜单和接口鉴权。",
                actionText: "刷新权限"
            },
            log: {
                title: "登录日志",
                headerTitle: "登录日志",
                description: "查看登录成功和失败日志，支持按用户名筛选。",
                actionText: "刷新日志"
            },
            "access-log": {
                title: "访问日志",
                headerTitle: "访问日志",
                description: "查看查询学生信息和成绩时自动写入的访问审计记录。",
                actionText: "刷新访问日志"
            },
            "rule-change-log": {
                title: "规则变更日志",
                headerTitle: "规则变更日志",
                description: "查看脱敏规则更新后的数据库侧规则变更记录。",
                actionText: "刷新规则变更日志"
            },
            "abnormal-access": {
                title: "异常访问监控",
                headerTitle: "异常访问监控",
                description: "基于访问日志执行异常检测，识别高频查询、单日大量敏感访问和普通用户异常访问量。",
                actionText: "执行检测"
            }
        };

        sectionMap["student-data-center"] = {
            title: "瀛︾敓鏁版嵁涓績",
            headerTitle: "瀛︾敓鏁版嵁涓績",
            description: "闆嗕腑鏌ョ湅瀛︾敓淇℃伅鍜屾垚缁╂暟鎹紝璁╁鐢熺浉鍏冲姛鑳介泦涓埌鍚屼竴缁勮彍鍗曚笅銆?",
            actionText: "鏌ョ湅瀛︾敓淇℃伅"
        };
        sectionMap["analytics-center"] = {
            title: "鏁版嵁缁熻鍒嗘瀽涓績",
            headerTitle: "鏁版嵁缁熻鍒嗘瀽涓績",
            description: "褰撳墠鍏堜繚鐣欏垎鏋愪腑蹇冨叆鍙ｃ€傚悗缁皢鍦ㄨ繖閲屾壙杞藉鐢熸垚缁╁垎鏋愬拰鏁忔劅鏁版嵁鍒嗘瀽鑳藉姏銆?",
            actionText: "鍒锋柊鍗犱綅椤?"
        };
        sectionMap["grade-analytics"] = {
            title: "瀛︾敓鎴愮哗鍒嗘瀽",
            headerTitle: "瀛︾敓鎴愮哗鍒嗘瀽",
            description: "褰撳墠涓虹浜岄樁娈电殑鍗犱綅鍏ュ彛锛屽悗缁皢鍦ㄨ繖閲屽睍绀烘垚缁╃粺璁′笌鍙鍖栧垎鏋愩€?",
            actionText: "鍒锋柊鍗犱綅椤?"
        };
        sectionMap["sensitive-analytics"] = {
            title: "鏁忔劅鏁版嵁鍒嗘瀽",
            headerTitle: "鏁忔劅鏁版嵁鍒嗘瀽",
            description: "褰撳墠涓虹浜岄樁娈电殑鍗犱綅鍏ュ彛锛屽悗缁皢鎵胯浇鏁忔劅瀛楁銆佽闂秼鍔垮拰瀹夊叏鍒嗘瀽瑙嗗浘銆?",
            actionText: "鍒锋柊鍗犱綅椤?"
        };
        sectionMap["security-center"] = {
            title: "鏁版嵁瀹夊叏涓績",
            headerTitle: "鏁版嵁瀹夊叏涓績",
            description: "灏嗚劚鏁忚鍒欍€佽闂棩蹇椼€佽鍒欏彉鏇存棩蹇椾笌寮傚父璁块棶鐩戞帶闆嗕腑鍦ㄥ悓涓€涓畨鍏ㄤ腑蹇冦€?",
            actionText: "鏌ョ湅鑴辨晱瑙勫垯"
        };
        sectionMap["system-management"] = {
            title: "绯荤粺绠＄悊",
            headerTitle: "绯荤粺绠＄悊",
            description: "灏嗙敤鎴风鐞嗐€佽鑹茬鐞嗐€佹潈闄愮鐞嗚繘琛岀粍缁囷紝璁╃郴缁熼厤缃粨鏋勬洿娓呮櫚銆?",
            actionText: "鏌ョ湅鐢ㄦ埛绠＄悊"
        };

        sectionMap["analytics-center"] = {
            title: "数据统计分析中心",
            headerTitle: "数据统计分析中心",
            description: "集中查看学生成绩分析与敏感数据分析等聚合统计结果，页面仅展示分析视图，不返回敏感明细。",
            actionText: "刷新分析概览"
        };
        sectionMap["grade-analytics"] = {
            title: "学生成绩分析",
            headerTitle: "学生成绩分析",
            description: "复用学生、成绩、课程、学期、专业与学院基础数据，展示学院、专业、课程排名和成绩分布等聚合统计图。",
            actionText: "刷新成绩分析"
        };
        sectionMap["sensitive-analytics"] = {
            title: "敏感数据分析",
            headerTitle: "敏感数据分析",
            description: "复用敏感字段目录、脱敏策略和规则分配，展示覆盖率统计、字段目录和当前角色的真实脱敏可见效果。",
            actionText: "刷新敏感分析"
        };

        const flatMenus = computed(() => flattenMenuTree(currentUser.value.menuTree || []));
        const visibleMenus = computed(() => {
            const expanded = new Set(expandedMenuKeys.value);
            const result = [];
            const visit = (nodes, depth = 0) => {
                (nodes || []).forEach((node) => {
                    result.push({
                        ...node,
                        depth,
                        hasChildren: Boolean(node.children && node.children.length > 0),
                        expanded: expanded.has(node.menuKey)
                    });
                    if (node.children && node.children.length > 0 && expanded.has(node.menuKey)) {
                        visit(node.children, depth + 1);
                    }
                });
            };
            visit(currentUser.value.menuTree || []);
            return result;
        });
        const flattenedPermissionTree = computed(() => flattenPermissionTree(permissionTree.value || []));
        const parentPermissionOptions = computed(() =>
            flattenedPermissionTree.value.filter((item) => item.id !== permissionForm.id)
        );
        const selectedMaskingRulePolicy = computed(() =>
            (maskingRuleForm.availablePolicies || []).find((item) => String(item.policyId) === String(maskingRuleForm.policyId)) || null
        );
        const currentDataEntryMeta = computed(() => dataEntryMeta[dataEntryMode.value] || dataEntryMeta[DATA_ENTRY_TYPE_USER]);
        const currentDataImportMeta = computed(() => dataEntryMeta[dataImportMode.value] || dataEntryMeta[DATA_ENTRY_TYPE_USER]);

        const currentSection = computed(() => sectionMap[activeMenu.value] || {
            title: "控制台",
            headerTitle: "控制台",
            description: "当前菜单没有匹配到页面定义。",
            actionText: "刷新"
        });

        const resolvedRoleCode = computed(() => {
            if (currentUser.value.superAdmin) {
                return ROLE_SUPER_ADMIN;
            }
            const roleCodes = (currentUser.value.roles || []).map((role) => role.roleCode);
            if (roleCodes.includes(ROLE_STUDENT)) {
                return ROLE_STUDENT;
            }
            if (roleCodes.includes(ROLE_DATA_ADMIN)) {
                return ROLE_DATA_ADMIN;
            }
            if (roleCodes.includes(ROLE_TEACHER)) {
                return ROLE_TEACHER;
            }
            if (roleCodes.includes(ROLE_ANALYST)) {
                return ROLE_ANALYST;
            }
            if (roleCodes.includes(ROLE_NORMAL)) {
                return ROLE_NORMAL;
            }
            return roleCodes[0] || ROLE_NORMAL;
        });

        const isStudentScopeLocked = computed(() => resolvedRoleCode.value === ROLE_STUDENT);
        const isStudentUser = computed(() => resolvedRoleCode.value === ROLE_STUDENT);
        const studentAvatarText = computed(() => {
            const name = currentUser.value.studentProfile?.name || currentUser.value.userName || "";
            return name ? name.slice(0, 1) : "学";
        });

        const currentRoleText = computed(() => {
            if (currentUser.value.superAdmin) {
                return "超级管理员";
            }
            const roles = currentUser.value.roles || [];
            return roles.length > 0 ? roles.map((role) => role.roleName).join("、") : "无角色";
        });

        const maskingHintText = computed(() => {
            const roleCode = resolvedRoleCode.value;
            if (roleCode === ROLE_SUPER_ADMIN) {
                return "当前角色可查看原始敏感数据，结果仍经过统一数据库查询链路返回。";
            }
            if (roleCode === ROLE_DATA_ADMIN) {
                return "当前角色可查看原始敏感数据，用于数据管理和核验场景。";
            }
            if (roleCode === ROLE_TEACHER) {
                return "当前角色按教学场景返回部分脱敏数据，便于识别学生但隐藏高敏字段。";
            }
            if (roleCode === ROLE_ANALYST) {
                return "当前角色按分析场景返回更强脱敏或泛化结果，适合统计分析。";
            }
            if (roleCode === ROLE_STUDENT) {
                return "当前角色仅显示本人数据，后端会忽略会扩大查询范围的筛选条件。";
            }
            return "当前角色采用高强度默认脱敏策略，仅返回必要的展示信息。";
        });

        const homeStats = computed(() => [
            {
                label: "可见菜单数",
                value: flatMenus.value.length,
                tip: "根据后端返回的菜单权限树动态计算。"
            },
            {
                label: "用户总数",
                value: homeUserTotal.value === null ? "--" : homeUserTotal.value,
                tip: can("sys:user:view") ? "来自用户分页接口。" : "当前账号没有查看用户统计的权限。"
            },
            {
                label: "登录日志数",
                value: homeLogTotal.value === null ? "--" : homeLogTotal.value,
                tip: can("sys:log:view") ? "来自登录日志分页接口。" : "当前账号没有查看日志的权限。"
            },
            {
                label: "权限编码数",
                value: (currentUser.value.permissionCodes || []).length,
                tip: "JWT 解析后由后端装载到当前安全上下文。"
            }
        ]);

        function can(permissionCode) {
            if (currentUser.value.superAdmin) {
                return true;
            }
            return (currentUser.value.permissionCodes || []).includes(permissionCode);
        }

        function resolveMenuIcon(iconName) {
            return menuIcons[iconName] || menuIcons.default;
        }

        function formatDateTime(value) {
            if (!value) {
                return "未记录";
            }
            return String(value).replace("T", " ");
        }

        function formatRoleNames(roles) {
            if (!roles || roles.length === 0) {
                return "未分配";
            }
            return roles.map((role) => role.roleName).join("、");
        }

        function formatPermissionOption(option) {
            return `${"\u3000".repeat(option.depth)}${option.permissionName}`;
        }

        function formatGender(value) {
            if (value === "M") {
                return "男";
            }
            if (value === "F") {
                return "女";
            }
            return value || "--";
        }

        function formatStudentStatus(value) {
            if (value === 1) {
                return "在读";
            }
            if (value === 0) {
                return "停用";
            }
            return value ?? "--";
        }

        function formatAnalyticsNumber(value) {
            const number = Number(value);
            if (!Number.isFinite(number)) {
                return "--";
            }
            return number.toFixed(2);
        }

        function formatAnalyticsPercent(value) {
            const number = Number(value);
            if (!Number.isFinite(number)) {
                return "--";
            }
            return `${number.toFixed(2)}%`;
        }

        function safeMetricValue(value) {
            const number = Number(value);
            if (!Number.isFinite(number)) {
                return 0;
            }
            return number;
        }

        function paletteColor(index, tones = ["#2f6fe4", "#4f8df0", "#6ea8ff", "#15a38a", "#f1b24a", "#d14c6d"]) {
            return tones[index % tones.length];
        }

        function rankingBarStyle(value, index = 0) {
            const score = Math.max(0, Math.min(100, safeMetricValue(value)));
            return {
                width: `${Math.max(score, 6)}%`,
                background: `linear-gradient(90deg, ${paletteColor(index)} 0%, #9cc2ff 100%)`
            };
        }

        function sumMetric(items, key = "count") {
            return (items || []).reduce((total, item) => total + safeMetricValue(item?.[key]), 0);
        }

        function distributionPercent(value, items) {
            const total = sumMetric(items, "count");
            if (!total) {
                return 0;
            }
            return safeMetricValue(value) / total * 100;
        }

        function distributionBarStyle(value, items, index = 0) {
            const total = sumMetric(items, "count");
            const current = safeMetricValue(value);
            const max = Math.max(...(items || []).map((item) => safeMetricValue(item.count)), 0);
            const ratio = max > 0 ? current / max : 0;
            return {
                height: `${Math.max(ratio * 100, current > 0 ? 12 : 0)}%`,
                background: `linear-gradient(180deg, ${paletteColor(index)} 0%, #c7dcff 100%)`
            };
        }

        function countBarStyle(value, items, index = 0) {
            const current = safeMetricValue(value);
            const max = Math.max(...(items || []).map((item) => safeMetricValue(item.count)), 0);
            const ratio = max > 0 ? current / max : 0;
            return {
                width: `${Math.max(ratio * 100, current > 0 ? 8 : 0)}%`,
                background: `linear-gradient(90deg, ${paletteColor(index, ["#d14c6d", "#eb7b54", "#f1b24a", "#2f6fe4"])} 0%, #f5c0a9 100%)`
            };
        }

        function coverageBarStyle(value, index = 0) {
            const ratio = Math.max(0, Math.min(100, safeMetricValue(value)));
            return {
                width: `${Math.max(ratio, 6)}%`,
                background: `linear-gradient(90deg, ${paletteColor(index, ["#1f8f8b", "#39a7a1", "#67beb9", "#8bd2ce"])} 0%, #b9ebe7 100%)`
            };
        }

        function toggleSidebar() {
            isCollapsed.value = !isCollapsed.value;
        }

        function isMenuExpanded(menuKey) {
            return expandedMenuKeys.value.includes(menuKey);
        }

        function expandAncestorMenus(menuKey) {
            const trail = [];
            const walk = (nodes, parents = []) => {
                for (const node of nodes || []) {
                    if (node.menuKey === menuKey) {
                        trail.push(...parents);
                        return true;
                    }
                    if (walk(node.children || [], [...parents, node.menuKey])) {
                        return true;
                    }
                }
                return false;
            };
            walk(currentUser.value.menuTree || []);
            if (trail.length === 0) {
                return;
            }
            const expanded = new Set(expandedMenuKeys.value);
            trail.forEach((key) => expanded.add(key));
            expandedMenuKeys.value = [...expanded];
        }

        function toggleMenuGroup(menuKey) {
            if (isMenuExpanded(menuKey)) {
                expandedMenuKeys.value = expandedMenuKeys.value.filter((item) => item !== menuKey);
                return;
            }
            expandedMenuKeys.value = [...expandedMenuKeys.value, menuKey];
        }

        function handleUnauthorized() {
            redirectToLogin();
        }

        async function parseResult(response) {
            const text = await response.text();
            const result = text ? JSON.parse(text) : null;
            if (response.status === 401 || result?.code === 401) {
                handleUnauthorized();
                return null;
            }
            return result;
        }

        async function authorizedFetch(url, options = {}) {
            const headers = new Headers(options.headers || {});
            headers.set("Authorization", `Bearer ${getToken() || ""}`);
            return fetch(url, {
                ...options,
                headers
            });
        }

        async function apiRequest(url, options = {}) {
            const response = await authorizedFetch(url, options);
            const result = await parseResult(response);
            if (!result) {
                return { response, result: null };
            }
            if (!response.ok || (result.code !== 200 && result.code !== 201)) {
                throw new Error(result.message || "请求失败");
            }
            return { response, result };
        }

        function ensureActiveMenu() {
            if (activeMenu.value === "profile") {
                return;
            }
            const firstMenu = flatMenus.value[0];
            if (!firstMenu) {
                activeMenu.value = null;
                return;
            }
            if (!flatMenus.value.some((menu) => menu.menuKey === activeMenu.value)) {
                activeMenu.value = firstMenu.menuKey;
            }
            const activeNode = findMenuNodeByKey(currentUser.value.menuTree || [], activeMenu.value);
            if (activeNode?.children?.length > 0) {
                const firstLeaf = flattenMenuTree(activeNode.children || [])[0];
                if (firstLeaf) {
                    activeMenu.value = firstLeaf.menuKey;
                }
            }
            if (activeMenu.value) {
                expandAncestorMenus(activeMenu.value);
            }
        }

        async function loadCurrentUser() {
            const { result } = await apiRequest("/api/user/me");
            currentUser.value = result.data || {};
            localStorage.setItem(USER_KEY, JSON.stringify(currentUser.value));
            ensureActiveMenu();
        }

        async function refreshContext(reloadSection = true) {
            await loadCurrentUser();
            if (reloadSection && activeMenu.value) {
                await loadSectionData(activeMenu.value);
            }
        }

        async function loadHomeData() {
            const tasks = [];
            if (can("sys:user:view")) {
                tasks.push(apiRequest(`/api/users?${buildQuery({ page: 1, size: 1 })}`).then(({ result }) => {
                    homeUserTotal.value = result.data.total || 0;
                }));
            } else {
                homeUserTotal.value = null;
            }

            if (can("sys:log:view")) {
                tasks.push(apiRequest(`/api/login-logs?${buildQuery({ page: 1, size: 5 })}`).then(({ result }) => {
                    homeLogTotal.value = result.data.total || 0;
                    homeRecentLogs.value = result.data.records || [];
                }));
            } else {
                homeLogTotal.value = null;
                homeRecentLogs.value = [];
            }
            await Promise.all(tasks);
        }

        async function loadUsers() {
            userLoading.value = true;
            userError.value = "";
            try {
                const { result } = await apiRequest(`/api/users?${buildQuery(userQuery)}`);
                userPage.value = result.data || defaultPageData();
            } catch (error) {
                userError.value = error.message || "读取用户数据失败";
            } finally {
                userLoading.value = false;
            }
        }

        async function loadRoleOptions() {
            if (!can("sys:role:view")) {
                roleOptions.value = [];
                return;
            }
            const { result } = await apiRequest("/api/roles/options");
            roleOptions.value = result.data || [];
        }

        async function loadRoles() {
            roleLoading.value = true;
            roleError.value = "";
            try {
                const query = buildQuery(roleQuery);
                const { result } = await apiRequest(query ? `/api/roles?${query}` : "/api/roles");
                roleList.value = result.data || [];
                await loadRoleOptions();
            } catch (error) {
                roleError.value = error.message || "读取角色数据失败";
            } finally {
                roleLoading.value = false;
            }
        }

        async function loadPermissions() {
            permissionLoading.value = true;
            permissionError.value = "";
            try {
                const { result } = await apiRequest("/api/permissions/tree");
                permissionTree.value = result.data || [];
            } catch (error) {
                permissionError.value = error.message || "读取权限数据失败";
            } finally {
                permissionLoading.value = false;
            }
        }

        async function loadLogs() {
            logLoading.value = true;
            logError.value = "";
            try {
                const { result } = await apiRequest(`/api/login-logs?${buildQuery(logQuery)}`);
                logPage.value = result.data || defaultPageData();
            } catch (error) {
                logError.value = error.message || "读取日志数据失败";
            } finally {
                logLoading.value = false;
            }
        }

        async function loadAccessLogs() {
            accessLogLoading.value = true;
            accessLogError.value = "";
            try {
                const { result } = await apiRequest(`/api/access-logs?${buildQuery(accessLogQuery)}`);
                accessLogPage.value = result.data || defaultPageData();
            } catch (error) {
                accessLogError.value = error.message || "读取访问日志失败";
            } finally {
                accessLogLoading.value = false;
            }
        }

        async function loadRuleChangeLogs() {
            ruleChangeLogLoading.value = true;
            ruleChangeLogError.value = "";
            try {
                const { result } = await apiRequest(`/api/rule-change-logs?${buildQuery(ruleChangeLogQuery)}`);
                ruleChangeLogPage.value = result.data || defaultPageData();
            } catch (error) {
                ruleChangeLogError.value = error.message || "读取规则变更日志失败";
            } finally {
                ruleChangeLogLoading.value = false;
            }
        }

        async function loadAbnormalAccess() {
            abnormalAccessLoading.value = true;
            abnormalAccessError.value = "";
            try {
                const { result } = await apiRequest(`/api/abnormal-access?${buildQuery(abnormalAccessQuery)}`);
                abnormalAccessPage.value = result.data || defaultPageData();
            } catch (error) {
                abnormalAccessError.value = error.message || "读取异常访问记录失败";
            } finally {
                abnormalAccessLoading.value = false;
            }
        }

        async function loadStudentProfiles() {
            studentProfileLoading.value = true;
            studentProfileError.value = "";
            try {
                const { result } = await apiRequest(`/api/student-profiles?${buildQuery(studentProfileQuery)}`);
                studentProfiles.value = result.data || [];
            } catch (error) {
                studentProfileError.value = error.message || "读取学生信息失败";
            } finally {
                studentProfileLoading.value = false;
            }
        }

        async function loadStudentScores() {
            studentScoreLoading.value = true;
            studentScoreError.value = "";
            try {
                const { result } = await apiRequest(`/api/student-scores?${buildQuery(studentScoreQuery)}`);
                studentScores.value = result.data || [];
            } catch (error) {
                studentScoreError.value = error.message || "读取学生成绩失败";
            } finally {
                studentScoreLoading.value = false;
            }
        }

        async function loadGradeAnalytics() {
            gradeAnalyticsLoading.value = true;
            gradeAnalyticsError.value = "";
            try {
                const { result } = await apiRequest("/api/analytics/score");
                gradeAnalytics.value = result.data || defaultScoreAnalytics();
            } catch (error) {
                gradeAnalytics.value = defaultScoreAnalytics();
                gradeAnalyticsError.value = error.message || "读取学生成绩分析失败";
            } finally {
                gradeAnalyticsLoading.value = false;
            }
        }

        async function loadSensitiveAnalytics() {
            sensitiveAnalyticsLoading.value = true;
            sensitiveAnalyticsError.value = "";
            try {
                const { result } = await apiRequest("/api/analytics/sensitive");
                sensitiveAnalytics.value = result.data || defaultSensitiveAnalytics();
            } catch (error) {
                sensitiveAnalytics.value = defaultSensitiveAnalytics();
                sensitiveAnalyticsError.value = error.message || "读取敏感数据分析失败";
            } finally {
                sensitiveAnalyticsLoading.value = false;
            }
        }

        async function loadDataEntryOptions(force = false) {
            if (dataEntryOptionsLoading.value) {
                return;
            }
            if (dataEntryOptionsLoaded.value && !force) {
                return;
            }
            dataEntryOptionsLoading.value = true;
            try {
                const { result } = await apiRequest("/api/data-entry/options");
                dataEntryOptions.roles = result.data?.roles || [];
                dataEntryOptions.classes = result.data?.classes || [];
                dataEntryOptions.courses = result.data?.courses || [];
                dataEntryOptions.semesters = result.data?.semesters || [];
                dataEntryOptionsLoaded.value = true;
            } finally {
                dataEntryOptionsLoading.value = false;
            }
        }

        async function refreshDataListByType(type) {
            if (type === DATA_ENTRY_TYPE_USER) {
                userQuery.page = 1;
                await loadUsers();
                await refreshContext(false);
                if (activeMenu.value === "dashboard") {
                    await loadHomeData();
                }
                return;
            }
            if (type === DATA_ENTRY_TYPE_STUDENT) {
                await loadStudentProfiles();
                return;
            }
            if (type === DATA_ENTRY_TYPE_SCORE) {
                await loadStudentScores();
            }
        }

        async function loadMaskingRuleOptions() {
            const { result } = await apiRequest("/api/masking-rules/options");
            maskingRuleRoleOptions.value = result.data?.roles || [];
            maskingRuleFieldOptions.value = result.data?.fields || [];
        }

        async function loadMaskingRules() {
            maskingRuleLoading.value = true;
            maskingRuleError.value = "";
            try {
                const query = buildQuery(maskingRuleQuery);
                const { result } = await apiRequest(query ? `/api/masking-rules?${query}` : "/api/masking-rules");
                maskingRulePage.value = result.data || defaultPageData();
                if (maskingRuleRoleOptions.value.length === 0 || maskingRuleFieldOptions.value.length === 0) {
                    await loadMaskingRuleOptions();
                }
            } catch (error) {
                maskingRuleError.value = error.message || "读取脱敏规则失败";
            } finally {
                maskingRuleLoading.value = false;
            }
        }

        async function loadSectionData(menuKey) {
            if (!menuKey) {
                return;
            }
            if (menuKey === "student-data-center"
                || menuKey === "analytics-center"
                || menuKey === "security-center"
                || menuKey === "system-management") {
                return;
            }
            if (menuKey === "dashboard") {
                await loadHomeData();
                return;
            }
            if (menuKey === "profile") {
                await loadCurrentUser();
                return;
            }
            if (menuKey === "student") {
                await loadStudentProfiles();
                return;
            }
            if (menuKey === "score") {
                await loadStudentScores();
                return;
            }
            if (menuKey === "grade-analytics") {
                await loadGradeAnalytics();
                return;
            }
            if (menuKey === "sensitive-analytics") {
                await loadSensitiveAnalytics();
                return;
            }
            if (menuKey === "masking-rule") {
                await loadMaskingRules();
                return;
            }
            if (menuKey === "user") {
                await Promise.all([loadUsers(), loadRoleOptions()]);
                return;
            }
            if (menuKey === "role") {
                await Promise.all([loadRoles(), loadPermissions()]);
                return;
            }
            if (menuKey === "permission") {
                await loadPermissions();
                return;
            }
            if (menuKey === "log") {
                await loadLogs();
                return;
            }
            if (menuKey === "access-log") {
                await loadAccessLogs();
                return;
            }
            if (menuKey === "rule-change-log") {
                await loadRuleChangeLogs();
                return;
            }
            if (menuKey === "abnormal-access") {
                await loadAbnormalAccess();
            }
        }

        async function activateMenu(menuKey) {
            const targetMenu = findMenuNodeByKey(currentUser.value.menuTree || [], menuKey);
            if (!targetMenu) {
                return;
            }
            if (targetMenu.children && targetMenu.children.length > 0) {
                toggleMenuGroup(menuKey);
                return;
            }
            expandAncestorMenus(menuKey);
            activeMenu.value = menuKey;
            await loadSectionData(menuKey);
        }

        async function openProfileSection() {
            activeMenu.value = "profile";
            await loadSectionData("profile");
        }

        async function handlePrimaryAction() {
            if (activeMenu.value) {
                if (activeMenu.value === "user" && can("sys:user:create")) {
                    await openDataEntryModal(DATA_ENTRY_TYPE_USER);
                    return;
                }
                if (activeMenu.value === "student" && can("sys:user:create")) {
                    await openDataEntryModal(DATA_ENTRY_TYPE_STUDENT);
                    return;
                }
                if (activeMenu.value === "score" && can("sys:user:create")) {
                    await openDataEntryModal(DATA_ENTRY_TYPE_SCORE);
                    return;
                }
                if (activeMenu.value === "abnormal-access" && can("sys:abnormal-access:detect")) {
                    await runAbnormalAccessDetection();
                    return;
                }
                await loadSectionData(activeMenu.value);
            }
        }

        async function searchUsers() {
            userQuery.page = 1;
            await loadUsers();
        }

        async function resetUserSearch() {
            userQuery.userName = "";
            userQuery.page = 1;
            await loadUsers();
        }

        async function changeUserPage(page) {
            if (page < 1 || page > (userPage.value.totalPages || 1)) {
                return;
            }
            userQuery.page = page;
            await loadUsers();
        }

        async function searchStudentProfiles() {
            await loadStudentProfiles();
        }

        async function refreshStudentProfiles() {
            await loadStudentProfiles();
        }

        async function resetStudentProfileSearch() {
            studentProfileQuery.studentNo = "";
            studentProfileQuery.name = "";
            studentProfileQuery.className = "";
            await loadStudentProfiles();
        }

        async function searchStudentScores() {
            await loadStudentScores();
        }

        async function resetStudentScoreSearch() {
            studentScoreQuery.studentNo = "";
            studentScoreQuery.courseName = "";
            studentScoreQuery.semesterName = "";
            await loadStudentScores();
        }

        async function searchAbnormalAccess() {
            abnormalAccessQuery.page = 1;
            await loadAbnormalAccess();
        }

        async function resetAbnormalAccessSearch() {
            abnormalAccessQuery.userName = "";
            abnormalAccessQuery.ruleName = "";
            abnormalAccessQuery.severity = "";
            abnormalAccessQuery.page = 1;
            await loadAbnormalAccess();
        }

        async function changeAbnormalAccessPage(page) {
            if (page < 1 || page > (abnormalAccessPage.value.totalPages || 1)) {
                return;
            }
            abnormalAccessQuery.page = page;
            await loadAbnormalAccess();
        }

        async function runAbnormalAccessDetection() {
            abnormalAccessLoading.value = true;
            abnormalAccessError.value = "";
            try {
                await apiRequest("/api/abnormal-access/detect", { method: "POST" });
                await loadAbnormalAccess();
            } catch (error) {
                abnormalAccessError.value = error.message || "执行异常访问检测失败";
            } finally {
                abnormalAccessLoading.value = false;
            }
        }

        function resetDataEntryForm() {
            dataEntryForm.userName = "";
            dataEntryForm.userPwd = "";
            dataEntryForm.userPhonenum = "";
            dataEntryForm.userEmail = "";
            dataEntryForm.userHeader = "";
            dataEntryForm.roleIds = [];
            dataEntryForm.studentNo = "";
            dataEntryForm.name = "";
            dataEntryForm.gender = "M";
            dataEntryForm.birthDate = "";
            dataEntryForm.classId = "";
            dataEntryForm.phone = "";
            dataEntryForm.email = "";
            dataEntryForm.idCard = "";
            dataEntryForm.address = "";
            dataEntryForm.familyIncome = "";
            dataEntryForm.bankCard = "";
            dataEntryForm.scoreStudentNo = "";
            dataEntryForm.courseId = "";
            dataEntryForm.semesterId = "";
            dataEntryForm.score = "";
            dataEntryFormError.value = "";
        }

        async function openDataEntryModal(type) {
            dataEntryMode.value = type;
            resetDataEntryForm();
            if (type !== DATA_ENTRY_TYPE_USER || can("sys:role:view")) {
                await loadDataEntryOptions();
            }
            showDataEntryModal.value = true;
        }

        function closeDataEntryModal() {
            showDataEntryModal.value = false;
            dataEntrySubmitting.value = false;
            resetDataEntryForm();
        }

        function buildDataEntryPayload() {
            if (dataEntryMode.value === DATA_ENTRY_TYPE_USER) {
                if (!dataEntryForm.userName) {
                    throw new Error("请输入用户名");
                }
                if (!dataEntryForm.userPwd) {
                    throw new Error("请输入密码");
                }
                return {
                    url: "/api/users",
                    payload: {
                        userName: dataEntryForm.userName,
                        userPwd: dataEntryForm.userPwd,
                        userHeader: dataEntryForm.userHeader || null,
                        userPhonenum: dataEntryForm.userPhonenum || null,
                        userEmail: dataEntryForm.userEmail || null,
                        roleIds: dataEntryForm.roleIds || []
                    }
                };
            }
            if (dataEntryMode.value === DATA_ENTRY_TYPE_STUDENT) {
                if (!dataEntryForm.studentNo || !dataEntryForm.name || !dataEntryForm.gender || !dataEntryForm.classId) {
                    throw new Error("请完整填写学号、姓名、性别和班级");
                }
                return {
                    url: "/api/students",
                    payload: {
                        studentNo: dataEntryForm.studentNo,
                        name: dataEntryForm.name,
                        gender: dataEntryForm.gender,
                        birthDate: dataEntryForm.birthDate || null,
                        classId: Number(dataEntryForm.classId),
                        status: 1,
                        phone: dataEntryForm.phone || null,
                        email: dataEntryForm.email || null,
                        idCard: dataEntryForm.idCard || null,
                        address: dataEntryForm.address || null,
                        familyIncome: dataEntryForm.familyIncome === "" ? null : Number(dataEntryForm.familyIncome),
                        bankCard: dataEntryForm.bankCard || null
                    }
                };
            }
            if (!dataEntryForm.scoreStudentNo || !dataEntryForm.courseId || !dataEntryForm.semesterId || dataEntryForm.score === "") {
                throw new Error("请完整填写学号、课程、学期和成绩");
            }
            return {
                url: "/api/students/scores",
                payload: {
                    studentNo: dataEntryForm.scoreStudentNo,
                    courseId: Number(dataEntryForm.courseId),
                    semesterId: Number(dataEntryForm.semesterId),
                    score: Number(dataEntryForm.score)
                }
            };
        }

        async function submitDataEntryForm() {
            dataEntrySubmitting.value = true;
            dataEntryFormError.value = "";
            try {
                const { url, payload } = buildDataEntryPayload();
                await apiRequest(url, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(payload)
                });
                closeDataEntryModal();
                await refreshDataListByType(dataEntryMode.value);
                window.alert((dataEntryMeta[dataEntryMode.value] || {}).successMessage || "保存成功");
            } catch (error) {
                dataEntryFormError.value = error.message || "提交失败";
            } finally {
                dataEntrySubmitting.value = false;
            }
        }

        function resetDataImportState() {
            dataImportError.value = "";
            dataImportFile.value = null;
            dataImportFileName.value = "";
            dataImportResult.value = null;
            dataImportInputKey.value += 1;
        }

        function openDataImportModal(type) {
            dataImportMode.value = type;
            resetDataImportState();
            showDataImportModal.value = true;
        }

        function closeDataImportModal() {
            showDataImportModal.value = false;
            dataImportSubmitting.value = false;
            resetDataImportState();
        }

        function handleDataImportFileChange(event) {
            const file = event?.target?.files?.[0] || null;
            dataImportFile.value = file;
            dataImportFileName.value = file ? file.name : "";
            dataImportError.value = "";
            dataImportResult.value = null;
        }

        async function submitDataImport() {
            if (!dataImportFile.value) {
                dataImportError.value = "请先选择要导入的 Excel 文件";
                return;
            }
            dataImportSubmitting.value = true;
            dataImportError.value = "";
            try {
                const formData = new FormData();
                formData.append("file", dataImportFile.value);
                const response = await authorizedFetch(`/api/import/${dataImportMode.value}`, {
                    method: "POST",
                    body: formData
                });
                const result = await parseResult(response);
                if (!result) {
                    return;
                }
                if (!response.ok || (result.code !== 200 && result.code !== 201)) {
                    throw new Error(result.message || "导入失败");
                }
                dataImportResult.value = result.data || null;
                await refreshDataListByType(dataImportMode.value);
            } catch (error) {
                dataImportError.value = error.message || "导入失败";
            } finally {
                dataImportSubmitting.value = false;
            }
        }

        async function searchMaskingRules() {
            maskingRuleQuery.page = 1;
            await loadMaskingRules();
        }

        async function resetMaskingRuleSearch() {
            maskingRuleQuery.roleId = "";
            maskingRuleQuery.sensitiveFieldId = "";
            maskingRuleQuery.page = 1;
            await loadMaskingRules();
        }

        async function changeMaskingRulePage(page) {
            if (page < 1 || page > (maskingRulePage.value.totalPages || 1)) {
                return;
            }
            maskingRuleQuery.page = page;
            await loadMaskingRules();
        }

        function resetMaskingRuleForm() {
            maskingRuleForm.roleId = "";
            maskingRuleForm.roleName = "";
            maskingRuleForm.sensitiveFieldId = "";
            maskingRuleForm.fieldLabel = "";
            maskingRuleForm.policyId = "";
            maskingRuleForm.availablePolicies = [];
            maskingRuleFormError.value = "";
        }

        function openMaskingRuleModal(row) {
            maskingRuleForm.roleId = row.roleId ? String(row.roleId) : "";
            maskingRuleForm.roleName = row.roleName || "";
            maskingRuleForm.sensitiveFieldId = row.sensitiveFieldId ? String(row.sensitiveFieldId) : "";
            maskingRuleForm.fieldLabel = row.fieldLabel || `${row.tableName}.${row.columnName}`;
            maskingRuleForm.policyId = row.effectivePolicyId ? String(row.effectivePolicyId) : "";
            maskingRuleForm.availablePolicies = row.availablePolicies || [];
            maskingRuleFormError.value = "";
            showMaskingRuleModal.value = true;
        }

        function closeMaskingRuleModal() {
            showMaskingRuleModal.value = false;
            resetMaskingRuleForm();
        }

        async function submitMaskingRuleForm() {
            if (!maskingRuleForm.roleId || !maskingRuleForm.sensitiveFieldId || !maskingRuleForm.policyId) {
                maskingRuleFormError.value = "请选择角色、敏感字段和目标脱敏策略";
                return;
            }
            maskingRuleSubmitting.value = true;
            maskingRuleFormError.value = "";
            try {
                await apiRequest("/api/masking-rules", {
                    method: "PUT",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        roleId: Number(maskingRuleForm.roleId),
                        sensitiveFieldId: Number(maskingRuleForm.sensitiveFieldId),
                        policyId: Number(maskingRuleForm.policyId)
                    })
                });
                closeMaskingRuleModal();
                await loadMaskingRules();
                window.alert("脱敏规则更新成功，重新查询学生信息或成绩即可看到最新效果");
            } catch (error) {
                maskingRuleFormError.value = error.message || "保存脱敏规则失败";
            } finally {
                maskingRuleSubmitting.value = false;
            }
        }

        function resetUserForm() {
            userForm.id = null;
            userForm.userName = "";
            userForm.userPwd = "";
            userForm.userHeader = "";
            userForm.userPhonenum = "";
            userForm.userEmail = "";
            userForm.roleIds = [];
            userFormError.value = "";
        }

        function openCreateUserModal() {
            openDataEntryModal(DATA_ENTRY_TYPE_USER);
        }

        function openEditUserModal(user) {
            userForm.id = user.id;
            userForm.userName = user.userName || "";
            userForm.userPwd = "";
            userForm.userHeader = user.userHeader || "";
            userForm.userPhonenum = user.userPhonenum || "";
            userForm.userEmail = user.userEmail || "";
            userForm.roleIds = [...(user.roleIds || [])];
            userFormError.value = "";
            showUserModal.value = true;
        }

        function closeUserModal() {
            showUserModal.value = false;
            resetUserForm();
        }

        function validateUserForm() {
            if (!userForm.userName) {
                userFormError.value = "用户名不能为空";
                return false;
            }
            if (!userForm.id && !userForm.userPwd) {
                userFormError.value = "新增用户时密码不能为空";
                return false;
            }
            userFormError.value = "";
            return true;
        }

        async function submitUserForm() {
            if (!validateUserForm()) {
                return;
            }
            userSubmitting.value = true;
            userFormError.value = "";
            const isEdit = Boolean(userForm.id);
            const payload = {
                userName: userForm.userName,
                userPwd: userForm.userPwd,
                userHeader: userForm.userHeader || null,
                userPhonenum: userForm.userPhonenum || null,
                userEmail: userForm.userEmail || null,
                roleIds: userForm.roleIds || []
            };
            if (isEdit && !payload.userPwd) {
                delete payload.userPwd;
            }

            try {
                await apiRequest(isEdit ? `/api/users/${userForm.id}` : "/api/users", {
                    method: isEdit ? "PUT" : "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(payload)
                });
                closeUserModal();
                await loadUsers();
                await refreshContext(false);
                if (activeMenu.value === "dashboard") {
                    await loadHomeData();
                }
                window.alert(isEdit ? "用户修改成功" : "用户创建成功");
            } catch (error) {
                userFormError.value = error.message || "提交失败";
            } finally {
                userSubmitting.value = false;
            }
        }

        async function deleteUser(user) {
            if (!window.confirm(`确认删除用户「${user.userName}」吗？`)) {
                return;
            }
            try {
                await apiRequest(`/api/users/${user.id}`, {
                    method: "DELETE"
                });
                await loadUsers();
                await refreshContext(false);
                if (activeMenu.value === "dashboard") {
                    await loadHomeData();
                }
                window.alert("用户删除成功");
            } catch (error) {
                window.alert(error.message || "删除失败");
            }
        }

        function resetRoleForm() {
            roleForm.id = null;
            roleForm.roleCode = "";
            roleForm.roleName = "";
            roleForm.roleDescription = "";
            roleForm.sortNum = 0;
            roleForm.enabled = true;
            roleForm.permissionIds = [];
            roleFormError.value = "";
        }

        function openCreateRoleModal() {
            resetRoleForm();
            showRoleModal.value = true;
        }

        function openEditRoleModal(role) {
            roleForm.id = role.id;
            roleForm.roleCode = role.roleCode || "";
            roleForm.roleName = role.roleName || "";
            roleForm.roleDescription = role.roleDescription || "";
            roleForm.sortNum = role.sortNum ?? 0;
            roleForm.enabled = role.enabled !== false;
            roleForm.permissionIds = [...(role.permissionIds || [])];
            roleFormError.value = "";
            showRoleModal.value = true;
        }

        function closeRoleModal() {
            showRoleModal.value = false;
            resetRoleForm();
        }

        function selectAllPermissions() {
            roleForm.permissionIds = flattenedPermissionTree.value.map((item) => item.id);
        }

        function clearAllPermissions() {
            roleForm.permissionIds = [];
        }

        async function submitRoleForm() {
            if (!roleForm.roleCode || !roleForm.roleName) {
                roleFormError.value = "角色编码和角色名称不能为空";
                return;
            }
            roleSubmitting.value = true;
            roleFormError.value = "";
            const isEdit = Boolean(roleForm.id);
            const payload = {
                roleCode: roleForm.roleCode,
                roleName: roleForm.roleName,
                roleDescription: roleForm.roleDescription || null,
                sortNum: Number(roleForm.sortNum || 0),
                enabled: Boolean(roleForm.enabled),
                permissionIds: roleForm.permissionIds || []
            };

            try {
                await apiRequest(isEdit ? `/api/roles/${roleForm.id}` : "/api/roles", {
                    method: isEdit ? "PUT" : "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(payload)
                });
                closeRoleModal();
                await Promise.all([loadRoles(), loadPermissions(), refreshContext(false)]);
                if (activeMenu.value === "dashboard") {
                    await loadHomeData();
                }
                window.alert(isEdit ? "角色修改成功" : "角色创建成功");
            } catch (error) {
                roleFormError.value = error.message || "提交失败";
            } finally {
                roleSubmitting.value = false;
            }
        }

        async function deleteRole(role) {
            if (!window.confirm(`确认删除角色「${role.roleName}」吗？`)) {
                return;
            }
            try {
                await apiRequest(`/api/roles/${role.id}`, {
                    method: "DELETE"
                });
                await Promise.all([loadRoles(), loadRoleOptions(), refreshContext(false)]);
                if (activeMenu.value === "dashboard") {
                    await loadHomeData();
                }
                window.alert("角色删除成功");
            } catch (error) {
                window.alert(error.message || "删除失败");
            }
        }

        async function resetRoleSearch() {
            roleQuery.roleName = "";
            await loadRoles();
        }

        function resetPermissionForm() {
            permissionForm.id = null;
            permissionForm.permissionCode = "";
            permissionForm.permissionName = "";
            permissionForm.permissionType = "MENU";
            permissionForm.parentId = 0;
            permissionForm.menuKey = "";
            permissionForm.routePath = "";
            permissionForm.componentPath = "";
            permissionForm.icon = "";
            permissionForm.apiPattern = "";
            permissionForm.httpMethod = "";
            permissionForm.sortNum = 0;
            permissionForm.visible = true;
            permissionForm.description = "";
            permissionFormError.value = "";
        }

        function openCreatePermissionModal() {
            resetPermissionForm();
            showPermissionModal.value = true;
        }

        function openEditPermissionModal(permission) {
            permissionForm.id = permission.id;
            permissionForm.permissionCode = permission.permissionCode || "";
            permissionForm.permissionName = permission.permissionName || "";
            permissionForm.permissionType = permission.permissionType || "MENU";
            permissionForm.parentId = permission.parentId ?? 0;
            permissionForm.menuKey = permission.menuKey || "";
            permissionForm.routePath = permission.routePath || "";
            permissionForm.componentPath = permission.componentPath || "";
            permissionForm.icon = permission.icon || "";
            permissionForm.apiPattern = permission.apiPattern || "";
            permissionForm.httpMethod = permission.httpMethod || "";
            permissionForm.sortNum = permission.sortNum ?? 0;
            permissionForm.visible = permission.visible !== false;
            permissionForm.description = permission.description || "";
            permissionFormError.value = "";
            showPermissionModal.value = true;
        }

        function closePermissionModal() {
            showPermissionModal.value = false;
            resetPermissionForm();
        }

        async function submitPermissionForm() {
            if (!permissionForm.permissionCode || !permissionForm.permissionName) {
                permissionFormError.value = "权限编码和权限名称不能为空";
                return;
            }
            permissionSubmitting.value = true;
            permissionFormError.value = "";
            const isEdit = Boolean(permissionForm.id);
            const payload = {
                permissionCode: permissionForm.permissionCode,
                permissionName: permissionForm.permissionName,
                permissionType: permissionForm.permissionType,
                parentId: Number(permissionForm.parentId || 0),
                menuKey: permissionForm.permissionType === "MENU" ? (permissionForm.menuKey || null) : null,
                routePath: permissionForm.permissionType === "MENU" ? (permissionForm.routePath || null) : null,
                componentPath: permissionForm.permissionType === "MENU" ? (permissionForm.componentPath || null) : null,
                icon: permissionForm.permissionType === "MENU" ? (permissionForm.icon || null) : null,
                apiPattern: permissionForm.permissionType === "API" ? (permissionForm.apiPattern || null) : null,
                httpMethod: permissionForm.permissionType === "API" ? (permissionForm.httpMethod || null) : null,
                sortNum: Number(permissionForm.sortNum || 0),
                visible: Boolean(permissionForm.visible),
                description: permissionForm.description || null
            };
            try {
                await apiRequest(isEdit ? `/api/permissions/${permissionForm.id}` : "/api/permissions", {
                    method: isEdit ? "PUT" : "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(payload)
                });
                closePermissionModal();
                await Promise.all([loadPermissions(), refreshContext(false)]);
                if (activeMenu.value === "dashboard") {
                    await loadHomeData();
                }
                window.alert(isEdit ? "权限修改成功" : "权限创建成功");
            } catch (error) {
                permissionFormError.value = error.message || "提交失败";
            } finally {
                permissionSubmitting.value = false;
            }
        }

        async function deletePermission(permission) {
            if (!window.confirm(`确认删除权限「${permission.permissionName}」吗？`)) {
                return;
            }
            try {
                await apiRequest(`/api/permissions/${permission.id}`, {
                    method: "DELETE"
                });
                await Promise.all([loadPermissions(), refreshContext(false)]);
                if (activeMenu.value === "dashboard") {
                    await loadHomeData();
                }
                window.alert("权限删除成功");
            } catch (error) {
                window.alert(error.message || "删除失败");
            }
        }

        function resetProfileForm() {
            profileForm.userName = currentUser.value.userName || "";
            profileForm.userHeader = currentUser.value.userHeader || "";
            profileForm.userPhonenum = currentUser.value.studentProfile?.phone || currentUser.value.userPhonenum || "";
            profileForm.userEmail = currentUser.value.studentProfile?.email || currentUser.value.userEmail || "";
            profileForm.address = currentUser.value.studentProfile?.address || "";
            profileFormError.value = "";
        }

        function openProfileModal() {
            resetProfileForm();
            showProfileModal.value = true;
        }

        function closeProfileModal() {
            showProfileModal.value = false;
            profileFormError.value = "";
        }

        async function submitProfileForm() {
            if (!isStudentUser.value && !profileForm.userName) {
                profileFormError.value = "用户名不能为空";
                return;
            }
            profileSubmitting.value = true;
            profileFormError.value = "";
            try {
                await apiRequest("/api/user/profile", {
                    method: "PUT",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        userName: isStudentUser.value ? (currentUser.value.userName || "") : profileForm.userName,
                        userHeader: profileForm.userHeader || null,
                        userPhonenum: profileForm.userPhonenum || null,
                        userEmail: profileForm.userEmail || null,
                        address: profileForm.address || null
                    })
                });
                closeProfileModal();
                await refreshContext(false);
                window.alert("个人资料更新成功");
            } catch (error) {
                profileFormError.value = error.message || "保存失败";
            } finally {
                profileSubmitting.value = false;
            }
        }

        function resetPasswordForm() {
            passwordForm.oldPassword = "";
            passwordForm.newPassword = "";
            passwordForm.confirmPassword = "";
            passwordFormError.value = "";
        }

        function openPasswordModal() {
            resetPasswordForm();
            showPasswordModal.value = true;
        }

        function closePasswordModal() {
            showPasswordModal.value = false;
            resetPasswordForm();
        }

        async function submitPasswordForm() {
            if (!passwordForm.oldPassword) {
                passwordFormError.value = "请输入旧密码";
                return;
            }
            if (!passwordForm.newPassword) {
                passwordFormError.value = "请输入新密码";
                return;
            }
            if (passwordForm.newPassword !== passwordForm.confirmPassword) {
                passwordFormError.value = "两次输入的新密码不一致";
                return;
            }
            passwordSubmitting.value = true;
            passwordFormError.value = "";
            try {
                await apiRequest("/api/user/password", {
                    method: "PUT",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        oldPassword: passwordForm.oldPassword,
                        newPassword: passwordForm.newPassword,
                        confirmPassword: passwordForm.confirmPassword
                    })
                });
                closePasswordModal();
                window.alert("密码修改成功");
            } catch (error) {
                passwordFormError.value = error.message || "修改失败";
            } finally {
                passwordSubmitting.value = false;
            }
        }

        function openStudentDetailModal(student) {
            selectedStudentProfile.value = { ...student };
            showStudentDetailModal.value = true;
        }

        function closeStudentDetailModal() {
            selectedStudentProfile.value = null;
            showStudentDetailModal.value = false;
        }

        function resetStudentEditForm() {
            studentEditForm.studentId = null;
            studentEditForm.studentNo = "";
            studentEditForm.name = "";
            studentEditForm.gender = "M";
            studentEditForm.birthDate = "";
            studentEditForm.phone = "";
            studentEditForm.email = "";
            studentEditForm.address = "";
            studentEditFormError.value = "";
        }

        function openStudentEditModal(student) {
            studentEditForm.studentId = student.studentId;
            studentEditForm.studentNo = student.studentNo || "";
            studentEditForm.name = student.name || "";
            studentEditForm.gender = student.gender || "M";
            studentEditForm.birthDate = student.birthDate || "";
            studentEditForm.phone = student.phone || "";
            studentEditForm.email = student.email || "";
            studentEditForm.address = student.address || "";
            studentEditFormError.value = "";
            showStudentEditModal.value = true;
        }

        function closeStudentEditModal() {
            showStudentEditModal.value = false;
            resetStudentEditForm();
        }

        async function submitStudentEditForm() {
            if (!studentEditForm.studentId) {
                studentEditFormError.value = "学生信息不完整";
                return;
            }
            if (!studentEditForm.name) {
                studentEditFormError.value = "姓名不能为空";
                return;
            }
            studentEditSubmitting.value = true;
            studentEditFormError.value = "";
            try {
                await apiRequest(`/api/students/${studentEditForm.studentId}`, {
                    method: "PUT",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        name: studentEditForm.name,
                        gender: studentEditForm.gender,
                        birthDate: studentEditForm.birthDate || null,
                        status: 1,
                        phone: studentEditForm.phone || null,
                        email: studentEditForm.email || null,
                        address: studentEditForm.address || null
                    })
                });
                closeStudentEditModal();
                await loadStudentProfiles();
                window.alert("学生信息更新成功");
            } catch (error) {
                studentEditFormError.value = error.message || "保存失败";
            } finally {
                studentEditSubmitting.value = false;
            }
        }

        async function deleteStudent(student) {
            if (!window.confirm(`确认删除学生「${student.name || student.studentNo}」吗？`)) {
                return;
            }
            try {
                await apiRequest(`/api/students/${student.studentId}`, {
                    method: "DELETE"
                });
                await loadStudentProfiles();
                window.alert("学生信息删除成功");
            } catch (error) {
                window.alert(error.message || "删除失败");
            }
        }

        async function searchLogs() {
            logQuery.page = 1;
            await loadLogs();
        }

        async function resetLogSearch() {
            logQuery.userName = "";
            logQuery.page = 1;
            await loadLogs();
        }

        async function changeLogPage(page) {
            if (page < 1 || page > (logPage.value.totalPages || 1)) {
                return;
            }
            logQuery.page = page;
            await loadLogs();
        }

        async function searchAccessLogs() {
            accessLogQuery.page = 1;
            await loadAccessLogs();
        }

        async function resetAccessLogSearch() {
            accessLogQuery.userName = "";
            accessLogQuery.roleCode = "";
            accessLogQuery.operationType = "";
            accessLogQuery.page = 1;
            await loadAccessLogs();
        }

        async function changeAccessLogPage(page) {
            if (page < 1 || page > (accessLogPage.value.totalPages || 1)) {
                return;
            }
            accessLogQuery.page = page;
            await loadAccessLogs();
        }

        async function searchRuleChangeLogs() {
            ruleChangeLogQuery.page = 1;
            await loadRuleChangeLogs();
        }

        async function resetRuleChangeLogSearch() {
            ruleChangeLogQuery.operatorName = "";
            ruleChangeLogQuery.page = 1;
            await loadRuleChangeLogs();
        }

        async function changeRuleChangeLogPage(page) {
            if (page < 1 || page > (ruleChangeLogPage.value.totalPages || 1)) {
                return;
            }
            ruleChangeLogQuery.page = page;
            await loadRuleChangeLogs();
        }

        async function logout() {
            try {
                await authorizedFetch("/api/user/logout", {
                    method: "POST"
                });
            } finally {
                redirectToLogin();
            }
        }

        onMounted(async () => {
            try {
                await loadCurrentUser();
                if (activeMenu.value) {
                    await loadSectionData(activeMenu.value);
                }
            } catch (error) {
                handleUnauthorized();
            }
        });

        onBeforeUnmount(() => {
        });

        return {
            pageIcons,
            currentUser,
            isCollapsed,
            activeMenu,
            currentSection,
            currentRoleText,
            resolvedRoleCode,
            isStudentUser,
            isStudentScopeLocked,
            studentAvatarText,
            maskingHintText,
            flatMenus,
            visibleMenus,
            flattenedPermissionTree,
            parentPermissionOptions,
            homeStats,
            homeRecentLogs,
            userLoading,
            userError,
            userPage,
            userQuery,
            showUserModal,
            userForm,
            userFormError,
            userSubmitting,
            roleLoading,
            roleError,
            roleList,
            roleOptions,
            roleQuery,
            showRoleModal,
            roleForm,
            roleFormError,
            roleSubmitting,
            permissionLoading,
            permissionError,
            showPermissionModal,
            permissionForm,
            permissionFormError,
            permissionSubmitting,
            profileSubmitting,
            profileFormError,
            showProfileModal,
            profileForm,
            passwordSubmitting,
            passwordFormError,
            showPasswordModal,
            passwordForm,
            logLoading,
            logError,
            logPage,
            logQuery,
            accessLogLoading,
            accessLogError,
            accessLogPage,
            accessLogQuery,
            ruleChangeLogLoading,
            ruleChangeLogError,
            ruleChangeLogPage,
            ruleChangeLogQuery,
            abnormalAccessLoading,
            abnormalAccessError,
            abnormalAccessPage,
            abnormalAccessQuery,
            studentProfileLoading,
            studentProfileError,
            studentProfiles,
            selectedStudentProfile,
            showStudentDetailModal,
            showStudentEditModal,
            studentEditSubmitting,
            studentEditFormError,
            studentProfileQuery,
            studentEditForm,
            studentScoreLoading,
            studentScoreError,
            studentScores,
            studentScoreQuery,
            gradeAnalyticsLoading,
            gradeAnalyticsError,
            gradeAnalytics,
            sensitiveAnalyticsLoading,
            sensitiveAnalyticsError,
            sensitiveAnalytics,
            maskingRuleLoading,
            maskingRuleError,
            maskingRulePage,
            maskingRuleRoleOptions,
            maskingRuleFieldOptions,
            maskingRuleQuery,
            showMaskingRuleModal,
            maskingRuleSubmitting,
            maskingRuleFormError,
            maskingRuleForm,
            selectedMaskingRulePolicy,
            dataEntryOptionsLoading,
            dataEntryOptions,
            showDataEntryModal,
            dataEntrySubmitting,
            dataEntryFormError,
            dataEntryMode,
            dataEntryForm,
            currentDataEntryMeta,
            showDataImportModal,
            dataImportSubmitting,
            dataImportError,
            dataImportMode,
            dataImportFileName,
            dataImportInputKey,
            dataImportResult,
            currentDataImportMeta,
            can,
            isMenuExpanded,
            resolveMenuIcon,
            formatDateTime,
            formatGender,
            formatRoleNames,
            formatStudentStatus,
            formatAnalyticsNumber,
            formatAnalyticsPercent,
            rankingBarStyle,
            distributionPercent,
            distributionBarStyle,
            countBarStyle,
            coverageBarStyle,
            formatPermissionOption,
            toggleSidebar,
            activateMenu,
            openProfileSection,
            handlePrimaryAction,
            searchUsers,
            resetUserSearch,
            changeUserPage,
            searchStudentProfiles,
            refreshStudentProfiles,
            resetStudentProfileSearch,
            searchStudentScores,
            loadStudentScores,
            resetStudentScoreSearch,
            searchMaskingRules,
            resetMaskingRuleSearch,
            changeMaskingRulePage,
            openMaskingRuleModal,
            closeMaskingRuleModal,
            submitMaskingRuleForm,
            openCreateUserModal,
            openEditUserModal,
            closeUserModal,
            submitUserForm,
            deleteUser,
            openDataEntryModal,
            closeDataEntryModal,
            submitDataEntryForm,
            openDataImportModal,
            closeDataImportModal,
            handleDataImportFileChange,
            submitDataImport,
            loadRoles,
            resetRoleSearch,
            openCreateRoleModal,
            openEditRoleModal,
            closeRoleModal,
            selectAllPermissions,
            clearAllPermissions,
            submitRoleForm,
            deleteRole,
            loadPermissions,
            openCreatePermissionModal,
            openEditPermissionModal,
            closePermissionModal,
            submitPermissionForm,
            deletePermission,
            openProfileModal,
            closeProfileModal,
            submitProfileForm,
            openPasswordModal,
            closePasswordModal,
            submitPasswordForm,
            openStudentDetailModal,
            closeStudentDetailModal,
            openStudentEditModal,
            closeStudentEditModal,
            submitStudentEditForm,
            deleteStudent,
            searchLogs,
            resetLogSearch,
            changeLogPage,
            searchAccessLogs,
            resetAccessLogSearch,
            changeAccessLogPage,
            searchRuleChangeLogs,
            resetRuleChangeLogSearch,
            changeRuleChangeLogPage,
            searchAbnormalAccess,
            resetAbnormalAccessSearch,
            changeAbnormalAccessPage,
            runAbnormalAccessDetection,
            logout
        };
    }
}).mount("#app");
