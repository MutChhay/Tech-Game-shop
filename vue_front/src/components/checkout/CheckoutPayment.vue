<script setup>
defineProps({
    modelValue: {
        type: String,
        required: true,
    },
})

const emit = defineEmits(['update:modelValue'])
</script>

<template>
  <section class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
    <h2 class="text-lg font-bold">Payment</h2>
    <label class="mt-4 flex cursor-pointer items-center gap-3 rounded-lg border border-gray-200 p-4 text-sm transition hover:border-gray-400">
      <input :checked="modelValue === 'cash_on_delivery'" type="radio" value="cash_on_delivery" @change="emit('update:modelValue', 'cash_on_delivery')" />
      Cash on delivery
    </label>
    <label class="mt-3 flex cursor-pointer items-center gap-3 rounded-lg border border-gray-200 p-4 text-sm transition hover:border-gray-400">
      <input :checked="modelValue === 'card'" type="radio" value="card" @change="emit('update:modelValue', 'card')" />
      Card payment
    </label>
  </section>
</template>
