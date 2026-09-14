<script setup>
import { ShoppingCart, ArrowUpRight } from 'lucide-vue-next';
import { RouterLink } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { useCartStore } from '../stores/cart';

defineProps({ product: { type: Object, required: true } });
const emit = defineEmits(['notify']);
const auth = useAuthStore();
const cart = useCartStore();
async function add(product) {
    if (!auth.isAuthenticated) return emit('notify', 'Sign in to add items to your cart.');
    try { await cart.add(product); emit('notify', `${product.name} added to cart.`); } catch (error) { emit('notify', error.response?.data?.message || 'Could not add this item.'); }
}
</script>
<template>
    <article class="product-card">
        <RouterLink :to="`/products/${product.id}`" class="product-image"><img v-if="product.image_url" :src="product.image_url" :alt="product.name"><div v-else class="image-placeholder">N</div><span v-if="product.stock === 0" class="stock-pill out">Out of stock</span><span v-else class="stock-pill">In stock</span></RouterLink>
        <div class="product-card-body"><p class="eyebrow">{{ product.category_name || 'Hardware' }}</p><RouterLink :to="`/products/${product.id}`" class="product-name">{{ product.name }}</RouterLink><div class="product-meta"><strong>${{ Number(product.price).toLocaleString() }}</strong><button :disabled="!product.stock" class="icon-action" title="Add to cart" @click="add(product)"><ShoppingCart :size="17" /></button></div></div>
    </article>
</template>
