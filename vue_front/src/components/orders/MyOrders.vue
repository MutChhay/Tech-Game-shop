<script setup>
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getOrderTotal, useOrderStore } from '../../Store/orders.js'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const router = useRouter()
const orderStore = useOrderStore()

function valueOf(order, keys, fallback = '') {
  for (const key of keys) {
    if (order?.[key] !== undefined && order[key] !== null && order[key] !== '') return order[key]
  }
  return fallback
}

function orderId(order) {
  return valueOf(order, ['order_number', 'orderNumber', 'id'])
}

function formatDate(order) {
  const value = valueOf(order, ['created_at', 'createdAt', 'date'])
  if (!value) return 'Date unavailable'
  const date = new Date(value)
  return Number.isNaN(date.getTime()) ? String(value) : date.toLocaleDateString()
}

function formatTotal(order) {
  return getOrderTotal(order).toFixed(2)
}

function statusLabel(order) {
  const status = valueOf(order, ['status'], 'Processing')
  return String(status).replace(/[_-]+/g, ' ')
}

function statusClass(order) {
  const status = String(valueOf(order, ['status'], '')).toLowerCase()

  if (['delivered', 'completed'].includes(status)) {
    return 'bg-emerald-50 text-emerald-700 ring-emerald-600/20'
  }

  if (['cancelled', 'canceled', 'failed'].includes(status)) {
    return 'bg-red-50 text-red-700 ring-red-600/20'
  }

  if (['shipped', 'packed'].includes(status)) {
    return 'bg-blue-50 text-blue-700 ring-blue-600/20'
  }

  return 'bg-amber-50 text-amber-700 ring-amber-600/20'
}

function itemCount(order) {
  const items = valueOf(order, ['items', 'order_items', 'orderItems'], [])
  if (!Array.isArray(items)) return 0
  return items.reduce((total, item) => total + Number(item.quantity || 1), 0)
}

onMounted(() => orderStore.fetchOrders().catch(() => {}))
</script>

<template>
  <main class="min-h-screen bg-gray-50 px-4 py-8 text-gray-900 sm:px-6 lg:px-8 lg:py-12">
    <div class="mx-auto max-w-6xl">
      <!-- Header -->
      <header class="flex flex-col justify-between gap-6 border-b border-gray-200 pb-8 sm:flex-row sm:items-end">
        <div>
          <p class="text-xs font-bold uppercase tracking-[0.22em] text-blue-600">{{t('nav.account')}}</p>
          <h1 class="mt-2 text-3xl font-bold tracking-tight text-gray-950 sm:text-4xl">{{t('Order.myorder')}}</h1>
          <p class="mt-2 max-w-md text-sm leading-6 text-gray-500">{{t('Order.tracktitle')}}</p>
        </div>

        <div class="flex items-center gap-3 rounded-xl border border-gray-200 bg-white px-4 py-3 shadow-sm">
          <span class="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-50 text-blue-700">
            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" d="M6 3.75h12A1.25 1.25 0 0 1 19.25 5v14A1.25 1.25 0 0 1 18 20.25H6A1.25 1.25 0 0 1 4.75 19V5A1.25 1.25 0 0 1 6 3.75Z" />
              <path stroke-linecap="round" d="M8 8h8M8 12h8M8 16h5" />
            </svg>
          </span>
          <div>
            <p class="text-2xl font-bold leading-none text-gray-950">{{ orderStore.orders.length }}</p>
            <p class="mt-1 text-xs font-medium text-gray-500">{{ t('Order.ordersP') }}</p>
          </div>
        </div>
      </header>

      <!-- Loading -->
      <div v-if="orderStore.isLoading" class="flex items-center justify-center py-16">
        <span class="h-7 w-7 animate-spin rounded-full border-2 border-gray-300 border-t-gray-900"></span>
      </div>

      <!-- Error -->
      <div v-else-if="orderStore.error" class="mt-8 rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-sm text-red-700">
        <p class="font-semibold">{{ t('Order.Noproductsfound') }}</p>
        <p class="mt-1">{{ orderStore.error }}</p>
      </div>

      <!-- Empty -->
      <div v-else-if="!orderStore.orders.length" class="mt-8 overflow-hidden rounded-2xl border border-gray-200 bg-white px-6 py-14 text-center shadow-sm sm:px-10">
        <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl bg-gray-100 text-gray-500">
          <svg class="h-8 w-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 8.25h10.5l1.5 11h-13.5l1.5-11Z" />
            <path stroke-linecap="round" d="M9 9V6a3 3 0 0 1 6 0v3" />
          </svg>
        </div>
        <h2 class="mt-5 text-xl font-bold text-gray-950">{{ t('Order.history') }}</h2>
        <p class="mx-auto mt-2 max-w-sm text-sm leading-6 text-gray-500">{{ t('Order.tittle') }}</p>
        <button type="button" class="mt-6 inline-flex items-center gap-2 rounded-lg bg-gray-950 px-5 py-3 text-sm font-semibold text-white transition hover:bg-blue-700" @click="router.push('/products')">
          {{t('Order.shopping')}}
          <span aria-hidden="true">→</span>
        </button>
      </div>

      <!-- Orders list -->
      <div v-else class="mt-8 space-y-4">
        <article
          v-for="order in orderStore.orders"
          :key="orderId(order)"
          class="group overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm transition duration-200 hover:-translate-y-0.5 hover:border-blue-200 hover:shadow-md"
        >
          <div class="flex flex-col gap-5 p-5 sm:p-6 lg:flex-row lg:items-center lg:justify-between">
            <div class="flex min-w-0 items-start gap-4">
              <div class="hidden h-12 w-1 shrink-0 rounded-full bg-blue-600 sm:block"></div>
              <div class="min-w-0">
                <div class="flex flex-wrap items-center gap-3">
                  <p class="text-xs font-bold uppercase tracking-[0.16em] text-gray-400">{{t('account.orders')}}</p>
                  <p class="truncate text-base font-bold text-gray-950">#{{ orderId(order) }}</p>
                  <span class="rounded-full px-3 py-1 text-xs font-bold capitalize ring-1 ring-inset" :class="statusClass(order)">
                    {{ statusLabel(order) }}
                  </span>
                </div>
                <div class="mt-3 flex flex-wrap gap-x-5 gap-y-1 text-sm text-gray-500">
                  <span>{{t('Order.Placed')}} {{ formatDate(order) }}</span>
                  <span>{{ itemCount(order) }} {{ itemCount(order) === 1 ? 'item' : 'items' }}</span>
                </div>
              </div>
            </div>

            <div class="flex items-center justify-between gap-5 border-t border-gray-100 pt-4 sm:justify-end sm:border-t-0 sm:pt-0">
              <div class="sm:text-right">
                <p class="text-xs font-medium uppercase tracking-wider text-gray-400">{{ t('nav.Total') }}</p>
                <p class="mt-1 text-xl font-bold text-gray-950">${{ formatTotal(order) }}</p>
              </div>
              <button
                type="button"
                class="inline-flex items-center gap-2 rounded-lg border border-gray-200 px-4 py-2.5 text-sm font-semibold text-gray-700 transition hover:border-gray-950 hover:bg-gray-950 hover:text-white"
                @click="router.push(`/orders/${orderId(order)}`)"
              >
                {{ t('Order.View') }}
                <span class="transition-transform group-hover:translate-x-0.5" aria-hidden="true">→</span>
              </button>
            </div>
          </div>
        </article>
      </div>
    </div>
  </main>
</template>