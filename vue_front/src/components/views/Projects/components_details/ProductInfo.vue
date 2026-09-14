<script setup>
defineProps({
  product: {
    type: Object,
    required: true,
  },

  specifications: {
    type: Array,
    required: true,
  },

  formattedPrice: {
    type: String,
    required: true,
  },
})
</script>

<template>
  <div class="min-w-0">

    <!-- ======================================================
         CATEGORY
    ======================================================= -->

    <div class="flex items-center gap-2">
      <span class="text-sm font-medium text-gray-500">
        PRODUCT:
      </span>

      <span class="text-sm font-semibold text-blue-700">
        <RouterLink
          :to="`/products/${product.category_name?.toLowerCase()}`"
          class="hover:underline"
        >
          {{ product.category_name || 'Product' }}
        </RouterLink>
      </span>
    </div>

    <!-- ======================================================
         PRODUCT NAME
    ======================================================= -->

    <h1
      class="mt-2 text-2xl font-semibold leading-tight text-gray-900"
    >
      {{ product.name }}
    </h1>

    <!-- ======================================================
         RATING
    ======================================================= -->

    <div
      class="mt-4 flex flex-wrap items-center gap-2 border-b border-gray-200 pb-4"
    >
      <span class="text-sm font-semibold text-gray-900">
        {{ product.rating || '4.3' }}
      </span>

      <span class="text-base tracking-wide text-yellow-500">
        ★★★★<span class="text-gray-300">★</span>
      </span>

      <span class="text-sm text-blue-700">
        ({{ product.review_count || 128 }} reviews)
      </span>

      <span class="text-gray-300">
        |
      </span>

      <span class="text-sm text-gray-700">
        {{ product.sold_count || '4K+' }} bought recently
      </span>
    </div>

    <!-- ======================================================
         PRICE
    ======================================================= -->

    <div class="mt-5">
      <p class="text-sm text-gray-500">
        Price
      </p>

      <p class="mt-1 text-3xl font-medium text-gray-900">
        <span class="mr-1 text-base font-normal">
          USD
        </span>

        {{ formattedPrice }}
      </p>
    </div>

    <!-- ======================================================
         DESCRIPTION
    ======================================================= -->

    <div class="mt-1 pt-6">

      <p
        class="text-xs font-bold uppercase tracking-[0.2em] text-blue-700"
      >
        Product information
      </p>

      <p
        class="mt-3 text-sm leading-7 text-gray-600"
      >
        {{
          product.description ||
          'A reliable addition to your setup, ready for your next project.'
        }}
      </p>

    </div>

    <!-- ======================================================
         SPECIFICATIONS
    ======================================================= -->

    <div
      class="mt-8 border-t border-gray-200 pt-6"
    >
      <h2
        class="text-xl font-bold text-gray-900"
      >
        Specifications
      </h2>

      <div
        class="mt-4 overflow-hidden rounded-xl border border-gray-200 bg-white"
      >
        <div
          v-for="specification in specifications"
          :key="specification.key"
          class="grid grid-cols-2 border-b border-gray-100 px-4 py-3 last:border-b-0 hover:bg-gray-50"
        >
          <p
            class="text-xs font-semibold text-gray-500"
          >
            {{ specification.label }}
          </p>

          <p
            class="text-right text-xs font-medium text-gray-900"
          >
            {{
              product[specification.key] ||
              'Not specified'
            }}
          </p>
        </div>
      </div>
    </div>

  </div>
</template>