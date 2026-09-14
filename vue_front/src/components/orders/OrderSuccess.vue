<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import OrderTracking from '../../components/orders/OrderTracking.vue'
import { getOrderTotal, useOrderStore } from '../../Store/orders.js'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const orderStore = useOrderStore()
const order = computed(() => orderStore.lastOrder)

function valueOf(keys, fallback = '') {
    for (const key of keys) {
        if (order.value?.[key] !== undefined && order.value[key] !== null && order.value[key] !== '') return order.value[key]
    }
    return fallback
}

const orderId = computed(() => valueOf(['order_number', 'orderNumber', 'id'], route.params.id))
const status = computed(() => valueOf(['status'], 'pending'))
const items = computed(() => {
    const value = valueOf(['items', 'order_items', 'orderItems'], [])
    return Array.isArray(value) ? value : []
})
const subtotal = computed(() => getOrderTotal(order.value))

function itemSubtotal(item) {
    const subtotal = itemValue(item, ['subtotal', 'line_total', 'total'])
    if (subtotal !== '') return Number(subtotal).toFixed(2)
    return (Number(itemValue(item, ['price', 'unit_price', 'unitPrice'], 0)) * Number(itemValue(item, ['quantity'], 0))).toFixed(2)
}

</script>

<template>
  <main class="min-h-screen bg-gray-50 px-4 py-10 text-gray-900 sm:px-6 lg:px-8">
    <div class="mx-auto max-w-3xl">
      <section class="order-success rounded-2xl border border-emerald-100 bg-white px-6 py-12 text-center shadow-sm sm:px-10">
        <div class="success-mark mx-auto flex h-20 w-20 items-center justify-center rounded-full bg-emerald-100 text-4xl text-emerald-600">✓</div>
        <p class="mt-6 text-xs font-semibold uppercase tracking-[0.18em] text-emerald-600">Order confirmed</p>
        <h1 class="mt-2 text-3xl font-bold">{{ t('Order.Thanks') }}</h1>
        <p class="mt-3 text-sm text-gray-500">{{ t('Order.OrderSU') }}</p>
        <p class="mt-5 text-lg font-bold">{{t('account.orders')}} #{{ orderId }}</p>
        <p class="mt-2 text-2xl font-bold">${{ subtotal }}</p>
      </section>

      <div class="mt-6"><OrderTracking :status="status" /></div>

      <section v-if="items.length" class="mt-6 rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <h2 class="text-lg font-bold">{{ t('PurchasedP') }}</h2>
        <div class="mt-4 space-y-3 text-sm">
          <div v-for="(item, index) in items" :key="item.id || index" class="flex justify-between gap-4 border-b border-gray-100 pb-3 last:border-0 last:pb-0">
            <span>{{ item.name || item.product_name || 'Product' }} × {{ item.quantity || 0 }}</span>
            <span class="font-semibold">${{ Number(item.subtotal || item.total || (item.price || 0) * (item.quantity || 0)).toFixed(2) }}</span>
          </div>
        </div>
      </section>

      <div class="mt-8 flex flex-wrap justify-center gap-3">
        <button type="button" class="rounded-full bg-gray-900 px-6 py-3 text-sm font-semibold text-white transition hover:bg-gray-800" @click="router.push(`/orders/${orderId}`)">{{ t('Order.ViewOD') }}</button>
        <button type="button" class="rounded-full border border-gray-300 bg-white px-6 py-3 text-sm font-semibold text-gray-700 transition hover:bg-gray-50" @click="router.push('/products')">{{ t('Purchase.conti') }}</button>
      </div>
    </div>
  </main>
</template>

<style scoped>
.order-success { animation: slide-up 420ms ease-out both; }
.success-mark { animation: success-pop 420ms 100ms ease-out both; }

@keyframes slide-up { from { opacity: 0; transform: translateY(14px); } to { opacity: 1; transform: translateY(0); } }
@keyframes success-pop { from { opacity: 0; transform: scale(0.65); } 75% { transform: scale(1.08); } to { opacity: 1; transform: scale(1); } }
</style>
