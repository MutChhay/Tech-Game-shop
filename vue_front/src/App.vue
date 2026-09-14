<template>
  <headerbanner />
  <Header @open-login="showLogin = true" />

  <templateModel :isOpen="showLogin" @close="showLogin = false" />
  <router-view />
  
  <Footer />

</template>

<script setup>
import { onMounted, ref } from 'vue'
import Header from "./components/Home/Header.vue";
import templateModel from "./models/templateModel.vue";
import headerbanner from "./components/Home/header_banner.vue";
import { useCartStore } from './Store/carts.js'
import Footer from "./components/Home/footer.vue";
import profile from "./components/Auth/views/Profile.vue";
const showLogin = ref(false)
const cartStore = useCartStore()

onMounted(() => {
  cartStore.fetchCart()
})


</script>