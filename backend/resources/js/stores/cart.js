import { defineStore } from 'pinia';
import { cartService } from '../services/cartService';

export const useCartStore = defineStore('cart', {
    state: () => ({ items: [], loading: false, error: null }),
    getters: {
        count: (state) => state.items.reduce((sum, item) => sum + item.quantity, 0),
        subtotal: (state) => state.items.reduce((sum, item) => sum + Number(item.product.price) * item.quantity, 0),
    },
    actions: {
        async fetch() {
            this.loading = true;
            this.error = null;
            try { this.items = (await cartService.list()).data; } catch (error) { this.error = (error.response && error.response.data && error.response.data.message) || 'Unable to load your cart.'; } finally { this.loading = false; }
        },
        async add(product, quantity = 1) {
            await cartService.add(product.id, quantity);
            await this.fetch();
        },
        async setQuantity(item, quantity) {
            const next = Math.max(1, Math.min(Number(quantity), item.product.stock));
            await cartService.update(item.id, next);
            await this.fetch();
        },
        async remove(item) {
            await cartService.remove(item.id);
            this.items = this.items.filter((current) => current.id !== item.id);
        },
        clear() { this.items = []; },
    },
});