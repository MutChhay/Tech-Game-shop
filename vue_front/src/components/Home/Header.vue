<template>
  <nav class="relative sticky top-0 z-50 w-full border-b border-black/5 bg-white/95 px-3 py-2.5 backdrop-blur-lg sm:px-6 lg:px-12">
    <div class="mx-auto flex max-w-7xl items-center justify-between">
      
      <router-link to="/" class="flex items-center group transition-transform active:scale-95">
        <h1 class="text-base font-black uppercase italic tracking-[0.08em] text-black sm:text-xl sm:tracking-[0.15em]">
          TechStore<span class="text-primary border-b-2 border-primary ml-1 group-hover:text-secondary group-hover:border-secondary transition-colors">Game</span>
        </h1>
      </router-link>

      <div class="hidden md:flex items-center space-x-8">
    <router-link to="/" class="link link-animated text-sm font-bold uppercase tracking-widest text-black/70 hover:text-black">
      {{$t('nav.home')}}
    </router-link>

    <div class="dropdown relative inline-flex [--placement:bottom-start]">
      <button 
        id="dropdown-products" 
        type="button" 
        class="dropdown-toggle text-sm font-bold uppercase tracking-widest text-black/70 hover:text-black flex items-center gap-1 transition-colors outline-none" 
        aria-haspopup="menu" 
        aria-expanded="false" 
        aria-label="Dropdown"
      >
        <span class="relative z-10 text-sm font-bold uppercase tracking-widest text-black/80 group-hover:text-white transition-colors flex items-center gap-2">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"/>
              </svg>
              {{$t('nav.products')}}
            </span>
      </button>

      <ul 
        class="dropdown-menu dropdown-open:opacity-100 hidden min-w-52 bg-neutral-900 border border-white/10 p-2 rounded-xl shadow-2xl z-[100]" 
        role="menu" 
        aria-orientation="vertical" 
        aria-labelledby="dropdown-products"
      >
        <li>
          <router-link to="/products/computers" class="dropdown-item text-white/70 hover:text-primary hover:bg-white/5 rounded-lg py-2">
            <span class="icon-[tabler--device-desktop] size-4 mr-2"></span> {{$t('nav.computers')}}
          </router-link>
        </li>
        <li>
          <router-link to="/products/laptops" class="dropdown-item text-white/70 hover:text-primary hover:bg-white/5 rounded-lg py-2">
            <span class="icon-[tabler--cpu] size-4 mr-2"></span> {{$t('nav.laptops')}}
          </router-link>
        </li>
        <li>
          <router-link to="/products/accessories" class="dropdown-item text-white/70 hover:text-primary hover:bg-white/5 rounded-lg py-2">
            <span class="icon-[tabler--keyboard] size-4 mr-2"></span> {{$t('nav.accessories')}}
          </router-link>
        </li>
        <li>
          <router-link to="/products/audio" class="dropdown-item text-white/70 hover:text-primary hover:bg-white/5 rounded-lg py-2">
            <span class="icon-[tabler--keyboard] size-4 mr-2"></span> {{$t('nav.audio')}}
          </router-link>
        </li>
        <li>
          <router-link to="/products/speakers" class="dropdown-item text-white/70 hover:text-primary hover:bg-white/5 rounded-lg py-2">
            <span class="icon-[tabler--keyboard] size-4 mr-2"></span> {{$t('nav.speakers')}}
          </router-link>
        </li>
        <li>
          <router-link to="/products/headphones" class="dropdown-item text-white/70 hover:text-primary hover:bg-white/5 rounded-lg py-2">
            <span class="icon-[tabler--keyboard] size-4 mr-2"></span> {{$t('nav.headphones')}}
          </router-link>
        </li>

        <li>
          <router-link to="/products/networking" class="dropdown-item text-white/70 hover:text-primary hover:bg-white/5 rounded-lg py-2">
            <span class="icon-[tabler--keyboard] size-4 mr-2"></span> {{$t('nav.networking')}}
          </router-link>
        </li>
        <li>
          <router-link to="/products/storage" class="dropdown-item text-white/70 hover:text-primary hover:bg-white/5 rounded-lg py-2">
            <span class="icon-[tabler--keyboard] size-4 mr-2"></span> {{$t('nav.storage')}}
          </router-link>
        </li>
        <div class="divider my-1 opacity-10"></div>
        <li>
          <router-link to="/products/all" class="dropdown-item text-xs font-bold uppercase tracking-widest text-primary hover:bg-primary/10 rounded-lg">
            {{$t('nav.viewAllProducts')}}
          </router-link>
        </li>
      </ul>
    </div>

    <router-link to="/orders" class="link link-animated text-sm font-bold uppercase tracking-widest text-black/70 hover:text-black">
      {{$t('nav.ordersReturns')}}
    </router-link>
    <router-link to="/about" class="link link-animated text-sm font-bold uppercase tracking-widest text-black/70 hover:text-black">
      {{$t('nav.contact')}}
    </router-link>
  </div>

      <button
        type="button"
        class="inline-flex h-10 w-10 items-center justify-center rounded-lg border border-black/10 text-black md:hidden"
        aria-label="Toggle navigation"
        :aria-expanded="showMobileMenu"
        @click="showMobileMenu = !showMobileMenu"
      >
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
          <path v-if="!showMobileMenu" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 6l12 12M18 6L6 18" />
        </svg>
      </button>

      <div class="flex items-center gap-2 sm:gap-4">

      <router-link
        id="cart-link"
        to="/carts"
        aria-label="Open shopping cart"
        class="relative inline-flex"
      >
        <span class="text-xl cursor-pointer">🛒</span>
        <span
          v-if="cartStore.totalItems > 0"
          class="absolute -right-3 -top-2 flex h-5 min-w-5 items-center justify-center rounded-full bg-red-600 px-1 text-[11px] font-bold leading-none text-white"
        >
          {{ cartStore.totalItems }}
        </span>
      </router-link>


      <!-- Notication -->
      <router-link to="/notifications" 
        aria-label="Open notifications" 
        class="relative inline-flex">
      <svg class="w-6 h-6 text-gray-800 text-xl cursor-pointer text-black/100" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24">
        <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5.365V3m0 2.365a5.338 5.338 0 0 1 5.133 5.368v1.8c0 2.386 1.867 2.982 1.867 4.175 0 .593 0 1.193-.538 1.193H5.538c-.538 0-.538-.6-.538-1.193 0-1.193 1.867-1.789 1.867-4.175v-1.8A5.338 5.338 0 0 1 12 5.365Zm-8.134 5.368a8.458 8.458 0 0 1 2.252-5.714m14.016 5.714a8.458 8.458 0 0 0-2.252-5.714M8.54 17.901a3.48 3.48 0 0 0 6.92 0H8.54Z"/>
      </svg>
      </router-link>
          
      <!-- ================================================= -->
        <!-- LOGIN / PROFILE -->
        <!-- ================================================= -->

        <div class="relative">


          <!-- ==================== LOGIN ==================== -->
          <button
            v-if="!auth.isLoggedIn"
            @click="emit('open-login')"
              class="group relative rounded-xl px-2 py-2 text-xs font-bold uppercase tracking-widest overflow-hidden transition-all duration-300 hover:scale-105 active:scale-95 sm:px-6 sm:py-3 sm:text-sm"
          >

            <div
              class="absolute inset-0 bg-gradient-to-r from-primary via-secondary to-primary animate-gradient-xy"
            ></div>

            <div
              class="absolute inset-0 bg-gradient-to-r from-primary to-secondary opacity-90 group-hover:opacity-100 transition-opacity"
            ></div>

            <span
              class="relative z-10 text-black flex items-center gap-2"
            >

              <!-- Login Icon -->
              <svg
                class="w-4 h-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"
                />
              </svg>

              {{$t('nav.login')}}

            </span>
          </button>


          <!-- ==================== PROFILE ==================== -->
          <div v-else>

            <!-- Profile Button -->
            <button
              @click="showProfileMenu = !showProfileMenu"
              type="button"
              class="flex items-center gap-2 rounded-full transition-all duration-300 hover:scale-105"
            >

              <!-- Profile Image -->
              <img
                :src="auth.user?.avatar || defaultAvatar"
                :alt="auth.user?.name || 'User'"
                class="h-10 w-10 rounded-full object-cover border-2 border-primary shadow-lg"
              />


              <!-- User Name -->
              <span
                class="hidden lg:block text-sm font-semibold text-black/80 group-hover:text-black transition-colors truncate max-w-[6rem]"
              >
                {{ auth.user?.name || 'User' }}
              </span>


              <!-- Arrow -->
              <svg
                class="hidden lg:block h-4 w-4 text-black transition-transform"
                :class="{ 'rotate-180': showProfileMenu }"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="m19 9-7 7-7-7"
                />
              </svg>

            </button>


            <!-- ==================== PROFILE DROPDOWN ==================== -->
            <div
              v-if="showProfileMenu"
              class="absolute right-0 top-14 z-[200] w-64 overflow-hidden rounded-xl border border-white/10 bg-neutral-900 shadow-2xl"
            >

              <!-- User Information -->
              <div
                class="border-b border-white/10 px-4 py-4"
              >

                <div class="flex items-center gap-3">

                  <img
                    :src="auth.user?.avatar || defaultAvatar"
                    :alt="auth.user?.name || 'User'"
                    class="h-11 w-11 rounded-full object-cover border border-primary"
                  />

                  <div class="min-w-0">

                    <p
                      class="truncate font-bold text-white"
                    >
                      {{ auth.user?.name || 'User' }}
                    </p>

                    <p
                      class="truncate text-xs text-white/50"
                    >
                      {{ auth.user?.email || '' }}
                    </p>

                  </div>

                </div>

              </div>


              <!-- Menu -->
              <div class="p-2">


                <!-- My Profile -->
                <router-link
                  to="/profile"
                  @click="showProfileMenu = false"
                  class="flex items-center gap-3 rounded-lg px-4 py-3 text-sm text-white/70 transition hover:bg-white/5 hover:text-white"
                >

                  <svg
                    class="h-5 w-5"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.5 20.25a8.25 8.25 0 0 1 15 0"
                    />
                  </svg>

                  {{$t('nav.myProfile')}}

                </router-link>


                <!-- My Data -->
                <router-link
                  to="/account"
                  @click="showProfileMenu = false"
                  class="flex items-center gap-3 rounded-lg px-4 py-3 text-sm text-white/70 transition hover:bg-white/5 hover:text-white"
                >

                  <svg
                    class="h-5 w-5"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M3 5h18M3 12h18M3 19h18"
                    />
                  </svg>

                  {{$t('nav.myData')}}

                </router-link>


                <!-- Settings -->
                <router-link
                  to="/account"
                  @click="showProfileMenu = false"
                  class="flex items-center gap-3 rounded-lg px-4 py-3 text-sm text-white/70 transition hover:bg-white/5 hover:text-white"
                >

                  <svg
                    class="h-5 w-5"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M10.5 6h9.75M10.5 6a1.5 1.5 0 1 1-3 0m3 0a1.5 1.5 0 0 0-3 0M3.75 6H6M10.5 18h9.75M10.5 18a1.5 1.5 0 1 1-3 0m3 0a1.5 1.5 0 0 0-3 0M3.75 18H6M10.5 12h9.75M10.5 12a1.5 1.5 0 1 1-3 0m3 0a1.5 1.5 0 1 0-3 0M3.75 12H6"
                    />
                  </svg>

                  {{$t('nav.settings')}}

                </router-link>


                <!-- Divider -->
                <div
                  class="my-2 border-t border-white/10"
                ></div>


                <!-- Logout -->
                <button
                  @click="logout"
                  class="flex w-full items-center gap-3 rounded-lg px-4 py-3 text-sm text-red-400 transition hover:bg-red-500/10 hover:text-red-300"
                >

                  <svg
                    class="h-5 w-5"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M9 15 3 9m0 0 6-6M3 9h12a6 6 0 0 1 0 12h-3"
                    />
                  </svg>

                  {{$t('nav.logout')}}

                </button>

              </div>

            </div>

          </div>

        </div>
              <select v-model="locale" class="w-12 text-xs sm:w-auto sm:text-sm">
                <option value="en">English</option>
                <option value="km">ខ្មែរ</option>
              </select>
      
       </div>
       
       </div>  

      <div
        v-if="showMobileMenu"
        class="absolute inset-x-4 top-full z-[100] rounded-b-xl border border-t-0 border-black/10 bg-white p-3 shadow-xl md:hidden sm:inset-x-6"
      >
        <router-link to="/" class="block rounded-lg px-3 py-3 text-sm font-bold uppercase tracking-widest text-black/70" @click="showMobileMenu = false">
          {{ $t('nav.home') }}
        </router-link>
        <router-link to="/products/all" class="block rounded-lg px-3 py-3 text-sm font-bold uppercase tracking-widest text-black/70" @click="showMobileMenu = false">
          {{ $t('nav.products') }}
        </router-link>
        <router-link to="/orders" class="block rounded-lg px-3 py-3 text-sm font-bold uppercase tracking-widest text-black/70" @click="showMobileMenu = false">
          {{ $t('nav.ordersReturns') }}
        </router-link>
        <router-link to="/about" class="block rounded-lg px-3 py-3 text-sm font-bold uppercase tracking-widest text-black/70" @click="showMobileMenu = false">
          {{ $t('nav.contact') }}
        </router-link>
      </div>

    </nav>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useAuthStore } from '../../Store/Auth'
import { useCartStore } from '../../Store/carts.js'
import { IStaticMethods } from 'flyonui/flyonui'

import { useI18n } from 'vue-i18n'

const { locale } = useI18n()

watch(locale, (value) => {
  if (value) {
    localStorage.setItem('language', value)
  }
}, { immediate: true })

/*
|--------------------------------------------------------------------------
| Auth Store
|--------------------------------------------------------------------------
*/

const auth = useAuthStore()
const cartStore = useCartStore()


/*
|--------------------------------------------------------------------------
| Emits
|--------------------------------------------------------------------------
*/

const emit = defineEmits(['open-login'])


/*
|--------------------------------------------------------------------------
| Profile Dropdown
|--------------------------------------------------------------------------
*/

const showProfileMenu = ref(false)


/*
|--------------------------------------------------------------------------
| Default Profile Image
|--------------------------------------------------------------------------
*/

const defaultAvatar =
  'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80&w=200'


/*
|--------------------------------------------------------------------------
| Logout
|--------------------------------------------------------------------------
*/

const logout = () => {

  auth.logout()

  showProfileMenu.value = false

}


const showProducts = ref(false)
const showMobileMenu = ref(false)
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



