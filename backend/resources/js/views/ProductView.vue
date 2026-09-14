<script setup>
import { computed, onMounted, ref } from 'vue';
import { ArrowLeft, Minus, Plus, ShoppingCart, Truck } from 'lucide-vue-next';
import { RouterLink, useRoute, useRouter } from 'vue-router';
import { productService } from '../services/productService';
import { useAuthStore } from '../stores/auth';
import { useCartStore } from '../stores/cart';

const route = useRoute();
const router = useRouter();
const auth = useAuthStore();
const cart = useCartStore();
const product = ref(null);
const loading = ref(true);
const quantity = ref(1);
const activeImage = ref(0);
const error = ref('');
const emit = defineEmits(['notify']);

const images = computed(() => product.value?.images?.length ? product.value.images : (product.value?.image_url ? [product.value.image_url] : []));
const specs = computed(() => [['CPU', product.value?.cpu], ['RAM', product.value?.ram], ['Storage', product.value?.storage], ['GPU', product.value?.gpu], ['Display', product.value?.display], ['Battery', product.value?.battery], ['Warranty', product.value?.warranty]].filter(([, value]) => value));

async function add(goCheckout = false) {
    if (!auth.isAuthenticated) return router.push({ path: '/login', query: { redirect: route.fullPath } });
    try { await cart.add(product.value, quantity.value); emit('notify', 'Added to your cart.'); if (goCheckout) router.push('/checkout'); }
    catch (requestError) { emit('notify', requestError.response?.data?.message || 'Could not add this item.'); }
}

onMounted(async () => { try { product.value = (await productService.get(route.params.id)).data; } catch { error.value = 'This product could not be found.'; } finally { loading.value = false; } });
</script>

<template>
    <section class="container detail-page">
        <RouterLink class="back-link" to="/products"><ArrowLeft :size="16" /> Back to collection</RouterLink>
        <div v-if="loading" class="detail-skeleton"></div>
        <div v-else-if="error" class="state error-state">{{ error }}</div>
        <div v-else class="detail-grid">
            <div><div class="detail-image"><img v-if="images.length" :key="images[activeImage]" :src="images[activeImage]" :alt="`${product.name} image ${activeImage + 1}`"><div v-else class="image-placeholder">N</div></div><div v-if="images.length > 1" class="gallery-thumbs"><button v-for="(image, index) in images" :key="image" :class="{ active: index === activeImage }" @click="activeImage = index"><img :src="image" :alt="`${product.name} thumbnail ${index + 1}`"></button></div></div>
            <div class="detail-copy"><p class="kicker">{{ product.category_name || 'HARDWARE' }}</p><h1>{{ product.name }}</h1><div class="detail-price">${{ Number(product.price).toLocaleString() }}</div><p class="detail-description">{{ product.description || 'A considered piece of hardware, selected for dependable everyday performance.' }}</p><div class="stock-line"><span :class="product.stock ? 'dot-green' : 'dot-red'"></span>{{ product.stock ? `${product.stock} available now` : 'Currently out of stock' }}</div><div class="buy-row"><div class="quantity"><button :disabled="quantity <= 1" @click="quantity--"><Minus :size="15" /></button><span>{{ quantity }}</span><button :disabled="quantity >= product.stock" @click="quantity++"><Plus :size="15" /></button></div><button class="button button-dark" :disabled="!product.stock" @click="add()"><ShoppingCart :size="17" /> Add to cart</button><button class="button button-accent" :disabled="!product.stock" @click="add(true)">Buy now</button></div><div class="detail-note"><Truck :size="18" /><span>Reliable delivery, with tracking from dispatch to your door.</span></div><div v-if="specs.length" class="specs"><h3>Specifications</h3><div v-for="[label, value] in specs" :key="label" class="spec-row"><span>{{ label }}</span><strong>{{ value }}</strong></div></div></div>
        </div>
    </section>
</template>
