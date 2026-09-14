<script setup>
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useCartStore } from '../../Store/carts.js'
import { useOrderStore } from '../../Store/orders.js'
import CheckoutAddress from '../checkout/CheckoutAddress.vue'
import CheckoutItems from '../checkout/CheckoutItems.vue'
import CheckoutPayment from '../checkout/CheckoutPayment.vue'
import CheckoutSummary from '../checkout/CheckoutSummary.vue'

const route = useRoute()
const router = useRouter()
const cartStore = useCartStore()
const orderStore = useOrderStore()

const form = ref({
    name: '',
    email: '',
    phone: '',
    address: '',
    city: '',
    postalCode: '',
    paymentMethod: 'cash_on_delivery',
})
const completedOrder = ref(null)

const selectedIds = computed(() => {
    const queryIds = String(route.query.items || '')
        .split(',')
        .filter(Boolean)

    return queryIds.length
        ? queryIds.map(id => String(id))
        : cartStore.items.map(item => String(item.id))
})

const checkoutItems = computed(() => cartStore.items.filter(item =>
    selectedIds.value.includes(String(item.id))
))

const subtotal = computed(() => checkoutItems.value.reduce(
    (total, item) => total + Number(item.price) * Number(item.quantity),
    0,
))

async function placeOrder() {
    if (!checkoutItems.value.length || orderStore.isLoading) return

  const orderedItems = checkoutItems.value.map(item => ({
    id: item.id,
    quantity: item.quantity,
  }))

    try {
        const order = await orderStore.createOrder({
      items: orderedItems.map(item => ({
                product_id: item.id,
                quantity: item.quantity,
            })),
            name: form.value.name,
            email: form.value.email,
            phone: form.value.phone,
            address: form.value.address,
            city: form.value.city,
            postal_code: form.value.postalCode,
            payment_method: form.value.paymentMethod,
        })

        await cartStore.removeItemsFromCart(
          orderedItems.map(item => item.id)
        )
        completedOrder.value = order
        const orderId = order.order_number || order.orderNumber || order.id
        if (orderId) {
          router.push(`/orders/${orderId}/success`)
        }
    } catch (requestError) {
        console.error('Checkout failed:', requestError)
    }
}
</script>

<template>
  <main class="min-h-screen bg-gray-50 px-4 py-8 text-gray-900 sm:px-6 lg:px-8">
    <div class="mx-auto max-w-6xl">
      <div v-if="completedOrder" class="checkout-success mx-auto max-w-xl rounded-2xl border border-emerald-100 bg-white px-6 py-14 text-center shadow-sm">
        <div class="success-mark mx-auto flex h-20 w-20 items-center justify-center rounded-full bg-emerald-100 text-4xl text-emerald-600">✓</div>
        <h1 class="mt-6 text-2xl font-bold">Order placed successfully</h1>
        <p class="mt-2 text-sm text-gray-500">Thank you. Your order is being prepared.</p>
        <p v-if="completedOrder.id" class="mt-3 text-sm font-semibold text-gray-800">Order #{{ completedOrder.id }}</p>
        <button type="button" class="mt-8 rounded-full bg-gray-900 px-7 py-3 text-sm font-semibold text-white transition hover:bg-gray-800" @click="router.push('/products')">Continue shopping</button>
      </div>

      <template v-else>
        <button type="button" class="mb-6 text-sm font-semibold text-gray-600 hover:text-gray-900" @click="router.back()">← Back to cart</button>
        <h1 class="text-3xl font-bold">Checkout</h1>
        <p class="mt-2 text-sm text-gray-500">Complete your details to place the order.</p>

        <div v-if="!checkoutItems.length" class="mt-8 rounded-xl border border-gray-200 bg-white p-8 text-center shadow-sm">
          <p class="text-gray-600">There are no items ready for checkout.</p>
          <button type="button" class="mt-5 font-semibold text-blue-700 hover:underline" @click="router.push('/carts')">Return to cart</button>
        </div>

        <form v-else class="mt-8 grid gap-6 lg:grid-cols-[1fr_360px]" @submit.prevent="placeOrder">
          <div class="space-y-6">
            <CheckoutAddress v-model="form" />
            <CheckoutPayment v-model="form.paymentMethod" />
            <CheckoutItems :items="checkoutItems" />
          </div>
          <CheckoutSummary
            :items="checkoutItems"
            :subtotal="subtotal"
            :is-loading="orderStore.isLoading"
            :error="orderStore.error"
          />
        </form>
      </template>
    </div>
  </main>
</template>

<style scoped>
.checkout-success { animation: reveal 360ms ease-out both; }
.success-mark { animation: pop 420ms 100ms ease-out both; }

@keyframes reveal {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes pop {
  from { opacity: 0; transform: scale(0.6); }
  75% { transform: scale(1.08); }
  to { opacity: 1; transform: scale(1); }
}
</style>
