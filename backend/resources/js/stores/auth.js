import { defineStore } from 'pinia';
import { authService } from '../services/authService';

export const useAuthStore = defineStore('auth', {
    state: () => ({
        token: localStorage.getItem('store_token'),
        user: JSON.parse(localStorage.getItem('store_user') || 'null'),
        loading: false,
    }),
    getters: {
        isAuthenticated: (state) => Boolean(state.token),
        isAdmin: (state) => state.user && state.user.role === 'admin',
    },
    actions: {
        persist(token, user) {
            this.token = token;
            this.user = user;
            localStorage.setItem('store_token', token);
            localStorage.setItem('store_user', JSON.stringify(user));
        },
        async login(payload) {
            this.loading = true;
            try {
                const { data } = await authService.login(payload);
                this.persist(data.token, data.user || null);
                await this.hydrate();
            } finally { this.loading = false; }
        },
        async register(payload) {
            this.loading = true;
            try {
                const { data } = await authService.register(payload);
                this.persist(data.token, data.user);
            } finally { this.loading = false; }
        },
        async hydrate() {
            if (!this.token) return;
            try {
                const { data } = await authService.me();
                this.user = data;
                localStorage.setItem('store_user', JSON.stringify(data));
            } catch { this.clear(); }
        },
        async logout() {
            try { if (this.token) await authService.logout(); } finally { this.clear(); }
        },
        clear() {
            this.token = null;
            this.user = null;
            localStorage.removeItem('store_token');
            localStorage.removeItem('store_user');
        },
    },
});