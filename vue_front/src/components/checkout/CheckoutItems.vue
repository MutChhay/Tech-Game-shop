<script setup>
defineProps({
    items: {
        type: Array,
        required: true,
    },
})

function formatPrice(price) {
    return Number(price).toFixed(2)
}
</script>

<template>
  <section class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
    <h2 class="text-lg font-bold">Your items</h2>
    <div class="mt-5 divide-y divide-gray-100">
      <div v-for="item in items" :key="item.id" class="flex items-center gap-4 py-4 first:pt-0 last:pb-0">
        <div class="h-14 w-14 shrink-0 overflow-hidden rounded-lg bg-gray-50">
          <img :src="item.image" :alt="item.name" class="h-full w-full object-contain p-1" />
        </div>
        <div class="min-w-0 flex-1">
          <p class="truncate text-sm font-semibold text-gray-900">{{ item.name }}</p>
          <p class="mt-1 text-xs text-gray-500">Quantity: {{ item.quantity }}</p>
        </div>
        <span class="shrink-0 text-sm font-semibold">${{ formatPrice(item.price * item.quantity) }}</span>
      </div>
    </div>
  </section>
</template>
