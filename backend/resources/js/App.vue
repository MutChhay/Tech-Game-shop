<script setup>
import { computed, onMounted, ref } from 'vue';
import { RouterLink, RouterView, useRouter } from 'vue-router';
import { Menu, Search, ShoppingBag, UserRound, X } from 'lucide-vue-next';
import { useAuthStore } from './stores/auth';
import { useCartStore } from './stores/cart';

const auth = useAuthStore();
const cart = useCartStore();
const router = useRouter();
const menuOpen = ref(false);
const search = ref('');
const toast = ref('');
const toastTimer = ref();

const userLabel = computed(() => auth.user?.name?.split(' ')[0] || 'Account');

function submitSearch() {
    if (search.value.trim()) router.push({ path: '/products', query: { q: search.value.trim() } });
    menuOpen.value = false;
}
function notify(message) {
    toast.value = message;
    clearTimeout(toastTimer.value);
    toastTimer.value = setTimeout(() => { toast.value = ''; }, 2800);
}
async function logout() { await auth.logout(); cart.clear(); notify('You have been signed out.'); router.push('/'); }

onMounted(async () => {
    window.addEventListener('store:unauthorized', () => { auth.clear(); notify('Your session has expired.'); });
    await auth.hydrate();
    if (auth.isAuthenticated) await cart.fetch();
});
</script>

<template>
    <div class="app-shell">
        <header class="site-header">
            <div class="container nav-row">
                <RouterLink class="brand" to="/" @click="menuOpen = false"><span class="brand-mark">N</span><span>NEXUS<span class="brand-dot">.</span></span></RouterLink>
                <form class="search-box" @submit.prevent="submitSearch"><Search :size="17" /><input v-model="search" placeholder="Search laptops, GPUs, accessories..." aria-label="Search products"><button>Search</button></form>
                <nav class="desktop-nav">
                    <RouterLink to="/products">Shop</RouterLink>
                    <RouterLink v-if="auth.isAuthenticated" to="/orders">Orders</RouterLink>
                    <RouterLink v-if="auth.isAdmin" to="/admin">Admin</RouterLink>
                    <RouterLink v-if="!auth.isAuthenticated" to="/login" class="nav-account"><UserRound :size="17" /> Sign in</RouterLink>
                    <button v-else class="nav-account nav-button" @click="logout"><UserRound :size="17" /> Hi, {{ userLabel }}</button>
                    <RouterLink class="cart-link" to="/cart"><ShoppingBag :size="19" /><span v-if="cart.count" class="cart-count">{{ cart.count }}</span></RouterLink>
                </nav>
                <button class="mobile-menu-button" @click="menuOpen = !menuOpen" aria-label="Toggle menu"><X v-if="menuOpen" /><Menu v-else /></button>
            </div>
            <div v-if="menuOpen" class="mobile-nav container"><RouterLink to="/products" @click="menuOpen = false">Shop all</RouterLink><RouterLink v-if="auth.isAuthenticated" to="/orders" @click="menuOpen = false">My orders</RouterLink><RouterLink v-if="auth.isAdmin" to="/admin" @click="menuOpen = false">Admin</RouterLink><RouterLink to="/cart" @click="menuOpen = false">Cart ({{ cart.count }})</RouterLink></div>
        </header>
        <main><RouterView @notify="notify" /></main>
        <footer class="site-footer"><div class="container footer-row"><div><div class="brand footer-brand"><span class="brand-mark">N</span><span>NEXUS<span class="brand-dot">.</span></span></div><p>Hardware chosen for how you work, play, and create.</p></div><span>© {{ new Date().getFullYear() }} Nexus Hardware</span></div></footer>
        <Transition name="toast"><div v-if="toast" class="toast">{{ toast }}</div></Transition>
    </div>
</template>
