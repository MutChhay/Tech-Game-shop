<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import loadingPages from '../../loadingPages/loading.vue'
import api from '../../services/api'

import { useI18n } from 'vue-i18n'

const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()

const products = ref([])
const loading = ref(true)
const error = ref('')
const searchQuery = ref('')

const categoryNames = {
  'computers': 'Computers',
  'laptops': 'Laptops',
  'accessories': 'Accessories',
  'audio': 'Audio',
  'speakers': 'Speakers',
  'headphones': 'Headphones',
  'networking': 'Networking',
  'storage': 'Storage',
  'components': 'Components',

}


/*
|--------------------------------------------------------------------------
| Page title
|--------------------------------------------------------------------------
*/

const pageTitle = computed(() => {
  return categoryNames[route.params.category] || 'All Products'
})

/*
|--------------------------------------------------------------------------
| Is this the "All Products" page?
|--------------------------------------------------------------------------
*/

const isAllProducts = computed(() => {
  return !route.params.category || route.params.category === 'all'
})

const categoryOptions = computed(() => [
  { value: 'all', label: t('nav.viewAllProducts') },
  ...Object.entries(categoryNames).map(([value, label]) => ({
    value,
    label: t(`Products.categories.${value}`),
  })),
])

const selectedCategory = computed(() => route.params.category || 'all')

/*
|--------------------------------------------------------------------------
| Format price
|--------------------------------------------------------------------------
*/

function formatPrice(price) {
  return Number(price || 0).toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })
}

/*
|--------------------------------------------------------------------------
| Group products by category
|--------------------------------------------------------------------------
*/

const filteredProducts = computed(() => {
  const query = searchQuery.value.trim().toLowerCase()

  if (!query) return products.value

  return products.value.filter((product) => {
    return [product.name, product.category_name, product.description]
      .filter(Boolean)
      .some((value) => String(value).toLowerCase().includes(query))
  })
})

const groupedProducts = computed(() => {
  const groups = {}

  filteredProducts.value.forEach((product) => {
    const category = product.category_name || 'Other'

    if (!groups[category]) {
      groups[category] = []
    }

    groups[category].push({
      ...product,
      formattedPrice: formatPrice(product.price),
    })
  })

  return groups
})

function changeCategory(category) {
  router.push({
    name: 'Products',
    params: { category },
  })
}

function clearFilters() {
  searchQuery.value = ''
  changeCategory('all')
}

/*
|--------------------------------------------------------------------------
| Products to display
|--------------------------------------------------------------------------
|
| On /products/all:
| Show only 10 products per category.
|
| On /products/laptops:
| Show ALL laptop products.
|
*/

function displayedProducts(categoryProducts) {
  if (isAllProducts.value) {
    return categoryProducts.slice(0, 10)
  }

  return categoryProducts
}

/*
|--------------------------------------------------------------------------
| Check if category has more than 10 products
|--------------------------------------------------------------------------
*/

function hasMoreProducts(categoryProducts) {
  return isAllProducts.value && categoryProducts.length > 10
}

/*
|--------------------------------------------------------------------------
| Get route for View More
|--------------------------------------------------------------------------
*/

function getCategoryRoute(categoryName) {
  const entry = Object.entries(categoryNames).find(
    ([, name]) => name === categoryName
  )

  return entry
    ? {
        name: 'Products',
        params: {
          category: entry[0],
        },
      }
    : {
        name: 'Products',
        params: {
          category: 'all',
        },
      }
}

/*
|--------------------------------------------------------------------------
| Load products
|--------------------------------------------------------------------------
*/

async function loadProducts() {
  loading.value = true
  error.value = ''

  try {
    const response = await api.get('/products')

    const data = Array.isArray(response.data)
      ? response.data
      : response.data.data || []

    const routeCategory = route.params.category

    /*
     * ALL PRODUCTS
     *
     * /products/all
     */
    if (!routeCategory || routeCategory === 'all') {
      products.value = data
    }

    /*
     * SPECIFIC CATEGORY
     *
     * /products/laptops
     * /products/computer
     * etc.
     */
    else if (categoryNames[routeCategory]) {
      const selectedCategory = categoryNames[routeCategory]

      products.value = data.filter(
        (product) =>
          product.category_name === selectedCategory
      )
    }

    /*
     * Unknown category
     */
    else {
      products.value = []
    }

  } catch (requestError) {
    console.error(requestError)

    error.value =
      requestError.response?.data?.message ||
      'Unable to load products.'
  } finally {
    loading.value = false
  }
}

/*
|--------------------------------------------------------------------------
| Initial load
|--------------------------------------------------------------------------
*/

onMounted(() => {
  loadProducts()
})

/*
|--------------------------------------------------------------------------
| Reload when route changes
|--------------------------------------------------------------------------
*/

watch(
  () => route.params.category,
  () => {
    loadProducts()
  }
)
</script>

