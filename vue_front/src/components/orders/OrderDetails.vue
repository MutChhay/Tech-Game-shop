<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import OrderTracking from '../../components/orders/OrderTracking.vue'
import { getOrderTotal, useOrderStore } from '../../Store/orders.js'

import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const route = useRoute()
const router = useRouter()
const orderStore = useOrderStore()
const isCancelling = ref(false)
const cancellationMessage = ref('')

const order = computed(() => orderStore.currentOrder)

function valueOf(source, keys, fallback = '') {
    for (const key of keys) {
        if (source?.[key] !== undefined && source[key] !== null && source[key] !== '') return source[key]
    }
    return fallback
}

const orderId = computed(() => valueOf(order.value, ['order_number', 'orderNumber', 'id'], route.params.id))
const status = computed(() => valueOf(order.value, ['status'], ''))
const canRequestCancellation = computed(() => ['pending', 'processing'].includes(String(status.value).toLowerCase()))
const items = computed(() => {
    const value = valueOf(order.value, ['items', 'order_items', 'orderItems'], [])
    return Array.isArray(value) ? value : []
})
const total = computed(() => getOrderTotal(order.value))
const delivery = computed(() => valueOf(order.value, ['shipping_address', 'delivery_address', 'address'], ''))
const payment = computed(() => valueOf(order.value, ['payment_method', 'paymentMethod'], ''))
const date = computed(() => {
    const value = valueOf(order.value, ['created_at', 'createdAt', 'date'])
    if (!value) return 'Date unavailable'
    const parsed = new Date(value)
    return Number.isNaN(parsed.getTime()) ? String(value) : parsed.toLocaleString()
})

function itemValue(item, keys, fallback = '') {
    return valueOf(item, keys, fallback)
}

function itemPrice(item) {
    return Number(itemValue(item, ['price', 'unit_price', 'unitPrice'], 0)).toFixed(2)
}

function itemSubtotal(item) {
    const subtotal = itemValue(item, ['subtotal', 'line_total', 'total'])
    if (subtotal !== '') return Number(subtotal).toFixed(2)
    return (Number(itemValue(item, ['price', 'unit_price', 'unitPrice'], 0)) * Number(itemValue(item, ['quantity'], 0))).toFixed(2)
}

function itemImage(item) {
  const product = item?.product || {}
  const image = itemValue(item, ['image_url', 'image', 'product_image'], '') ||
    valueOf(product, ['image_url', 'image', 'product_image'], '')

  if (!image) return ''
  if (/^https?:\/\//i.test(image)) return image
  if (image.startsWith('/')) return `http://localhost:8000${image}`
  return `http://localhost:8000/storage/${image}`
}

async function requestCancellation() {
  isCancelling.value = true
  cancellationMessage.value = ''

  try {
    await orderStore.requestCancellation(route.params.id)
    cancellationMessage.value = 'Cancellation request sent to the admin.'
  } catch (requestError) {
    cancellationMessage.value = requestError.response?.data?.message || 'Unable to request cancellation.'
  } finally {
    isCancelling.value = false
  }
}

onMounted(() => orderStore.fetchOrder(route.params.id).catch(() => {}))
</script>

<template>
  <main class="min-h-screen bg-gray-50 px-4 py-8 text-gray-900 sm:px-6 lg:px-8">
    <div class="mx-auto max-w-5xl">
      <button type="button" class="mb-6 text-sm font-semibold text-gray-600 hover:text-gray-900" @click="router.push('/orders')">←{{ t('Order.myorder') }}</button>
      <div v-if="orderStore.isLoading" class="flex items-center justify-center py-24"><span class="h-8 w-8 animate-spin rounded-full border-2 border-gray-300 border-t-gray-900"></span></div>
      <div v-else-if="orderStore.error" class="rounded-xl border border-red-100 bg-red-50 p-5 text-sm text-red-700">{{ orderStore.error }}</div>
      <template v-else-if="order">
        <div class="flex flex-wrap items-end justify-between gap-4">
          <div><p class="text-xs font-semibold uppercase tracking-wider text-gray-500">{{ t('Order.orderdetails') }}</p><h1 class="mt-1 text-3xl font-bold">#{{ orderId }}</h1><p class="mt-2 text-sm text-gray-500">{{ date }}</p></div>
          <!-- <p class="text-lg font-bold capitalize">{{ status || 'Status unavailable' }}</p> -->
        </div>

        <div class="mt-8"><OrderTracking :status="status" /></div>

        <div class="mt-6 grid gap-6 lg:grid-cols-[1fr_320px]">
          <section class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
            <h2 class="text-lg font-bold">{{t('nav.products')}}</h2>
            <div v-if="!items.length" class="mt-5 text-sm text-gray-500">{{ t('Products.NoAPIProducts') }}</div>
            <div v-else class="mt-5 divide-y divide-gray-100">
              <div v-for="(item, index) in items" :key="item.id || index" class="flex gap-4 py-4 first:pt-0 last:pb-0">
                <div class="h-16 w-16 shrink-0 overflow-hidden rounded-lg bg-gray-50"><img v-if="itemImage(item)" :src="itemImage(item)" :alt="itemValue(item.product || item, ['name', 'product_name'], 'Product')" class="h-full w-full object-contain p-1" /><span v-else class="flex h-full items-center justify-center text-xs text-gray-400">No image</span></div>
                <div class="min-w-0 flex-1"><p class="font-semibold">{{ itemValue(item, ['name', 'product_name'], itemValue(item.product || {}, ['name'], 'Product')) }}</p><p class="mt-1 text-sm text-gray-500">Qty: {{ itemValue(item, ['quantity'], 0) }} · ${{ itemPrice(item) }}</p></div>
                <p class="font-semibold">${{ itemSubtotal(item) }}</p>
              </div>
            </div>
          </section>

          <aside class="h-fit rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
            <h2 class="text-lg font-bold">{{t('Order.Summary')}}</h2>
            <dl class="mt-5 space-y-4 text-sm">
              <div><dt class="text-gray-500">{{t('Order.Delivery')}}</dt><dd class="mt-1 font-medium">{{ delivery || 'Not provided' }}</dd></div>
              <div><dt class="text-gray-500">{{t('Order.Payment')}}</dt><dd class="mt-1 font-medium capitalize">{{ payment || 'Not provided' }}</dd></div>
            </dl>
            <div class="mt-6 flex justify-between border-t border-gray-100 pt-5 text-lg font-bold"><span>{{t('nav.Total')}}</span><span>${{ total.toFixed(2) }}</span></div>
            <button v-if="canRequestCancellation" type="button" class="mt-6 w-full rounded-lg border border-red-200 px-4 py-3 text-sm font-semibold text-red-700 transition hover:bg-red-50 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isCancelling" @click="requestCancellation">{{ isCancelling ? 'Sending request...' : t('Order.RequestCancellation') }}</button>
            <p v-if="status === 'cancellation_requested'" class="mt-5 rounded-lg bg-amber-50 px-4 py-3 text-sm text-amber-800">{{ t('Order. ') }}</p>
            <p v-if="cancellationMessage" class="mt-3 text-sm text-gray-600">{{ t('Order.isCancellationRequested') }}</p>
          </aside>
        </div>
      </template>
    </div>
  </main>
</template>
