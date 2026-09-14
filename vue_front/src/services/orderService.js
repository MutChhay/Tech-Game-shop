import api from './api.js'

export const orderService = {
    createOrder(payload) {
        return api.post('/orders', payload)
    },

    getOrders() {
        return api.get('/orders')
    },

    getOrder(orderId) {
        return api.get(`/orders/${orderId}`)
    },

    requestCancellation(orderId) {
        return api.post(`/orders/${orderId}/cancel`)
    },
}