<script setup>
import { ref, onMounted } from 'vue'
import { addressService } from '../../services/addressService'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true,
  },
})

const emit = defineEmits(['update:modelValue'])

const addresses = ref([])
const loading = ref(true)
const error = ref('')
const selectedAddressId = ref(null)

const selectAddress = (address) => {
  selectedAddressId.value = address.id

  emit('update:modelValue', {
    ...props.modelValue,

    name: address.name,
    phone: address.phone,
    city: address.city,
    address: address.street || address.address || '',
    postalCode: address.postal_code || address.postalCode || '',
  })
}

const loadAddresses = async () => {
  try {
    loading.value = true
    error.value = ''

    const response = await addressService.list()

    // Laravel usually returns data
    const data = response.data.data ?? response.data
    addresses.value = Array.isArray(data) ? data : data?.addresses || []

    // Automatically select the first saved address
    if (addresses.value.length > 0) {
      const defaultAddress =
        addresses.value.find(address => address.is_default) ||
        addresses.value[0]

      selectAddress(defaultAddress)
    }
  } catch (err) {
    console.error('Failed to load addresses:', err)
    error.value = 'Unable to load your saved addresses.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadAddresses()
})
</script>

<template>
  <section class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-bold">
        Delivery details
      </h2>

      <RouterLink
        to="/profile/addresses"
        class="text-sm font-medium text-blue-600 hover:text-blue-700"
      >
        Manage addresses
      </RouterLink>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="mt-5 text-sm text-gray-500">
      Loading your saved addresses...
    </div>

    <!-- Error -->
    <div
      v-else-if="error"
      class="mt-5 rounded-lg bg-red-50 p-4 text-sm text-red-600"
    >
      {{ error }}
    </div>

    <!-- Saved Addresses -->
    <div v-else-if="addresses.length > 0" class="mt-5 space-y-3">

      <p class="text-sm font-medium text-gray-700">
        Select delivery address
      </p>

      <button
        v-for="address in addresses"
        :key="address.id"
        type="button"
        @click="selectAddress(address)"
        class="w-full rounded-xl border p-4 text-left transition"
        :class="
          selectedAddressId === address.id
            ? 'border-blue-600 bg-blue-50 ring-1 ring-blue-600'
            : 'border-gray-200 hover:border-gray-400'
        "
      >
        <div class="flex items-start justify-between gap-4">

          <div>
            <p class="font-semibold text-gray-900">
              {{ address.name }}
            </p>

            <p class="mt-1 text-sm text-gray-600">
              {{ address.phone }}
            </p>

            <p class="mt-1 text-sm text-gray-600">
              {{ address.street || address.address }}
            </p>

            <p class="text-sm text-gray-600">
              {{ address.city }}
              <span v-if="address.postal_code">
                , {{ address.postal_code }}
              </span>
            </p>
          </div>

          <!-- Selected -->
          <div
            v-if="selectedAddressId === address.id"
            class="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-blue-600 text-xs text-white"
          >
            ✓
          </div>
        </div>

        <!-- Default badge -->
        <span
          v-if="address.is_default"
          class="mt-3 inline-block rounded-full bg-green-100 px-2.5 py-1 text-xs font-medium text-green-700"
        >
          Default address
        </span>
      </button>

      <RouterLink
        to="/profile/addresses"
        class="block pt-2 text-sm font-medium text-blue-600 hover:underline"
      >
        + Add another address
      </RouterLink>
    </div>

    <!-- No saved address -->
    <div v-else class="mt-5">

      <div class="mb-5 rounded-lg bg-yellow-50 p-4">
        <p class="text-sm font-medium text-yellow-800">
          You don't have a saved address yet.
        </p>

        <p class="mt-1 text-sm text-yellow-700">
          Please enter your delivery information below.
        </p>
      </div>

      <div class="grid gap-4 sm:grid-cols-2">

        <label class="text-sm font-medium">
          Full name

          <input
            :value="modelValue.name"
            required
            class="checkout-input"
            type="text"
            autocomplete="name"
            @input="
              emit('update:modelValue', {
                ...modelValue,
                name: $event.target.value
              })
            "
          />
        </label>

        <label class="text-sm font-medium">
          Phone

          <input
            :value="modelValue.phone"
            required
            class="checkout-input"
            type="tel"
            autocomplete="tel"
            @input="
              emit('update:modelValue', {
                ...modelValue,
                phone: $event.target.value
              })
            "
          />
        </label>

        <label class="text-sm font-medium">
          City

          <input
            :value="modelValue.city"
            required
            class="checkout-input"
            type="text"
            autocomplete="address-level2"
            @input="
              emit('update:modelValue', {
                ...modelValue,
                city: $event.target.value
              })
            "
          />
        </label>

        <label class="text-sm font-medium">
          Postal code

          <input
            :value="modelValue.postalCode"
            class="checkout-input"
            type="text"
            autocomplete="postal-code"
            @input="
              emit('update:modelValue', {
                ...modelValue,
                postalCode: $event.target.value
              })
            "
          />
        </label>

        <label class="text-sm font-medium sm:col-span-2">
          Address

          <input
            :value="modelValue.address"
            required
            class="checkout-input"
            type="text"
            autocomplete="street-address"
            @input="
              emit('update:modelValue', {
                ...modelValue,
                address: $event.target.value
              })
            "
          />
        </label>

      </div>
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