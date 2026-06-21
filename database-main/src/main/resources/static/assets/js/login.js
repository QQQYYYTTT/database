const { createApp, onMounted, reactive, ref } = Vue;

const TOKEN_KEY = "platform_token";
const USER_KEY = "platform_user";

const loginIcons = {
    user: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <path d="M20 21C20 17.686 16.418 15 12 15C7.582 15 4 17.686 4 21" />
            <circle cx="12" cy="8" r="4" />
        </svg>
    `,
    lock: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <rect x="5" y="11" width="14" height="10" />
            <path d="M8 11V8.5C8 6.015 9.79 4 12 4C14.21 4 16 6.015 16 8.5V11" />
        </svg>
    `,
    eyeOpen: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <path d="M2 12C4.727 7.636 8.091 5.455 12 5.455C15.909 5.455 19.273 7.636 22 12C19.273 16.364 15.909 18.545 12 18.545C8.091 18.545 4.727 16.364 2 12Z" />
            <circle cx="12" cy="12" r="3" />
        </svg>
    `,
    eyeClose: `
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8">
            <path d="M3 3L21 21" />
            <path d="M10.58 10.58C10.21 10.95 10 11.46 10 12C10 13.1 10.9 14 12 14C12.54 14 13.05 13.79 13.42 13.42" />
            <path d="M9.88 5.09C10.57 4.93 11.28 4.85 12 4.85C15.99 4.85 19.43 7.09 22 11.57C21.1 13.13 20.1 14.43 18.98 15.45" />
            <path d="M6.23 6.23C4.69 7.35 3.28 8.95 2 11.57C4.57 16.05 8.01 18.29 12 18.29C13.67 18.29 15.24 17.9 16.7 17.14" />
        </svg>
    `
};

const clearLoginState = () => {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
};

const fetchCurrentUser = async (token) => {
    const response = await fetch("/api/user/me", {
        headers: {
            Authorization: `Bearer ${token}`
        }
    });
    const text = await response.text();
    const result = text ? JSON.parse(text) : null;
    if (!response.ok || !result || result.code !== 200) {
        return null;
    }
    return result.data;
};

createApp({
    setup() {
        const form = reactive({
            userName: "admin",
            userPwd: "admin"
        });
        const loading = ref(false);
        const errorMessage = ref("");
        const showPassword = ref(false);

        function validateForm() {
            if (!form.userName) {
                errorMessage.value = "请输入用户名";
                return false;
            }
            if (!form.userPwd) {
                errorMessage.value = "请输入密码";
                return false;
            }
            errorMessage.value = "";
            return true;
        }

        function togglePassword() {
            showPassword.value = !showPassword.value;
        }

        async function handleLogin() {
            if (!validateForm()) {
                return;
            }
            loading.value = true;
            errorMessage.value = "";
            try {
                const response = await fetch("/api/user/login", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        userName: form.userName,
                        userPwd: form.userPwd
                    })
                });
                const text = await response.text();
                const result = text ? JSON.parse(text) : null;
                if (!response.ok || !result || result.code !== 200) {
                    errorMessage.value = result?.message || "登录失败，请稍后重试";
                    return;
                }
                localStorage.setItem(TOKEN_KEY, result.data.token);
                localStorage.setItem(USER_KEY, JSON.stringify({
                    userId: result.data.userId,
                    userName: result.data.userName
                }));
                window.location.replace("/index.html");
            } catch (error) {
                errorMessage.value = "网络异常，请稍后重试";
            } finally {
                loading.value = false;
            }
        }

        onMounted(async () => {
            const token = localStorage.getItem(TOKEN_KEY);
            if (!token) {
                return;
            }
            const currentUser = await fetchCurrentUser(token);
            if (!currentUser) {
                clearLoginState();
                return;
            }
            localStorage.setItem(USER_KEY, JSON.stringify(currentUser));
            window.location.replace("/index.html");
        });

        return {
            form,
            loading,
            errorMessage,
            showPassword,
            icons: loginIcons,
            togglePassword,
            handleLogin
        };
    }
}).mount("#app");
