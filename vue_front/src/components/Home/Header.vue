<template>
  <nav class="sticky top-0 z-50 w-full border-b border-black/5 bg-black backdrop-blur-lg px-6 py-3 lg:px-12">
    <div class="mx-auto flex max-w-7xl items-center justify-between">
      
      <router-link to="/" class="flex items-center group transition-transform active:scale-95">
        <h1 class="text-xl font-black tracking-[0.15em] uppercase italic text-white">
          TechStore<span class="text-primary border-b-2 border-primary ml-1 group-hover:text-secondary group-hover:border-secondary transition-colors">Game</span>
        </h1>
      </router-link>

      <div class="hidden md:flex items-center space-x-8">
    <router-link to="/" class="link link-animated text-sm font-bold uppercase tracking-widest text-white/70 hover:text-white">
      Home
    </router-link>

    <div class="dropdown relative inline-flex [--placement:bottom-start]">
      <button 
        id="dropdown-products" 
        type="button" 
        class="dropdown-toggle text-sm font-bold uppercase tracking-widest text-white/70 hover:text-white flex items-center gap-1 transition-colors outline-none" 
        aria-haspopup="menu" 
        aria-expanded="false" 
        aria-label="Dropdown"
      >
        Products 
        <span class="icon-[tabler--chevron-down] dropdown-open:rotate-180 size-4 transition-transform"></span>
      </button>

      <ul 
        class="dropdown-menu dropdown-open:opacity-100 hidden min-w-52 bg-neutral-900 border border-white/10 p-2 rounded-xl shadow-2xl z-[100]" 
        role="menu" 
        aria-orientation="vertical" 
        aria-labelledby="dropdown-products"
      >
        <li>
          <router-link to="/products/gaming-pc" class="dropdown-item text-white/70 hover:text-primary hover:bg-white/5 rounded-lg py-2">
            <span class="icon-[tabler--device-desktop] size-4 mr-2"></span> Gaming PCs
          </router-link>
        </li>
        <li>
          <router-link to="/products/components" class="dropdown-item text-white/70 hover:text-primary hover:bg-white/5 rounded-lg py-2">
            <span class="icon-[tabler--cpu] size-4 mr-2"></span> Components
          </router-link>
        </li>
        <li>
          <router-link to="/products/peripherals" class="dropdown-item text-white/70 hover:text-primary hover:bg-white/5 rounded-lg py-2">
            <span class="icon-[tabler--keyboard] size-4 mr-2"></span> Peripherals
          </router-link>
        </li>
        <div class="divider my-1 opacity-10"></div>
        <li>
          <router-link to="/products/all" class="dropdown-item text-xs font-bold uppercase tracking-widest text-primary hover:bg-primary/10 rounded-lg">
            View All Products
          </router-link>
        </li>
      </ul>
    </div>

    <router-link to="/orders" class="link link-animated text-sm font-bold uppercase tracking-widest text-white/70 hover:text-white">
      Orders
    </router-link>
    <router-link to="/contact" class="link link-animated text-sm font-bold uppercase tracking-widest text-white/70 hover:text-white">
      Contact
    </router-link>
  </div>

       <div class="flex items-center gap-4">

      <span class="text-xl cursor-pointer">🛒</span>

      <svg class="w-6 h-6 text-gray-800 text-xl cursor-pointer text-white" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24">
        <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5.365V3m0 2.365a5.338 5.338 0 0 1 5.133 5.368v1.8c0 2.386 1.867 2.982 1.867 4.175 0 .593 0 1.193-.538 1.193H5.538c-.538 0-.538-.6-.538-1.193 0-1.193 1.867-1.789 1.867-4.175v-1.8A5.338 5.338 0 0 1 12 5.365Zm-8.134 5.368a8.458 8.458 0 0 1 2.252-5.714m14.016 5.714a8.458 8.458 0 0 0-2.252-5.714M8.54 17.901a3.48 3.48 0 0 0 6.92 0H8.54Z"/>
      </svg>


      

      <button @click="$emit('open-login')" class="btn btn-primary">

        Login

      </button>



    </div>
    </div>
  </nav>
</template>

<script setup>
defineEmits(['open-login'])

import { onMounted } from 'vue'
import { IStaticMethods } from 'flyonui/flyonui'

onMounted(() => {
  // Required to make FlyonUI dropdowns clickable in Vue
  IStaticMethods.autoInit()
})
</script>

<style scoped>
/* Optional: Custom animation for the underline if FlyonUI isn't already handling it */
.link-animated {
  position: relative;
  text-decoration: none;
}
.link-animated::after {
  content: '';
  position: absolute;
  width: 0;
  height: 2px;
  bottom: -4px;
  left: 0;
  background-color: var(--color-primary, #641ae6);
  transition: width 0.3s ease;
}
.link-animated:hover::after {
  width: 100%;
}
</style>