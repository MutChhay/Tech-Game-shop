<template>
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
    <div class="w-full max-w-3xl overflow-hidden rounded-2xl bg-white shadow-2xl">
      <div class="flex items-center justify-between border-b border-gray-200 px-5 py-4">
        <div>
          <h3 class="font-semibold text-gray-900">Choose your location</h3>
          <p class="text-sm text-gray-500">Click your exact location on the map.</p>
        </div>
        <button
          type="button"
          class="rounded-lg px-3 py-2 text-xl text-gray-500 hover:bg-gray-100"
          aria-label="Close map"
          @click="$emit('close')"
        >
          &times;
        </button>
      </div>

      <div ref="mapElement" class="h-[65vh] min-h-[360px] w-full bg-gray-100"></div>

      <p v-if="errorMessage" class="border-t border-red-100 bg-red-50 px-5 py-3 text-sm text-red-700">
        {{ errorMessage }}
      </p>

      <div class="flex justify-end gap-3 border-t border-gray-200 px-5 py-4">
        <button
          type="button"
          class="rounded-xl border border-gray-200 px-4 py-2.5 text-sm font-medium hover:bg-gray-50"
          @click="$emit('close')"
        >
          Cancel
        </button>
        <button
          type="button"
          class="rounded-xl bg-gray-900 px-5 py-2.5 text-sm font-medium text-white disabled:cursor-not-allowed disabled:opacity-50"
          :disabled="!selectedLocation || isLoading"
          @click="$emit('selected', selectedLocation)"
        >
          {{ isLoading ? 'Finding address...' : 'Use this location' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

defineEmits(['close', 'selected'])

const mapElement = ref(null)
const selectedLocation = ref(null)
const errorMessage = ref('')
const isLoading = ref(false)
let map
let marker

const parseAddress = (address) => ({
  street: [address.house_number, address.road].filter(Boolean).join(' ') || address.display_name,
  city: address.city || address.town || address.village || address.municipality || '',
  state: address.state || '',
  postal_code: address.postcode || '',
  country: address.country || '',
})

const reverseGeocode = async (lat, lng) => {
  const params = new URLSearchParams({
    format: 'jsonv2',
    lat: String(lat),
    lon: String(lng),
    addressdetails: '1',
  })
  const response = await fetch(`https://nominatim.openstreetmap.org/reverse?${params}`)
  if (!response.ok) throw new Error('Could not find an address for that location.')
  return response.json()
}

const selectPoint = async (event) => {
  const { lat, lng } = event.latlng
  isLoading.value = true
  errorMessage.value = ''
  marker?.setLatLng([lat, lng])
  if (!marker) {
    marker = L.marker([lat, lng], { icon: L.divIcon({ className: 'free-map-marker', html: '📍' }) }).addTo(map)
  }

  try {
    const result = await reverseGeocode(lat, lng)
    selectedLocation.value = { lat, lng, ...parseAddress(result.address) }
  } catch (error) {
    selectedLocation.value = null
    errorMessage.value = error.message
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  map = L.map(mapElement.value).setView([11.5564, 104.9282], 13)
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap contributors',
    maxZoom: 19,
  }).addTo(map)
  map.on('click', selectPoint)
})

onBeforeUnmount(() => {
  map?.remove()
})
</script>

<style scoped>
:global(.free-map-marker) {
  background: transparent;
  border: 0;
  font-size: 2rem;
  line-height: 1;
}
</style>