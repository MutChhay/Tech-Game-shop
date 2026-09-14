<script setup>
import { computed, ref } from 'vue'

const props = defineProps({
  product: {
    type: Object,
    required: true,
  },

  specifications: {
    type: Array,
    default: () => [],
  },

  previewCount: {
    type: Number,
    default: 4,
  },
})

const showAll = ref(false)

const availableSpecifications = computed(() => {
  return props.specifications.filter((specification) => {
    const value = props.product?.[specification.key]

    return value !== null && value !== undefined && value !== ''
  })
})

const visibleSpecifications = computed(() => {
  if (showAll.value) {
    return availableSpecifications.value
  }

  return availableSpecifications.value.slice(0, props.previewCount)
})

const hasMoreSpecifications = computed(() => {
  return availableSpecifications.value.length > props.previewCount
})

function toggleSpecifications() {
  showAll.value = !showAll.value
}
</script>

<template>
  <section class="mt-16 border-t border-gray-200 pt-10">
    <div class="flex flex-wrap items-end justify-between gap-4">
      <div>
        <p class="text-xs font-bold uppercase tracking-[0.2em] text-blue-700">
          At a glance
        </p>

        <h2 class="mt-2 text-2xl font-bold text-gray-900">
          Specifications
        </h2>
      </div>

      <button
        v-if="hasMoreSpecifications"
        type="button"
        class="text-sm font-semibold text-blue-700 transition hover:text-blue-900 hover:underline"
        @click="toggleSpecifications"
      >
        {{ showAll ? 'Show less' : 'View all specifications' }}
      </button>
    </div>

    <!-- No specification data -->
    <div
      v-if="availableSpecifications.length === 0"
      class="mt-6 rounded-xl border border-dashed border-gray-300 bg-gray-50 p-6 text-sm text-gray-500"
    >
      No specifications available for this product.
    </div>

    <!-- Specifications table -->
    <div
      v-else
      class="mt-6 overflow-hidden rounded-xl border border-gray-200 bg-white"
    >
      <div
        v-for="specification in visibleSpecifications"
        :key="specification.key"
        class="grid grid-cols-2 border-b border-gray-100 px-5 py-4 transition last:border-b-0 hover:bg-gray-50 sm:grid-cols-3"
      >
        <p class="text-sm font-semibold text-gray-500">
          {{ specification.label }}
        </p>

        <p class="col-span-1 text-right text-sm font-medium text-gray-900 sm:col-span-2">
          {{ product[specification.key] }}
        </p>
      </div>
    </div>

    <!-- Bottom button for mobile / clearer layout -->
    <button
      v-if="hasMoreSpecifications"
      type="button"
      class="mt-4 rounded-lg border border-gray-300 px-4 py-2 text-sm font-semibold text-gray-700 transition hover:bg-gray-50"
      @click="toggleSpecifications"
    >
      {{
        showAll
          ? 'Show fewer specifications'
          : `Show ${availableSpecifications.length - previewCount} more specifications`
      }}
    </button>
  </section>
</template>