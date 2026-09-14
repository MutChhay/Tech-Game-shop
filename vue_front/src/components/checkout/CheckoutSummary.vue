<script setup>
defineProps({
    items: {
        type: Array,
        required: true,
    },
    subtotal: {
        type: Number,
        required: true,
    },
    isLoading: {
        type: Boolean,
        default: false,
    },
    error: {
        type: String,
        default: '',
    },
})

defineEmits(['submit'])

function formatPrice(price) {
    return Number(price).toFixed(2)
}
</script>

<template>
  <aside class="h-fit rounded-xl border border-gray-200 bg-white p-6 shadow-sm lg:sticky lg:top-24">
    <h2 class="text-lg font-bold">Order summary</h2>
    <div class="mt-5 flex items-center justify-between border-b border-gray-100 pb-5 text-sm">
      <span class="text-gray-500">{{ items.length }} product(s)</span>
      <span class="font-semibold">${{ formatPrice(subtotal) }}</span>
    </div>
    <div class="mt-5 flex items-center justify-between text-lg font-bold">
      <span>Total</span>
      <span>${{ formatPrice(subtotal) }}</span>
    </div>
    <p v-if="error" class="mt-4 rounded-lg bg-red-50 p-3 text-sm text-red-600">{{ error }}</p>
    <button type="submit" :disabled="isLoading" class="mt-6 flex w-full items-center justify-center gap-2 rounded-full bg-orange-500 py-3.5 text-sm font-bold text-white transition hover:bg-orange-600 disabled:cursor-not-allowed disabled:opacity-60">
      <span v-if="isLoading" class="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent"></span>
      {{ isLoading ? 'Placing order...' : 'Place order' }}
    </button>
  </aside>
</template>
