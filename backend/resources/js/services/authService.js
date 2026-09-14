import api from './api';

export const authService = {
    login: (payload) => api.post('/login', payload),
    register: (payload) => api.post('/register', payload),
    me: () => api.get('/me'),
    logout: () => api.post('/logout'),
};