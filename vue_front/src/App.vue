<template>
  <Header @open-login="showLogin = true" />

  <templateModel :isOpen="showLogin" @close="showLogin = false" />

  <router-view />
</template>

<script setup>
import { ref } from 'vue'
import Header from "./components/Home/Header.vue";
import templateModel from "./models/templateModel.vue";

const showLogin = ref(false)
</script>