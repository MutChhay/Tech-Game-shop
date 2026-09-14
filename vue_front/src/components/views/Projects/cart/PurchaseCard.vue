<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const props = defineProps({
  product: {
    type: Object,
    required: true,
  },

  formattedPrice: {
    type: String,
    required: true,
  },

  deliveryLocation: {
    type: String,
    default: '',
  },

  colors: {
    type: Array,
    default: () => [],
  },

  styles: {
    type: Array,
    default: () => [],
  },

  quantity: {
    type: Number,
    default: 1,
  },

  selectedColor: {
    type: String,
    default: '',
  },

  selectedStyle: {
    type: String,
    default: '',
  },
})

const emit = defineEmits([
  'update:quantity',
  'update:selectedColor',
  'update:selectedStyle',
  'increase',
  'decrease',
  'add-to-cart',
  'buy-now',
  'open-location',
])

// ======================================================
// SAFE PRODUCT VALUES
// ======================================================

const productPrice = computed(() => {
  const price = Number(props.product?.price)

  return Number.isFinite(price) ? price : 0
})

const productStock = computed(() => {
  const stock = Number(props.product?.stock)

  return Number.isFinite(stock) ? stock : 0
})

const currentQuantity = computed(() => {
  const quantity = Number(props.quantity)

  if (!Number.isFinite(quantity) || quantity < 1) {
    return 1
  }

  if (productStock.value > 0) {
    return Math.min(quantity, productStock.value)
  }

  return quantity
})

// ======================================================
// SUBTOTAL
// ======================================================

const subtotal = computed(() => {
  return productPrice.value * currentQuantity.value
})

const formattedSubtotal = computed(() => {
  return subtotal.value.toFixed(2)
})

// ======================================================
// EVENTS
// ======================================================

function updateQuantity(value) {
  const quantity = Number(value)

  if (!Number.isFinite(quantity)) {
    return
  }

  emit('update:quantity', quantity)
}

function updateColor(value) {
  emit('update:selectedColor', value)
}

function updateStyle(value) {
  emit('update:selectedStyle', value)
}

function handleAddToCart(event) {
  emit('add-to-cart', event)
}

function handleBuyNow() {
  emit('buy-now', currentQuantity.value)
}

function handleIncrease() {
  emit('increase')
}

function handleDecrease() {
  emit('decrease')
}

function handleOpenLocation() {
  emit('open-location')
}
</script>

