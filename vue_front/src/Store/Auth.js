import { defineStore } from 'pinia'
import api from '../services/api'

export const useAuthStore = defineStore('auth', {
    state: () => ({
        token: localStorage.getItem('token') || null,

        user: JSON.parse(
            localStorage.getItem('user') || 'null'
        ),
    }),

    getters: {
        isLoggedIn: (state) => !!state.token,
    },

    actions: {

        async fetchUser() {
            const response = await api.get('/me')
            const user = response.data && (response.data.user || response.data.data) || response.data
            this.user = user
            localStorage.setItem('user', JSON.stringify(user))
            return user
        },

        async updateUser(payload) {
            const response = await api.put('/updateUser', payload)
            const user = response.data && (response.data.user || response.data.data) || response.data
            this.user = user
            localStorage.setItem('user', JSON.stringify(user))
            return user
        },

        // Login
        login(token, user) {
            this.token = token
            this.user = user

            localStorage.setItem('token', token)
            localStorage.setItem('user', JSON.stringify(user))
        },

        // Logout
        logout() {
            this.token = null
            this.user = null

            localStorage.removeItem('token')
            localStorage.removeItem('user')
        },

    },
})