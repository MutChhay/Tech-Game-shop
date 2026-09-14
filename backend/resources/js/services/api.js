const api = window.axios;

api.defaults.baseURL = '/api';

api.interceptors.request.use((config) => {
    const token = localStorage.getItem('store_token');
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
});

api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response && error.response.status === 401) {
            localStorage.removeItem('store_token');
            localStorage.removeItem('store_user');
            window.dispatchEvent(new CustomEvent('store:unauthorized'));
        }
        return Promise.reject(error);
    },
);

export default api;