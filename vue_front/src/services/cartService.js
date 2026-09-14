import api from './api.js'

export const cartService = {
    // Get logged-in user's cart
    getCart() {
        return api.get('/cart')
    },

    // Add product to cart
    addToCart(productId, quantity) {
        return api.post('/cart', {
            product_id: productId,
            quantity,
        })
    },

    // Update cart quantity
    updateCart(cartId, quantity) {
        return api.put(`/cart/${cartId}`, {
            quantity,
        })
    },

    // Remove cart item
    removeFromCart(cartId) {
        return api.delete(`/cart/${cartId}`)
    },
}