<template>
  <aside
    class="h-fit rounded-xl border border-gray-300 bg-white p-5 shadow-sm"
  >

    <!-- ======================================================
         PRICE
    ======================================================= -->

    <p class="text-2xl font-medium text-gray-900">
      <span class="mr-1 text-sm font-normal">
        USD
      </span>

      {{ formattedPrice }}
    </p>

    <!-- ======================================================
         DELIVERY DESCRIPTION
    ======================================================= -->

    <p class="mt-3 text-sm leading-6 text-gray-600">
        {{ t('Purchase.title') }}
    </p>

    <!-- ======================================================
         LOCATION
    ======================================================= -->

    <div
      class="mt-4 flex items-center gap-2 text-sm text-gray-600"
    >
      <span>
        {{ t('Purchase.Deliver') }}
      </span>

      <button
        type="button"
        class="inline-flex items-center gap-1 font-semibold text-blue-700 transition hover:text-blue-800 hover:underline"
        @click="handleOpenLocation"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-4 w-4"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          stroke-width="2"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M12 21s7-4.35 7-10a7 7 0 10-14 0c0 5.65 7 10 7 10z"
          />

          <circle
            cx="12"
            cy="11"
            r="2.5"
          />
        </svg>

        {{ deliveryLocation || t('Purchase.ChooseLocation') }}
      </button>
    </div>

    <!-- ======================================================
         COLOR
    ======================================================= -->

    <div
      v-if="colors.length"
      class="mt-5"
    >
      <p class="mb-2 text-sm font-semibold text-gray-700">
        Color
      </p>

      <select
        :value="selectedColor"
        class="w-full rounded-lg border border-gray-300 bg-white px-3 py-2.5 text-sm outline-none transition focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
        @change="updateColor($event.target.value)"
      >
        <option
          v-for="color in colors"
          :key="color"
          :value="color"
        >
          {{ color }}
        </option>
      </select>
    </div>

    <!-- ======================================================
         STYLE
    ======================================================= -->

    <div
      v-if="styles.length"
      class="mt-4"
    >
      <p class="mb-2 text-sm font-semibold text-gray-700">
        Style
      </p>

      <select
        :value="selectedStyle"
        class="w-full rounded-lg border border-gray-300 bg-white px-3 py-2.5 text-sm outline-none transition focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
        @change="updateStyle($event.target.value)"
      >
        <option
          v-for="style in styles"
          :key="style"
          :value="style"
        >
          {{ style }}
        </option>
      </select>
    </div>

    <!-- ======================================================
         STOCK
    ======================================================= -->

    <p
      class="mt-5 text-lg font-semibold"
      :class="
        productStock > 0
          ? 'text-emerald-700'
          : 'text-red-600'
      "
    >
      {{
        productStock > 0
          ?  t('product.istock')
          : t('product.Ostock')
      }}
    </p>

    <p
      v-if="productStock > 0"
      class="mt-1 text-sm text-gray-500"
    >
      {{t('Purchase.available')}}  {{ productStock }} {{t('nav.products')}} 
    </p>

    <!-- ======================================================
         QUANTITY
    ======================================================= -->

    <div
      v-if="productStock > 0"
      class="mt-5 flex items-center justify-between rounded-lg border border-gray-300 px-3 py-2"
    >
      <span class="text-sm font-medium text-gray-700">
        {{t('Purchase.Quantity')}}
      </span>

      <div class="flex items-center gap-3">

        <!-- DECREASE -->

        <button
          type="button"
          :disabled="currentQuantity <= 1"
          class="flex h-7 w-7 items-center justify-center rounded border border-gray-300 text-lg text-gray-700 transition hover:bg-gray-100 disabled:cursor-not-allowed disabled:opacity-40"
          @click="handleDecrease"
        >
          −
        </button>

        <!-- CURRENT QUANTITY -->

        <span
          class="min-w-6 text-center text-sm font-bold text-gray-900"
        >
          {{ currentQuantity }}
        </span>

        <!-- INCREASE -->

        <button
          type="button"
          :disabled="currentQuantity >= productStock"
          class="flex h-7 w-7 items-center justify-center rounded border border-gray-300 text-lg text-gray-700 transition hover:bg-gray-100 disabled:cursor-not-allowed disabled:opacity-40"
          @click="handleIncrease"
        >
          +
        </button>

      </div>
    </div>

    <!-- ======================================================
         PRODUCT SUBTOTAL
    ======================================================= -->

    <div
      v-if="productStock > 0"
      class="mt-4 rounded-lg bg-gray-50 px-4 py-3"
    >
      <div class="flex items-center justify-between text-sm">
        <span class="text-gray-500">
          {{t('Products.price')}}
        </span>

        <span class="font-medium text-gray-900">
          ${{ productPrice.toFixed(2) }}
        </span>
      </div>

      <div
        class="mt-2 flex items-center justify-between text-sm"
      >
        <span class="text-gray-500">
          {{t('Purchase.Quantity')}}
        </span>

        <span class="font-medium text-gray-900">
          × {{ currentQuantity }}
        </span>
      </div>

      <div
        class="mt-3 flex items-center justify-between border-t border-gray-200 pt-3"
      >
        <span class="font-semibold text-gray-700">
          {{t('nav.Total')}}
        </span>

        <span class="text-lg font-bold text-gray-900">
          ${{ formattedSubtotal }}
        </span>
      </div>
    </div>

    <!-- ======================================================
         ADD TO CART
    ======================================================= -->

    <button
      type="button"
      :disabled="productStock < 1"
      class="mt-5 w-full rounded-full bg-yellow-400 py-3 text-sm font-semibold text-gray-900 transition hover:bg-yellow-500 disabled:cursor-not-allowed disabled:bg-gray-300"
      @click="handleAddToCart"
    >
      {{ t('product.addToCart') }}
    </button>

    <!-- ======================================================
         BUY NOW
    ======================================================= -->

    <button
      type="button"
      :disabled="productStock < 1"
      class="mt-3 w-full rounded-full bg-orange-500 py-3 text-sm font-semibold text-white transition hover:bg-orange-600 disabled:cursor-not-allowed disabled:bg-gray-300"
      @click="handleBuyNow"
    >
      {{ t('product.buyNow') }}
    </button>

    <!-- ======================================================
         EXTRA INFORMATION
    ======================================================= -->

    <div
      class="mt-6 space-y-4 border-t border-gray-200 pt-5 text-sm"
    >

      <!-- SELLER -->

      <div
        class="grid grid-cols-[105px_1fr] gap-3"
      >
        <span class="text-gray-500">
          {{ t('Purchase.Seller') }}
        </span>

        <span class="font-medium text-blue-700">
          {{ product.seller || 'Your Store' }}
        </span>
      </div>

      <!-- RETURNS -->

      <div
        class="grid grid-cols-[105px_1fr] gap-3"
      >
        <span class="text-gray-500">
          {{t('Purchase.Returns')}}
        </span>

        <span class="text-blue-700">
          {{ t('Purchase.replacement') }}
        </span>
      </div>

      <!-- PAYMENT -->

      <div
        class="grid grid-cols-[105px_1fr] gap-3"
      >
        <span class="text-gray-500">
          {{t('Purchase.Payment')}}
        </span>

        <span class="text-blue-700">
          {{ t('Purchase.transactionS') }}
        </span>
      </div>

    </div>

    <!-- ======================================================
         ADD TO LIST
    ======================================================= -->

    <button
      type="button"
      class="mt-6 w-full rounded-lg border border-gray-400 py-2.5 text-sm font-medium text-gray-700 transition hover:bg-gray-50"
    >
      {{ t('Purchase.ADDTL') }}
    </button>

  </aside>
</template>