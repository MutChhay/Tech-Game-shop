<script setup>
defineProps({
    modelValue: {
        type: Object,
        required: true,
    },
})

const emit = defineEmits(['update:modelValue'])
</script>

<template>
  <section class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
    <h2 class="text-lg font-bold">Delivery details</h2>
    <div class="mt-5 grid gap-4 sm:grid-cols-2">
      <label class="text-sm font-medium">
        Full name
        <input :value="modelValue.name" required class="checkout-input" type="text" autocomplete="name" @input="emit('update:modelValue', { ...modelValue, name: $event.target.value })" />
      </label>
      <label class="text-sm font-medium">
        Email
        <input :value="modelValue.email" required class="checkout-input" type="email" autocomplete="email" @input="emit('update:modelValue', { ...modelValue, email: $event.target.value })" />
      </label>
      <label class="text-sm font-medium">
        Phone
        <input :value="modelValue.phone" required class="checkout-input" type="tel" autocomplete="tel" @input="emit('update:modelValue', { ...modelValue, phone: $event.target.value })" />
      </label>
      <label class="text-sm font-medium">
        City
        <input :value="modelValue.city" required class="checkout-input" type="text" autocomplete="address-level2" @input="emit('update:modelValue', { ...modelValue, city: $event.target.value })" />
      </label>
      <label class="text-sm font-medium sm:col-span-2">
        Address
        <input :value="modelValue.address" required class="checkout-input" type="text" autocomplete="street-address" @input="emit('update:modelValue', { ...modelValue, address: $event.target.value })" />
      </label>
      <label class="text-sm font-medium">
        Postal code
        <input :value="modelValue.postalCode" required class="checkout-input" type="text" autocomplete="postal-code" @input="emit('update:modelValue', { ...modelValue, postalCode: $event.target.value })" />
      </label>
    </div>
  </section>
</template>

<style scoped>
.checkout-input {
  display: block;
  width: 100%;
  margin-top: 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 0.5rem;
  padding: 0.7rem 0.8rem;
  font-weight: 400;
  outline: none;
}

.checkout-input:focus {
  border-color: #2563eb;
  box-shadow: 0 0 0 3px #dbeafe;
}
</style>
