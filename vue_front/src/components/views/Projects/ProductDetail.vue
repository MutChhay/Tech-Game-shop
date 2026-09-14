<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '../../../services/api'
import { useCartStore } from '../../../Store/carts.js'
import { flyImageToCart } from '../../../utils/flyToCart.js'
import ProductGallery from './components_details/ProductGallery.vue'
import ProductInfo from './components_details/ProductInfo.vue'
import PurchaseCard from '../Projects/cart/PurchaseCard.vue'
import ProductReviews from './components_details/ProductReviews.vue'
import RelatedProducts from './components_details/RelatedProducts.vue'

const route = useRoute()
const router = useRouter()

const product = ref(null)
const products = ref([])
const loading = ref(true)
const error = ref('')

const selectedImage = ref(0)
const selectedColor = ref('')
const selectedStyle = ref('')
const quantity = ref(1)

const specifications = [
  { key: 'cpu', label: 'CPU' },
  { key: 'ram', label: 'RAM' },
  { key: 'storage', label: 'Storage' },
  { key: 'gpu', label: 'GPU' },
  { key: 'display', label: 'Display' },
  { key: 'battery', label: 'Battery' },
  { key: 'warranty', label: 'Warranty' },
]

const colors = computed(() => {
  if (!product.value?.colors) return []

  if (Array.isArray(product.value.colors)) {
    return product.value.colors
  }

  return String(product.value.colors)
    .split(',')
    .map(color => color.trim())
    .filter(Boolean)
})

const styles = computed(() => {
  if (!product.value?.styles) return []

  if (Array.isArray(product.value.styles)) {
    return product.value.styles
  }

  return String(product.value.styles)
    .split(',')
    .map(style => style.trim())
    .filter(Boolean)
})

const formattedPrice = computed(() => {
  return Number(product.value?.price || 0).toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })
})

const relatedProducts = computed(() => {
  if (!product.value) return []

  return products.value
    .filter(item => String(item.id) !== String(product.value.id))
    .filter(item => {
      if (!product.value.category_id) return true

      return String(item.category_id) === String(product.value.category_id)
    })
    .slice(0, 4)
})

async function loadProduct() {
  loading.value = true
  error.value = ''
  product.value = null

  resetProductState()

  try {
    const response = await api.get('/products')

    const data = Array.isArray(response.data)
      ? response.data
      : response.data.data || []

    products.value = data

    product.value = data.find(
      item => String(item.id) === String(route.params.id)
    )

    if (!product.value) {
      error.value = 'We could not find that product.'
      return
    }

    selectedColor.value = colors.value[0] || ''
    selectedStyle.value = styles.value[0] || ''
  } catch (requestError) {
    console.error(requestError)

    error.value =
      requestError.response?.data?.message ||
      'Unable to load product details.'
  } finally {
    loading.value = false
  }
}

function resetProductState() {
  selectedImage.value = 0
  selectedColor.value = ''
  selectedStyle.value = ''
  quantity.value = 1
}

function increaseQuantity() {
  if (!product.value) return

  if (quantity.value < Number(product.value.stock)) {
    quantity.value++
  }
}

function decreaseQuantity() {
  if (quantity.value > 1) {
    quantity.value--
  }
}

async function addToCart(event) {
  if (!product.value) return

  const stock = Number(product.value.stock || 0)

  if (stock < 1) {
    console.log('Product is out of stock')
    return
  }

  const qty = Number(quantity.value || 1)

  if (!Number.isFinite(qty) || qty < 1) {
    console.error('Invalid quantity:', quantity.value)
    return
  }

  const cartItem = {
    id: product.value.id,
    name: product.value.name,
    price: Number(product.value.price || 0),
    image: product.value.image_url || product.value.image || null,
    quantity: qty,
    color: selectedColor.value || '',
    style: selectedStyle.value || '',
    stock: stock,
    category_name: product.value.category_name || '',
  }

  console.log('Add to cart:', cartItem)

  // Animate product image to cart
  if (cartItem.image) {
    flyImageToCart(
      cartItem.image,
      event?.currentTarget,
    )
  }

  // Get Pinia cart store
  const cartStore = useCartStore()

  // Add product to cart
  await cartStore.addToCart(cartItem, qty)


}

async function buyNow() {
  if (!product.value || Number(product.value.stock) < 1) return

  await addToCart()
  router.push('/checkout')
}



onMounted(loadProduct)

watch(
  () => route.params.id,
  loadProduct
)
</script>

<template>
  <main class="min-h-screen bg-white px-4 py-6 text-gray-900 sm:px-6 lg:px-8">
    <div class="mx-auto max-w-[1600px]">

      <!-- Back -->
      <button
        type="button"
        class="mb-6 inline-flex items-center gap-2 text-sm font-medium text-gray-600 hover:text-blue-700"
        @click="router.back()"
      >
        ←
        Back to products
      </button>

      <!-- Loading -->
      <div
        v-if="loading"
        class="grid gap-8 xl:grid-cols-[minmax(0,1fr)_minmax(420px,0.95fr)_310px]"
      >
        <div class="aspect-square animate-pulse rounded-xl bg-gray-100" />

        <div class="space-y-5">
          <div class="h-5 w-32 animate-pulse rounded bg-gray-100" />
          <div class="h-12 w-3/4 animate-pulse rounded bg-gray-100" />
          <div class="h-6 w-48 animate-pulse rounded bg-gray-100" />
          <div class="h-36 animate-pulse rounded bg-gray-100" />
        </div>

        <div class="h-[420px] animate-pulse rounded-xl bg-gray-100" />
      </div>

      <!-- Error -->
      <div
        v-else-if="error"
        class="rounded-2xl border border-red-200 bg-red-50 px-6 py-14 text-center"
      >
        <p class="text-red-600">
          {{ error }}
        </p>

        <button
          type="button"
          class="mt-5 text-sm font-bold text-blue-700 hover:underline"
          @click="router.push('/products')"
        >
          Browse all products
        </button>
      </div>

      <!-- Product -->
      <template v-else-if="product">

        <section
          class="grid gap-8 xl:grid-cols-[minmax(0,1fr)_minmax(420px,0.95fr)_310px]"
        >

          <ProductGallery
            :product="product"
            v-model:selected-image="selectedImage"
          />

          <ProductInfo
            :product="product"
            :specifications="specifications"
            :formatted-price="formattedPrice"
          />

          <PurchaseCard
            :product="product"
            :formatted-price="formattedPrice"
            v-model:quantity="quantity"
            v-model:selected-color="selectedColor"
            v-model:selected-style="selectedStyle"
            @increase="increaseQuantity"
            @decrease="decreaseQuantity"
            @add-to-cart="addToCart"
            @buy-now="buyNow"
          />

        </section>

        <ProductReviews
          :product="product"
        />

        <RelatedProducts
          :products="relatedProducts"
        />

      </template>

    </div>
  </main>
</template>
