<script setup>
defineProps({
  products: {
    type: Array,
    default: () => [],
  },
})
</script>

<template>
  <section
    v-if="products.length"
    class="mt-16 border-t border-gray-200 pt-10"
  >

    <!-- ======================================================
         HEADER
    ======================================================= -->

    <p
      class="text-xs font-bold uppercase tracking-[0.2em] text-blue-700"
    >
      You may also like
    </p>

    <h2
      class="mt-2 text-2xl font-bold text-gray-900"
    >
      Related Products
    </h2>

    <!-- ======================================================
         PRODUCTS GRID
    ======================================================= -->

    <div
      class="mt-7 grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-4"
    >

      <RouterLink
        v-for="item in products"
        :key="item.id"
        :to="`/products/detail/${item.id}`"
        class="group cursor-pointer overflow-hidden rounded-xl border border-gray-200 bg-white transition hover:-translate-y-1 hover:border-gray-300 hover:shadow-md"
      >

        <!-- ==================================================
             IMAGE
        =================================================== -->

        <div
          class="aspect-square overflow-hidden bg-gray-50"
        >
          <img
            v-if="item.image_url"
            :src="item.image_url"
            :alt="item.name"
            class="h-full w-full object-contain p-5 transition duration-300 group-hover:scale-105"
          />

          <div
            v-else
            class="flex h-full items-center justify-center text-xs text-gray-400"
          >
            No image
          </div>
        </div>

        <!-- ==================================================
             CONTENT
        =================================================== -->

        <div class="p-4">

          <p
            class="truncate text-xs font-semibold uppercase tracking-wider text-blue-700"
          >
            {{ item.category_name || 'Product' }}
          </p>

          <h3
            class="mt-2 line-clamp-2 min-h-10 text-sm font-bold text-gray-900"
          >
            {{ item.name }}
          </h3>

          <div
            class="mt-3 flex items-center justify-between gap-2"
          >

            <p class="font-bold text-gray-900">
              USD
              {{
                Number(item.price || 0).toLocaleString(
                  'en-US',
                  {
                    minimumFractionDigits: 2,
                    maximumFractionDigits: 2,
                  }
                )
              }}
            </p>

            <span
              class="shrink-0 text-xs text-yellow-500"
            >
              ★ {{ item.rating || '4.3' }}
            </span>

          </div>

        </div>

      </RouterLink>

    </div>

  </section>
</template>