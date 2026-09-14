import { defineStore } from 'pinia'
import api from '../services/api'

export const useProductStore = defineStore('product', {
    state: () => ({
        products: [],
        loading: false,
        error: null,
    }),

    actions: {
        async fetchProducts() {
            this.loading = true
            this.error = null

            try {
                const response = await api.get('/products')

                console.log('Products:', response.data)

                // Store ALL products
                this.products = response.data

            } catch (error) {
                console.error('Failed to load products:', error)

                this.error = 'Failed to load products'
            } finally {
                this.loading = false
            }
        },
    },
})