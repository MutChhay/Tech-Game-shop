<script setup>
import { computed } from 'vue'

const props = defineProps({
  product: {
    type: Object,
    required: true,
  },

  selectedImage: {
    type: Number,
    default: 0,
  },
})

const emit = defineEmits([
  'update:selectedImage',
])

// ============================================================
// PRODUCT IMAGES
// ============================================================

const productImages = computed(() => {
  if (!props.product) {
    return []
  }

  return [
    props.product.image_url,
    props.product.image_url,
    props.product.image_url,
    props.product.image_url,
  ].filter(Boolean)
})

// ============================================================
// SELECT IMAGE
// ============================================================

function selectImage(index) {
  emit('update:selectedImage', index)
}
</script>

<template>
  <div class="flex min-w-0 gap-4">

    <!-- ======================================================
         DESKTOP THUMBNAILS
    ======================================================= -->

    <div
      v-if="productImages.length > 1"
      class="hidden w-16 shrink-0 flex-col gap-3 sm:flex"
    >
      <button
        v-for="(image, index) in productImages"
        :key="`thumbnail-${image}-${index}`"
        type="button"
        class="h-16 w-16 overflow-hidden rounded-lg border bg-white transition"
        :class="
          selectedImage === index
            ? 'border-blue-600 ring-2 ring-blue-100'
            : 'border-gray-200 hover:border-gray-400'
        "
        @click="selectImage(index)"
      >
        <img
          :src="image"
          :alt="`${product.name} image ${index + 1}`"
          class="h-full w-full object-contain p-1"
        />
      </button>
    </div>

    <!-- ======================================================
         MAIN IMAGE
    ======================================================= -->

    <div class="min-w-0 flex-1">

      <div
        class="flex aspect-square items-center justify-center overflow-hidden rounded-xl border border-gray-200 bg-white"
      >
        <img
          v-if="productImages.length"
          :src="productImages[selectedImage]"
          :alt="product.name"
          class="h-full w-full object-contain"
        />

        <span
          v-else
          class="text-sm text-gray-400"
        >
          No image available
        </span>
      </div>

      <!-- ====================================================
           MOBILE THUMBNAILS
      ===================================================== -->

      <div
        v-if="productImages.length > 1"
        class="mt-4 flex gap-3 overflow-x-auto pb-1 sm:hidden"
      >
        <button
          v-for="(image, index) in productImages"
          :key="`mobile-thumbnail-${image}-${index}`"
          type="button"
          class="h-16 w-16 shrink-0 overflow-hidden rounded-lg border bg-white"
          :class="
            selectedImage === index
              ? 'border-blue-600 ring-2 ring-blue-100'
              : 'border-gray-200'
          "
          @click="selectImage(index)"
        >
          <img
            :src="image"
            :alt="`${product.name} image ${index + 1}`"
            class="h-full w-full object-contain p-1"
          />
        </button>
      </div>

      <p
        class="mt-3 text-center text-sm font-medium text-blue-700"
      >
        Click to see full view
      </p>

    </div>
  </div>
</template>