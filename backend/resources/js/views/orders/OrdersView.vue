<script setup>import { onMounted, ref } from 'vue';
import { ArrowRight, Package } from 'lucide-vue-next';
import { RouterLink } from 'vue-router';
import { orderService } from '../../services/orderService';
const orders = ref([]); const loading = ref(true); const error = ref('');
onMounted(async () => {
    try {
        orders.value = (await orderService.list()).data;


    } catch {
        error.value = 'Unable to load your orders.';


    } finally { loading.value = false; }
});

const date = (value) => new Date(value).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });

</script>
<template>


<section class="container page-section">
    <div class="section-heading"><div>
    <p class="kicker">YOUR ACCOUNT</p>
    <h1>My orders</h1></div></div><div v-if="loading" class="state">Loading orders...</div>

    <p v-else-if="error" class="state error-state">{{ error }}</p>

    <div v-else-if="!orders.length" class="state"><Package :size="32" />

    <h2>No orders yet.</h2><RouterLink class="text-link" to="/products">Start shopping <ArrowRight :size="16" />

    </RouterLink></div><div v-else class="orders-list">

        <RouterLink v-for="order in orders" :key="order.id" class="order-row" :to="`/orders/${order.id}`">

            <div class="order-preview"><img v-if="order.items?.[0]?.product?.image" :src="`/storage/${order.items[0].product.image}`" alt=""><div v-else class="cart-thumb">N</div>

            </div>

            <div>

                <span class="eyebrow">Order #{{ order.id }}</span>
                <strong>{{ date(order.created_at) }}</strong><small>{{ order.items?.length || 0 }} products</small>
                </div>
                <span class="status-badge" :class="`status-${order.status}`">{{ order.status }}</span>

                <strong>${{ Number(order.total_price).toLocaleString(undefined, { minimumFractionDigits: 2 }) }}</strong>
                <ArrowRight :size="17" /></RouterLink>

            </div>

        </section>
</template>
