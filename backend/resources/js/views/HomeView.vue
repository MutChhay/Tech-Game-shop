<script setup>
import { onMounted, ref } from 'vue';
import { ArrowRight, Cpu, ShieldCheck, Truck } from 'lucide-vue-next';
import { RouterLink } from 'vue-router';
import { productService } from '../services/productService';
import ProductCard from '../components/ProductCard.vue';

const products = ref([]); const categories = ref([]); const loading = ref(true); const error = ref(''); const emit = defineEmits(['notify']);
onMounted(async () => { try { const [productsResponse, categoriesResponse] = await Promise.all([productService.list(), productService.categories()]); products.value = productsResponse.data; categories.value = categoriesResponse.data; } catch { error.value = 'We could not load the store right now.'; } finally { loading.value = false; } });
</script>
<template>
    <section class="hero"><div class="container hero-grid"><div class="hero-copy"><p class="kicker">NEXUS HARDWARE / 2026 EDITION</p><h1>Power your next <em>great thing.</em></h1><p class="hero-lede">Curated computers and components for deep work, high frame rates, and everything in between.</p><RouterLink class="button button-dark" to="/products">Explore the collection <ArrowRight :size="17" /></RouterLink></div><div class="hero-visual"><div class="hero-orbit orbit-one"></div><div class="hero-orbit orbit-two"></div><div class="hero-chip"><Cpu :size="88" stroke-width="1" /><span>BUILD<br>WITHOUT<br>LIMITS</span></div></div></div></section>
    <section class="trust-strip"><div class="container trust-grid"><div><Truck :size="20" /><span><b>Fast, reliable delivery</b><small>Tracked to your door</small></span></div><div><ShieldCheck :size="20" /><span><b>Hardware you can trust</b><small>Selected for quality</small></span></div><div><Cpu :size="20" /><span><b>Ready for your workflow</b><small>Specs that make sense</small></span></div></div></section>
    <section class="section container"><div class="section-heading"><div><p class="kicker">THE SHORTLIST</p><h2>Featured hardware</h2></div><RouterLink class="text-link" to="/products">View all <ArrowRight :size="16" /></RouterLink></div><div v-if="loading" class="product-grid"><div v-for="n in 4" :key="n" class="skeleton-card"></div></div><p v-else-if="error" class="state error-state">{{ error }}</p><div v-else class="product-grid"><ProductCard v-for="product in products.slice(0, 4)" :key="product.id" :product="product" @notify="emit('notify', $event)" /></div></section>
    <section class="category-band"><div class="container"><div class="section-heading"><div><p class="kicker">BROWSE BY NEED</p><h2>Find your setup</h2></div></div><div class="category-grid"><RouterLink v-for="category in categories" :key="category.id" class="category-tile" :to="{ path: '/products', query: { category: category.id } }"><span>{{ category.name }}</span><ArrowRight :size="18" /></RouterLink><RouterLink v-if="!categories.length" class="category-tile" to="/products"><span>All hardware</span><ArrowRight :size="18" /></RouterLink></div></div></section>
</template>
