import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { cartService } from '../services/cartService.js'

export const useCartStore = defineStore('cart', () => {
    const items = ref([])
    const isLoading = ref(false)

    // ==========================================
    // LOAD CART FROM DATABASE
    // ==========================================

    async function fetchCart() {
        const token = localStorage.getItem('token')

        if (!token) {
            items.value = []
            return
        }

        isLoading.value = true

        try {
            const response = await cartService.getCart()

            const cartItems = Array.isArray(response.data) ?
                response.data :
                response.data.data || []

            items.value = cartItems.map(item => ({
                id: item.product.id,
                cartId: item.id,

                name: item.product.name,
                price: Number(item.product.price),

                image: item.product.image_url || item.product.image,

                quantity: Number(item.quantity),
                stock: Number(item.product.stock),

                category_name: item.product.category_name || '',
            }))
        } catch (error) {
            console.error('Failed to load cart:', error)
        } finally {
            isLoading.value = false
        }
    }

    // ==========================================
    // ADD PRODUCT
    // ==========================================

    async function addToCart(product, quantity = 1) {
        const existingItem = items.value.find(
            item => item.id === product.id
        )

        let newQuantity = Number(quantity)

        if (existingItem) {
            newQuantity =
                existingItem.quantity + Number(quantity)

            if (newQuantity > Number(product.stock)) {
                newQuantity = Number(product.stock)
            }

            existingItem.quantity = newQuantity
        } else {
            newQuantity = Math.min(
                Number(quantity),
                Number(product.stock)
            )

            items.value.push({
                id: product.id,
                cartId: null,

                name: product.name,
                price: Number(product.price),

                image: product.image_url ||
                    product.image,

                quantity: newQuantity,
                stock: Number(product.stock),

                category_name: product.category_name || '',
            })
        }

        // Save to Laravel
        try {
            const response = await cartService.addToCart(
                product.id,
                newQuantity
            )

            const savedItem = response.data.data || response.data

            const item = items.value.find(
                item => item.id === product.id
            )

            if (item) {
                item.cartId = savedItem.id
            }
        } catch (error) {
            console.error('Failed to save cart:', error)

            // Restore cart from database
            await fetchCart()

            throw error
        }
    }

    // ==========================================
    // REMOVE PRODUCT
    // ==========================================

    async function removeFromCart(productId) {
        const item = items.value.find(
            item => item.id === productId
        )

        if (!item) return

        if (item.cartId) {
            try {
                await cartService.removeFromCart(
                    item.cartId
                )
            } catch (error) {
                console.error(
                    'Failed to remove cart item:',
                    error
                )

                return
            }
        }

        items.value = items.value.filter(
            item => item.id !== productId
        )
    }

    async function removeItemsFromCart(productIds) {
        const ids = new Set(productIds.map(id => String(id)))
        const removedItems = items.value.filter(item =>
            ids.has(String(item.id))
        )

        // Update Pinia immediately so the badge and cart page react without a refresh.
        items.value = items.value.filter(item =>
            !ids.has(String(item.id))
        )

        const results = await Promise.allSettled(
            removedItems
            .filter(item => item.cartId)
            .map(item => cartService.removeFromCart(item.cartId))
        )

        if (results.some(result => result.status === 'rejected')) {
            await fetchCart()
        }
    }

    // ==========================================
    // INCREASE
    // ==========================================

    async function increaseQuantity(productId) {
        const item = items.value.find(
            item => item.id === productId
        )

        if (!item) return

        if (item.quantity >= item.stock) return

        item.quantity++

            await updateQuantity(item)
    }

    // ==========================================
    // DECREASE
    // ==========================================

    async function decreaseQuantity(productId) {
        const item = items.value.find(
            item => item.id === productId
        )

        if (!item) return

        if (item.quantity <= 1) return

        item.quantity--

            await updateQuantity(item)
    }

    // ==========================================
    // UPDATE QUANTITY
    // ==========================================

    async function updateQuantity(item) {
        if (!item.cartId) return

        try {
            await cartService.updateCart(
                item.cartId,
                item.quantity
            )
        } catch (error) {
            console.error(
                'Failed to update quantity:',
                error
            )

            await fetchCart()
        }
    }

    // ==========================================
    // CLEAR CART
    // ==========================================

    async function clearCart() {
        const currentItems = [...items.value]

        try {
            await Promise.all(
                currentItems
                .filter(item => item.cartId)
                .map(item => cartService.removeFromCart(item.cartId))
            )
        } catch (error) {
            console.error('Failed to clear cart:', error)
            await fetchCart()
            return
        }

        items.value = []
    }

    // ==========================================
    // TOTAL ITEMS
    // ==========================================

    const totalItems = computed(() => {
        return items.value.reduce(
            (total, item) =>
            total + Number(item.quantity),
            0
        )
    })

    // ==========================================
    // SUBTOTAL
    // ==========================================

    const subtotal = computed(() => {
        return items.value.reduce(
            (total, item) =>
            total +
            Number(item.price) *
            Number(item.quantity),
            0
        )
    })

    // ==========================================
    // TOTAL
    // ==========================================

    const total = computed(() => {
        return subtotal.value
    })

    return {
        items,
        isLoading,

        totalItems,
        subtotal,
        total,

        fetchCart,
        addToCart,
        removeFromCart,
        removeItemsFromCart,
        increaseQuantity,
        decreaseQuantity,
        clearCart,
    }
})