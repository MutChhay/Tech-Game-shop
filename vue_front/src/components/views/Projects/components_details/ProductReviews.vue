<script setup>
defineProps({
  product: {
    type: Object,
    required: true,
  },
})
</script>

<template>
  <section
    class="mt-14 border-t border-gray-200 pt-10"
  >

    <!-- ======================================================
         HEADER
    ======================================================= -->

    <div
      class="flex flex-wrap items-center justify-between gap-4"
    >
      <div>

        <p
          class="text-xs font-bold uppercase tracking-[0.2em] text-blue-700"
        >
          Customer feedback
        </p>

        <h2
          class="mt-2 text-2xl font-bold text-gray-900"
        >
          Reviews
        </h2>

      </div>

      <button
        type="button"
        class="text-sm font-bold text-blue-700 hover:underline"
      >
        Write a review
      </button>
    </div>

    <!-- ======================================================
         RATING SUMMARY
    ======================================================= -->

    <div
      class="mt-6 rounded-xl border border-gray-200 bg-gray-50 p-6"
    >
      <div class="flex items-center gap-4">

        <p
          class="text-4xl font-bold text-gray-900"
        >
          {{ product.rating || '4.3' }}
        </p>

        <div>

          <p
            class="text-lg tracking-wide text-yellow-500"
          >
            ★★★★<span class="text-gray-300">★</span>
          </p>

          <p
            class="mt-1 text-sm text-gray-500"
          >
            Based on
            {{ product.review_count || 128 }}
            reviews
          </p>

        </div>

      </div>
    </div>

  </section>
</template>