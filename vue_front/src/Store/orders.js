import { defineStore } from 'pinia'
import { ref } from 'vue'
import { orderService } from '../services/orderService.js'

export function getOrderTotal(order) {
    const directKeys = [
        'total_amount',
        'total_price',
        'order_total',
        'totalAmount',
        'totalPrice',
        'grand_total',
        'grandTotal',
        'total',
        'amount',
    ]

    for (const key of directKeys) {
        const value = Number(order && order[key])
        if (Number.isFinite(value) && value > 0) return value
    }

    const items = order && (order.items || order.order_items || order.orderItems)
    if (!Array.isArray(items)) return 0

    return items.reduce((total, item) => {
        const lineTotal = Number(
            item.subtotal || item.line_total || item.total
        )

        if (Number.isFinite(lineTotal) && lineTotal > 0) {
            return total + lineTotal
        }

        const product = item.product || {}
        const price = Number(
            item.price || item.unit_price || item.unitPrice || product.price || 0
        )
        const quantity = Number(item.quantity || 0)

        return total + price * quantity
    }, 0)
}

export const useOrderStore = defineStore('orders', () => {
    const isLoading = ref(false)
    const error = ref('')
    const lastOrder = ref(null)
    const orders = ref([])
    const currentOrder = ref(null)

    async function createOrder(payload) {
        isLoading.value = true
        error.value = ''

        try {
            const response = await orderService.createOrder(payload)
            lastOrder.value = response.data.data || response.data
            return lastOrder.value
        } catch (requestError) {
            error.value =
                requestError.response && requestError.response.data ?
                requestError.response.data.message ||
                'Unable to place your order. Please try again.' :
                'Unable to place your order. Please try again.'
            throw requestError
        } finally {
            isLoading.value = false
        }
    }

    async function fetchOrders() {
        isLoading.value = true
        error.value = ''

        try {
            const response = await orderService.getOrders()
            const data = response.data && response.data.data !== undefined ?
                response.data.data :
                response.data
            orders.value = Array.isArray(data) ?
                data :
                data && Array.isArray(data.orders) ?
                data.orders : []
            return orders.value
        } catch (requestError) {
            error.value =
                requestError.response && requestError.response.data ?
                requestError.response.data.message ||
                'Unable to load your orders.' :
                'Unable to load your orders.'
            throw requestError
        } finally {
            isLoading.value = false
        }
    }

    async function fetchOrder(orderId) {
        isLoading.value = true
        error.value = ''

        try {
            const response = await orderService.getOrder(orderId)
            currentOrder.value = response.data && response.data.data !== undefined ?
                response.data.data :
                response.data
            return currentOrder.value
        } catch (requestError) {
            error.value =
                requestError.response && requestError.response.data ?
                requestError.response.data.message ||
                'Unable to load this order.' :
                'Unable to load this order.'
            throw requestError
        } finally {
            isLoading.value = false
        }
    }

    async function requestCancellation(orderId) {
        isLoading.value = true
        error.value = ''

        try {
            const response = await orderService.requestCancellation(orderId)
            const updatedOrder = response.data.order || response.data.data || response.data
            currentOrder.value = updatedOrder
            const index = orders.value.findIndex(order => order.id === updatedOrder.id)
            if (index !== -1) orders.value[index] = updatedOrder
            return updatedOrder
        } catch (requestError) {
            error.value = requestError.response && requestError.response.data ? requestError.response.data.message || 'Unable to request cancellation.' : 'Unable to request cancellation.'
            throw requestError
        } finally {
            isLoading.value = false
        }
    }

    return {
        isLoading,
        error,
        lastOrder,
        orders,
        currentOrder,
        createOrder,
        fetchOrders,
        fetchOrder,
        requestCancellation,
    }
})