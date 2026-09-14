<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const props = defineProps({
    status: {
        type: [String, Number],
        default: '',
    },
})

const steps = [
    { value: 'pending', label: 'Order placed' },
    { value: 'processing', label: 'Processing' },
    { value: 'packed', label: 'Packed' },
    { value: 'shipped', label: 'Shipped' },
    { value: 'delivered', label: 'Delivered' },
]

const normalizedStatus = computed(() => String(props.status || '').toLowerCase().trim())
const isCancelled = computed(() => ['cancelled', 'canceled'].includes(normalizedStatus.value))
const isCancellationRequested = computed(() => normalizedStatus.value === 'cancellation_requested')
const currentIndex = computed(() => steps.findIndex(step => step.value === normalizedStatus.value))

function stepState(index) {
    if (isCancelled.value || isCancellationRequested.value) return 'cancelled'
    if (currentIndex.value < 0) return 'upcoming'
    if (index < currentIndex.value) return 'complete'
    if (index === currentIndex.value) return 'current'
    return 'upcoming'
}
</script>

<template>
  <section class="rounded-xl border border-gray-200 bg-white p-5 shadow-sm sm:p-6">
    <div class="flex items-center justify-between gap-4">
      <h2 class="text-lg font-bold">{{t('Order.orderTracking')}}</h2>
      <span v-if="status" class="rounded-full bg-gray-100 px-3 py-1 text-xs font-semibold capitalize text-gray-700">{{ t('Order.RequestCancellation') }}</span>
    </div>

    <div v-if="isCancelled" class="mt-5 rounded-lg border border-red-100 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">
      {{ t('Order.isCancelled') }}
    </div>

    <div v-else-if="isCancellationRequested" class="mt-5 rounded-lg border border-amber-100 bg-amber-50 px-4 py-3 text-sm font-medium text-amber-800">
      {{ t('Order.isCancellationRequested') }}
    </div>

    <div v-else class="relative mt-8 grid grid-cols-5 gap-1">
      <div class="absolute left-[10%] right-[10%] top-3 h-0.5 bg-gray-200">
        <div class="progress-line h-full bg-gray-900" :style="{ width: `${Math.max(0, currentIndex) / (steps.length - 1) * 100}%` }"></div>
      </div>
      <div v-for="(step, index) in steps" :key="step.value" class="relative z-10 flex flex-col items-center text-center">
        <div class="status-dot flex h-6 w-6 items-center justify-center rounded-full border-2 text-[10px] font-bold" :class="{
          'border-gray-900 bg-gray-900 text-white': stepState(index) === 'complete',
          'current-status border-gray-900 bg-white text-gray-900': stepState(index) === 'current',
          'border-gray-200 bg-white text-transparent': stepState(index) === 'upcoming',
        }">
          <span v-if="stepState(index) === 'complete'">✓</span>
        </div>
        <span class="mt-3 text-[11px] font-medium leading-tight text-gray-600 sm:text-xs">{{ step.label }}</span>
      </div>
    </div>

    <p v-if="!status" class="mt-5 text-sm text-gray-500">The order status is not available yet.</p>
  </section>
</template>

<style scoped>
.progress-line { transition: width 500ms ease; }
.current-status { animation: pulse 2s ease-in-out infinite; }

@keyframes pulse {
  0%, 100% { box-shadow: 0 0 0 0 rgba(17, 24, 39, 0.12); }
  50% { box-shadow: 0 0 0 6px rgba(17, 24, 39, 0); }
}
</style>
