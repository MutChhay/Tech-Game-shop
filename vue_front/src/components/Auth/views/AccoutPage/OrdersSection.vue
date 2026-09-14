<script setup>
const orders = [
  { id: 'ORD-1024', date: 'Sep 05, 2026', items: 2, total: '85.00', status: 'Delivered' },
  { id: 'ORD-1023', date: 'Sep 02, 2026', items: 1, total: '120.00', status: 'Processing' },
  { id: 'ORD-1022', date: 'Aug 28, 2026', items: 3, total: '40.00', status: 'Pending' },
]
</script>

<template>
  <section class="rounded-2xl border border-gray-200 bg-white p-6">
    <div class="mb-6">
      <h2 class="text-lg font-semibold text-gray-900">My Orders</h2>
      <p class="text-sm text-gray-500">View your recent purchases.</p>
    </div>
    <div class="space-y-4">
      <div v-for="order in orders" :key="order.id" class="flex flex-col gap-4 rounded-xl border border-gray-200 p-5 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <p class="font-semibold text-gray-900">Order #{{ order.id }}</p>
          <p class="mt-1 text-sm text-gray-500">{{ order.date }} · {{ order.items }} items</p>
        </div>
        <div class="flex items-center gap-4">
          <span class="rounded-full px-3 py-1 text-xs font-medium" :class="{ 'bg-green-50 text-green-700': order.status === 'Delivered', 'bg-yellow-50 text-yellow-700': order.status === 'Processing', 'bg-gray-100 text-gray-600': order.status === 'Pending' }">{{ order.status }}</span>
          <span class="font-semibold text-gray-900">${{ order.total }}</span>
          <button class="text-sm font-medium text-gray-900 underline">View</button>
        </div>
      </div>
    </div>
  </section>
</template>
