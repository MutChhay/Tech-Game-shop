<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useCartStore } from '../../../../Store/carts'

const router = useRouter()
const cartStore = useCartStore()

// ======================================================
// CART DATA
// ======================================================

const cart = computed(() => cartStore.items)

// ======================================================
// SELECTED ITEMS
// ======================================================

const selectedItems = ref([])

// ======================================================
// TOTAL ITEMS
// ======================================================

const totalItems = computed(() => {
  return cartStore.totalItems
})

// ======================================================
// SUBTOTAL
// ======================================================

const subtotal = computed(() => {
  return cart.value
    .filter(item => selectedItems.value.includes(item.id))
    .reduce((total, item) => {
      return total + Number(item.price) * Number(item.quantity)
    }, 0)
})

// ======================================================
// DELIVERY
// ======================================================

const deliveryFee = computed(() => {
  return subtotal.value > 0 ? 0 : 0
})

// ======================================================
// GRAND TOTAL
// ======================================================

const grandTotal = computed(() => {
  return subtotal.value + deliveryFee.value
})

// ======================================================
// FORMAT PRICE
// ======================================================

function formatPrice(price) {
  return Number(price).toFixed(2)
}

// ======================================================
// QUANTITY
// ======================================================

function increaseQuantity(item) {
  cartStore.increaseQuantity(item.id)
}

function decreaseQuantity(item) {
  cartStore.decreaseQuantity(item.id)
}

// ======================================================
// REMOVE
// ======================================================

function removeItem(id) {
  cartStore.removeFromCart(id)

  selectedItems.value = selectedItems.value.filter(
    itemId => itemId !== id
  )
}

// ======================================================
// SELECT ITEM
// ======================================================

function toggleItem(id) {
  if (selectedItems.value.includes(id)) {
    selectedItems.value = selectedItems.value.filter(
      itemId => itemId !== id
    )
  } else {
    selectedItems.value.push(id)
  }
}

// ======================================================
// SELECT ALL
// ======================================================

const allSelected = computed(() => {
  return (
    cart.value.length > 0 &&
    selectedItems.value.length === cart.value.length
  )
})

function toggleSelectAll() {
  if (allSelected.value) {
    selectedItems.value = []
  } else {
    selectedItems.value = cart.value.map(item => item.id)
  }
}

// ======================================================
// CLEAR CART
// ======================================================

function clearCart() {
  cartStore.clearCart()
  selectedItems.value = []
}

// ======================================================
// CHECKOUT
// ======================================================

function checkout() {
  if (selectedItems.value.length === 0) {
    alert('Please select at least one product.')
    return
  }

  router.push({
    path: '/checkout',
    query: { items: selectedItems.value.join(',') },
  })
}
</script>

