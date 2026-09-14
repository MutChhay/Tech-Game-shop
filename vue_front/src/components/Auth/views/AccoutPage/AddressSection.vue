<script setup>
import { onMounted, ref } from 'vue'
import { addressService } from '../../../../services/addressService.js'
import FreeMapPicker from './FreeMapPicker.vue'

const addresses = ref([])
const newAddress = ref({ name: '' })
const showAddressForm = ref(false)
const mapPickerOpen = ref(false)
const selectedLocation = ref(null)
const deletingAddressId = ref(null)
const errorMessage = ref('')

const getErrorMessage = (error, fallback) => error.response && error.response.data && error.response.data.message || fallback

const loadAddresses = async () => {
  try {
    const response = await addressService.list()
    const data = response.data && response.data.data || response.data
    addresses.value = Array.isArray(data) ? data : data && data.addresses || []
  } catch (error) {
    errorMessage.value = getErrorMessage(error, 'Failed to load addresses.')
  }
}

const selectLocation = (location) => {
  selectedLocation.value = location
  mapPickerOpen.value = false
}

const addAddress = async () => {
  if (!newAddress.value.name || !selectedLocation.value) return

  try {
    const response = await addressService.create({ name: newAddress.value.name, ...selectedLocation.value })
    addresses.value.push(response.data && response.data.data || response.data)
    newAddress.value = { name: '' }
    selectedLocation.value = null
    showAddressForm.value = false
  } catch (error) {
    errorMessage.value = getErrorMessage(error, 'Failed to save address.')
  }
}

const deleteAddress = async (address) => {
  deletingAddressId.value = address.id
  errorMessage.value = ''

  try {
    await addressService.remove(address.id)
    addresses.value = addresses.value.filter(item => item.id !== address.id)
  } catch (error) {
    errorMessage.value = getErrorMessage(error, 'Failed to delete address.')
  } finally {
    deletingAddressId.value = null
  }
}

const googleMapsUrl = (address) => {
  const hasCoordinates = Number(address.lat) !== 0 && Number(address.lng) !== 0
  const query = hasCoordinates
    ? `${address.lat},${address.lng}`
    : [address.street, address.city, address.state, address.postal_code, address.country].filter(Boolean).join(', ')
  return `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(query)}`
}

onMounted(loadAddresses)
</script>

<template>
  <section class="rounded-2xl border border-gray-200 bg-white p-6">
    <div class="mb-6 flex items-center justify-between">
      <div>
        <h2 class="text-lg font-semibold text-gray-900">My Addresses</h2>
        <p class="text-sm text-gray-500">Manage your delivery addresses.</p>
      </div>
      <button class="rounded-xl bg-gray-900 px-4 py-2.5 text-sm font-medium text-white hover:bg-gray-800" @click="showAddressForm = !showAddressForm">+ Add Address</button>
    </div>

    <p v-if="errorMessage" class="mb-4 rounded-xl bg-red-50 px-4 py-3 text-sm text-red-700">{{ errorMessage }}</p>

    <div v-if="showAddressForm" class="mb-6 rounded-xl border border-gray-200 bg-gray-50 p-5">
      <h3 class="mb-4 font-semibold text-gray-900">Add New Address</h3>
      <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <input v-model="newAddress.name" placeholder="Address name e.g. Home" class="rounded-xl border border-gray-200 bg-white px-4 py-3 text-sm outline-none focus:border-gray-900 sm:col-span-2" />
        <button type="button" class="rounded-xl border border-gray-900 px-4 py-3 text-sm font-medium hover:bg-gray-900 hover:text-white sm:col-span-2" @click="mapPickerOpen = true">
          {{ selectedLocation ? 'Change location on map' : 'Choose location on map' }}
        </button>
        <div v-if="selectedLocation" class="rounded-xl bg-gray-100 px-4 py-3 text-sm text-gray-700 sm:col-span-2">
          {{ selectedLocation.street }}, {{ selectedLocation.city }}, {{ selectedLocation.country }}
        </div>
      </div>
      <button class="mt-4 rounded-xl bg-gray-900 px-5 py-2.5 text-sm font-medium text-white" @click="addAddress">Save Address</button>
    </div>

    <FreeMapPicker v-if="mapPickerOpen" @close="mapPickerOpen = false" @selected="selectLocation" />

    <div class="space-y-4">
      <div v-for="address in addresses" :key="address.id" class="rounded-xl border border-gray-200 p-5">
        <div class="flex items-start justify-between gap-4">
          <div>
            <div class="flex items-center gap-2">
              <h3 class="font-semibold text-gray-900">{{ address.name }}</h3>
              <span v-if="address.is_default" class="rounded-full bg-gray-100 px-2.5 py-1 text-xs font-medium text-gray-600">Default</span>
            </div>
            <p class="mt-2 text-sm text-gray-600">{{ address.street }}</p>
            <p class="text-sm text-gray-600">{{ address.state }}, {{ address.city }}</p>
            <p class="mt-1 text-sm text-gray-500">{{ address.postal_code }}, {{ address.country }}</p>
            <a :href="googleMapsUrl(address)" target="_blank" rel="noopener noreferrer" class="mt-3 inline-flex text-sm font-medium text-green-700 hover:text-green-800">Open in Google Maps</a>
          </div>
          <div class="flex gap-2">
            <button class="rounded-lg border border-gray-200 px-3 py-2 text-xs font-medium hover:bg-gray-50">Edit</button>
            <button :disabled="deletingAddressId === address.id" class="rounded-lg border border-red-100 px-3 py-2 text-xs font-medium text-red-600 hover:bg-red-50" @click="deleteAddress(address)">
              {{ deletingAddressId === address.id ? 'Deleting...' : 'Delete' }}
            </button>
          </div>
        </div>
      </div>
      <p v-if="!addresses.length" class="py-8 text-center text-sm text-gray-500">No saved addresses yet.</p>
    </div>
  </section>
</template>