<template>
  <main
    class="min-h-screen bg-gray-50 px-6 py-8 text-gray-900 sm:px-8 lg:px-10"
  >
    <div class="mx-auto max-w-7xl">

      <!-- ===================================================== -->
      <!-- PAGE HEADER -->
      <!-- ===================================================== -->

      <div
        class="mb-10 flex flex-wrap items-end justify-between gap-5"
      >
        <div>

          <h1
            class="text-3xl font-bold uppercase tracking-[0.22em] text-blue-600"
          >
            {{t('Products.OurP')}}
          </h1>

        

        </div>

        <!-- Total count -->
        <span
          v-if="!loading"
          class="rounded-full bg-white px-4 py-2 text-sm font-medium text-gray-600 shadow-sm ring-1 ring-gray-200"
        >
          {{ filteredProducts.length }} {{t('Products.AllP')}}
      
        </span>

      </div>


      <div class="grid gap-8 lg:grid-cols-[276px_minmax(0,1fr)] lg:items-start">

        <!-- ===================================================== -->
        <!-- FILTER SIDEBAR -->
        <!-- ===================================================== -->

        <aside class="border-b border-gray-200 pb-6 lg:sticky lg:top-24 lg:border-b-0 lg:pb-0">
          <div class="flex items-center gap-3 border-b border-gray-200 pb-5">
            <svg class="h-5 w-5 text-gray-900" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M7 12h10M10 18h4" />
            </svg>
            <h2 class="text-base font-bold text-gray-900"> {{t('Products.Filter')}}</h2>
          </div>

          <label class="mt-7 block text-sm font-semibold text-gray-600" for="product-search">
            {{t('Products.Search')}}
          </label>
          <div class="relative mt-3">
            <input
              id="product-search"
              v-model="searchQuery"
              type="search"
              :placeholder="t('Products.SearchP')"
              class="h-14 w-full rounded-md border border-gray-200 bg-white px-4 pr-11 text-sm text-gray-900 outline-none transition placeholder:text-gray-400 focus:border-gray-900 focus:ring-1 focus:ring-gray-900"
            />
            <svg class="pointer-events-none absolute right-4 top-1/2 h-5 w-5 -translate-y-1/2 text-gray-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
              <circle cx="11" cy="11" r="7" />
              <path stroke-linecap="round" d="m20 20-4-4" />
            </svg>
          </div>

          <label class="mt-6 block text-sm font-semibold text-gray-600" for="product-category">
            {{t('nav.products')}}
          </label>
          <div class="relative mt-3">
            <select
              id="product-category"
              :value="selectedCategory"
              class="h-14 w-full appearance-none rounded-md border border-gray-200 bg-white px-4 pr-10 text-sm text-gray-900 outline-none transition focus:border-gray-900 focus:ring-1 focus:ring-gray-900"
              @change="changeCategory($event.target.value)"
            >
              <option
                v-for="category in categoryOptions"
                :key="category.value"
                :value="category.value"
              >
                {{ category.label }}
              </option>
            </select>
            <svg class="pointer-events-none absolute right-4 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-900" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" d="m6 9 6 6 6-6" />
            </svg>
          </div>

          <button
            v-if="searchQuery || selectedCategory !== 'all'"
            type="button"
            class="mt-5 text-sm font-semibold text-blue-600 hover:text-blue-800 hover:underline"
            @click="clearFilters"
          >
             {{ t('Products.clearFilters') }}
          </button>
        </aside>

        <div class="min-w-0">

          <!-- ===================================================== -->
          <!-- LOADING -->
          <!-- ===================================================== -->

          <div
        v-if="loading"
        class="flex min-h-[400px] items-center justify-center"
      >
        <loadingPages />
      </div>


      <!-- ===================================================== -->
      <!-- ERROR -->
      <!-- ===================================================== -->

      <div
        v-else-if="error"
        class="rounded-2xl border border-red-200 bg-red-50 p-8 text-center"
      >

        <div
          class="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-red-100"
        >
          ⚠️
        </div>

        <p
          class="mt-4 text-sm font-semibold text-red-600"
        >
          {{ error }}
        </p>

      </div>


      <!-- ===================================================== -->
      <!-- EMPTY -->
      <!-- ===================================================== -->

          <div
        v-else-if="filteredProducts.length === 0"
        class="rounded-2xl border border-dashed border-gray-300 bg-white p-12 text-center"
      >

        <div
          class="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-gray-100 text-2xl"
        >
          📦
        </div>

        <p
          class="mt-4 text-lg font-semibold text-gray-900"
        >
          No products found
        </p>

        <p
          class="mt-2 text-sm text-gray-500"
        >
           {{ t('Products.tryAnotherCategory') }}
        </p>

      </div>


      <!-- ===================================================== -->
      <!-- CATEGORY SECTIONS -->
      <!-- ===================================================== -->

          <div
        v-else
        class="space-y-14"
      >

        <section
          v-for="(categoryProducts, categoryName) in groupedProducts"
          :key="categoryName"
        >

          <!-- ================================================= -->
          <!-- CATEGORY HEADER -->
          <!-- ================================================= -->

          <div
            class="mb-6 flex items-end justify-between gap-4"
          >

            <div>

              <div
                class="flex items-center gap-3"
              >

                <div
                  class="h-7 w-1 rounded-full bg-blue-600"
                ></div>

                <h2
                  class="text-2xl font-bold tracking-tight text-gray-900"
                >
                  {{ categoryName }}
                </h2>

              </div>

               <p class="mt-2 text-sm text-gray-500">
                    {{ t('Products.exploreCollection') }} {{ categoryName.toLowerCase() }}.
                  </p>
            </div>


            <!-- all Group Products -->
             <router-link
              :to="getCategoryRoute(categoryName)"
              class="group inline-flex items-center gap-2 rounded-xl border border-gray-200 bg-white px-6 py-3 text-sm font-semibold text-gray-700 shadow-sm transition hover:border-blue-600 hover:bg-blue-600 hover:text-white hover:shadow-md"
            >

               {{ t('Products.viewMore') }}
              
              

            </router-link>

          </div>


          <!-- ================================================= -->
          <!-- PRODUCT GRID -->
          <!-- ================================================= -->

          <div
            class="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5"
          >

            <router-link
              v-for="product in displayedProducts(categoryProducts)"
              :key="product.id"
              :to="{
                name: 'ProductDetail',
                params: {
                  id: product.id
                }
              }"
              class="group flex min-w-0 flex-col overflow-hidden rounded-xl border border-gray-200 bg-white transition duration-200 hover:-translate-y-1 hover:border-gray-300 hover:shadow-lg"
            >

              <!-- =========================================== -->
              <!-- IMAGE -->
              <!-- =========================================== -->

              <div
                class="relative aspect-square overflow-hidden bg-gray-50"
              >

                <img
                  v-if="product.image_url"
                  :src="product.image_url"
                  :alt="product.name"
                  loading="lazy"
                  class="h-full w-full object-contain p-4 transition duration-300 group-hover:scale-105"
                />

                <div
                  v-else
                  class="flex h-full items-center justify-center text-sm text-gray-400"
                >
                  No image
                </div>


                <!-- Stock -->
                <span
                  class="absolute left-3 top-3 rounded-full px-2.5 py-1 text-[10px] font-bold"
                  :class="
                    Number(product.stock) > 0
                      ? 'bg-emerald-100 text-emerald-700'
                      : 'bg-red-100 text-red-700'
                  "
                >
                  {{
                    Number(product.stock) > 0
                      ? 'In Stock'
                      : 'Out of Stock'
                  }}
                </span>

              </div>


              <!-- =========================================== -->
              <!-- INFORMATION -->
              <!-- =========================================== -->

              <div
                class="flex flex-1 flex-col p-4"
              >

                <!-- Category -->
                <p
                  class="truncate text-[10px] font-bold uppercase tracking-wider text-blue-600"
                >
                  {{ product.category_name || t('Products.other') }}
                </p>


                <!-- Name -->
                <h2
                  class="mt-2 line-clamp-2 min-h-10 text-sm font-semibold leading-5 text-gray-900"
                >
                  {{ product.name }}
                </h2>


                <!-- Rating -->
                <div
                  class="mt-2 flex items-center gap-1.5"
                >

                  <span
                    class="text-xs tracking-wide text-yellow-500"
                  >
                    ★★★★<span class="text-gray-300">★</span>
                  </span>

                  <span
                    class="text-[11px] text-gray-400"
                  >
                    {{ product.rating || '4.3' }}
                  </span>

                </div>


                <!-- Price -->
                <div
                  class="mt-4 flex items-end justify-between gap-2"
                >

                  <div>

                    <p
                      class="text-[10px] font-medium uppercase tracking-wide text-gray-400"
                    >
                      Price
                    </p>

                    <p
                      class="mt-1 text-base font-bold text-gray-900"
                    >
                      ${{ product.formattedPrice }}
                    </p>

                  </div>


                  <!-- View -->
                  <span
                    class="rounded-md bg-blue-50 px-2 py-1 text-[10px] font-bold text-blue-700 transition group-hover:bg-blue-600 group-hover:text-white"
                  >
                    View
                  </span>

                </div>

              </div>

            </router-link>

          </div>


          <!-- ================================================= -->
          <!-- VIEW MORE -->
          <!-- ================================================= -->

          <div
            v-if="hasMoreProducts(categoryProducts)"
            class="mt-6 flex justify-center"
          >

           

          </div>

        </section>

          </div>

        </div>

      </div>

    </div>
  </main>
</template>