<template>
  <div class="min-h-screen bg-gray-100">

    <!-- ==================================================
         HEADER
    =================================================== -->

    <header class="border-b border-gray-200 bg-white">
      <div
        class="mx-auto flex max-w-7xl items-center justify-between px-6 py-5 lg:px-12"
      >

        <div>
          <h1 class="text-2xl font-bold text-gray-900">
            Shopping Cart
          </h1>

          <p class="mt-1 text-sm text-gray-500">
            {{ totalItems }} item(s) in your cart
          </p>
        </div>

        <button
          v-if="cart.length"
          type="button"
          class="text-sm font-medium text-red-600 transition hover:text-red-700 hover:underline"
          @click="clearCart"
        >
          Clear cart
        </button>

      </div>
    </header>

    <!-- ==================================================
         MAIN
    =================================================== -->

    <main class="mx-auto max-w-7xl px-6 py-8 lg:px-12">

      <!-- =================================================
           EMPTY CART
      ================================================== -->

      <div
        v-if="cart.length === 0"
        class="rounded-xl border border-gray-200 bg-white px-6 py-20 text-center shadow-sm"
      >

        <!-- Cart Icon -->

        <div
          class="mx-auto flex h-20 w-20 items-center justify-center rounded-full bg-gray-100"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-10 w-10 text-gray-400"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            stroke-width="1.5"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2 4h13m-9 0a2 2 0 104 0m4 0a2 2 0 104 0"
            />
          </svg>
        </div>

        <h2 class="mt-6 text-xl font-bold text-gray-900">
          Your cart is empty
        </h2>

        <p class="mx-auto mt-2 max-w-md text-sm text-gray-500">
          Looks like you haven't added anything to your cart yet.
          Start shopping and find something you like.
        </p>

        <router-link
          to="/products"
          class="mt-6 inline-flex rounded-full bg-gray-900 px-7 py-3 text-sm font-semibold text-white transition hover:bg-gray-800"
        >
          Continue Shopping
        </router-link>

      </div>

      <!-- =================================================
           CART
      ================================================== -->

      <div
        v-else
        class="grid gap-6 lg:grid-cols-[1fr_380px]"
      >

        <!-- =================================================
             LEFT: PRODUCTS
        ================================================== -->

        <section class="space-y-4">

          <!-- SELECT ALL -->

          <div
            class="flex items-center justify-between rounded-xl border border-gray-200 bg-white px-5 py-4 shadow-sm"
          >

            <label class="flex cursor-pointer items-center gap-3">

              <input
                type="checkbox"
                :checked="allSelected"
                class="h-4 w-4 rounded border-gray-300 text-gray-900 focus:ring-gray-900"
                @change="toggleSelectAll"
              />

              <span class="text-sm font-semibold text-gray-800">
                Select all
              </span>

            </label>

            <span class="text-sm text-gray-500">
              {{ cart.length }} product(s)
            </span>

          </div>

          <!-- =================================================
               PRODUCT ITEM
          ================================================== -->

          <article
            v-for="item in cart"
            :key="item.id"
            class="rounded-xl border border-gray-200 bg-white p-5 shadow-sm"
          >

            <div class="flex gap-4">

              <!-- CHECKBOX -->

              <div class="pt-2">
                <input
                  type="checkbox"
                  :checked="selectedItems.includes(item.id)"
                  class="h-4 w-4 rounded border-gray-300 text-gray-900 focus:ring-gray-900"
                  @change="toggleItem(item.id)"
                />
              </div>

              <!-- IMAGE -->

              <div
                class="h-28 w-28 shrink-0 overflow-hidden rounded-lg bg-gray-50"
              >
                <img
                    :src="item.image"
                    :alt="item.name"
                    class="h-full w-full object-contain p-2"
                />
              </div>

              <!-- PRODUCT INFORMATION -->

              <div class="min-w-0 flex-1">

                <div class="flex items-start justify-between gap-4">

                  <div>
                    <h2
                      class="line-clamp-2 text-base font-semibold text-gray-900"
                    >
                      {{ item.name }}
                    </h2>

                    <p class="mt-1 text-sm text-emerald-600">
                      In Stock
                    </p>
                  </div>

                  <!-- PRICE -->

                  <p class="shrink-0 text-lg font-bold text-gray-900">
                    ${{ formatPrice(item.price) }}
                  </p>

                </div>

                <!-- QUANTITY + REMOVE -->

                <div
                  class="mt-5 flex items-center justify-between"
                >

                  <!-- QUANTITY -->

                  <div class="flex items-center gap-3">

                    <span class="text-sm text-gray-500">
                      Quantity
                    </span>

                    <div
                      class="flex items-center overflow-hidden rounded-lg border border-gray-300"
                    >

                      <button
                        type="button"
                        :disabled="item.quantity <= 1"
                        class="flex h-8 w-8 items-center justify-center text-lg text-gray-700 transition hover:bg-gray-100 disabled:cursor-not-allowed disabled:opacity-40"
                        @click="decreaseQuantity(item)"
                      >
                        −
                      </button>

                      <span
                        class="flex h-8 min-w-9 items-center justify-center border-x border-gray-300 px-2 text-sm font-semibold"
                      >
                        {{ item.quantity }}
                      </span>

                      <button
                        type="button"
                        :disabled="
                          item.quantity >= Number(item.stock)
                        "
                        class="flex h-8 w-8 items-center justify-center text-lg text-gray-700 transition hover:bg-gray-100 disabled:cursor-not-allowed disabled:opacity-40"
                        @click="increaseQuantity(item)"
                      >
                        +
                      </button>

                    </div>

                  </div>

                  <!-- REMOVE -->

                  <button
                    type="button"
                    class="text-sm font-medium text-red-600 transition hover:text-red-700 hover:underline"
                    @click="removeItem(item.id)"
                  >
                    Remove
                  </button>

                </div>

                <!-- SUBTOTAL -->

                <div
                  class="mt-4 flex items-center justify-between border-t border-gray-100 pt-3"
                >

                  <span class="text-sm text-gray-500">
                    Item subtotal
                  </span>

                  <span class="font-semibold text-gray-900">
                    ${{
                      formatPrice(
                        Number(item.price) *
                        Number(item.quantity)
                      )
                    }}
                  </span>

                </div>

              </div>

            </div>

          </article>

        </section>

        <!-- =================================================
             RIGHT: ORDER SUMMARY
        ================================================== -->

        <aside class="h-fit">

          <div
            class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
          >

            <h2 class="text-lg font-bold text-gray-900">
              Order Summary
            </h2>

            <!-- SELECTED ITEMS -->

            <div
              class="mt-5 space-y-3 border-b border-gray-200 pb-5"
            >

              <div class="flex justify-between text-sm">
                <span class="text-gray-500">
                  Selected items
                </span>

                <span class="font-medium text-gray-900">
                  {{ selectedItems.length }}
                </span>
              </div>

              <div class="flex justify-between text-sm">
                <span class="text-gray-500">
                  Subtotal
                </span>

                <span class="font-medium text-gray-900">
                    ${{ formatPrice(subtotal) }}
                </span>
              </div>

              <div class="flex justify-between text-sm">
                <span class="text-gray-500">
                  Delivery
                </span>

                <span class="font-medium text-emerald-600">
                  {{
                    deliveryFee === 0
                      ? 'FREE'
                      : `$${formatPrice(deliveryFee)}`
                  }}
                </span>
              </div>

            </div>

            <!-- TOTAL -->

            <div
              class="mt-5 flex items-center justify-between"
            >
              <span class="text-base font-semibold text-gray-700">
                Total
              </span>

              <span class="text-2xl font-bold text-gray-900">
                ${{ formatPrice(grandTotal) }}
              </span>
            </div>

            <!-- CHECKOUT -->

            <button
              type="button"
              :disabled="selectedItems.length === 0"
              class="mt-6 w-full rounded-full bg-orange-500 py-3.5 text-sm font-bold text-white transition hover:bg-orange-600 disabled:cursor-not-allowed disabled:bg-gray-300"
              @click="checkout"
            >
              Proceed to Checkout
            </button>

            <!-- SECURITY -->

            <div
              class="mt-5 flex items-center justify-center gap-2 text-xs text-gray-500"
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
                  d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v2h8z"
                />
              </svg>

              Secure checkout
            </div>

          </div>

          <!-- CONTINUE SHOPPING -->

          <router-link
            to="/products"
            class="mt-4 block text-center text-sm font-medium text-blue-700 hover:underline"
          >
            ← Continue Shopping
          </router-link>

        </aside>

      </div>

    </main>

  </div>
</template>
