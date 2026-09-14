<script setup>
import { ref } from "vue"
import api from "../../services/api.js"
import { useAuthStore } from "../../Store/Auth.js"
import { useCartStore } from "../../Store/carts.js"

import { useI18n } from 'vue-i18n'

const { t, locale } = useI18n()
const cartStore = useCartStore()
const emit = defineEmits(['open-register', 'login-success'])
const auth = useAuthStore()
const email = ref("")
const password = ref("")
const isLoading = ref(false)
const isPasswordVisible = ref(false)
const errorMessage = ref("")

const login = async () => {
  isLoading.value = true
  errorMessage.value = ""

  try {
    const res = await api.post("/login", {
      email: email.value,
      password: password.value
    })

    auth.login(res.data.token, res.data.user || res.data.data?.user || null)
    await cartStore.fetchCart()
    alert("Login success")
    emit('login-success')
  } catch (error) {
    errorMessage.value = error.response?.data?.message || "Your email or password is incorrect."
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <div class="w-full max-w-sm mx-auto text-base-content">
    <div class="mb-8 flex flex-col items-center text-center">
      <div class="mb-4 flex size-16 items-center justify-center rounded-2xl bg-primary/10 ring-8 ring-primary/5">
        <img src="../../assets/images/logo.jpg" class="size-11 rounded-xl object-cover" alt="Tech Store Game logo" />
      </div>
      <p class="mb-1 text-xs font-bold uppercase tracking-[0.2em] text-primary">{{ t('home.backWE') }}</p>
      <h2 class="text-2xl font-black tracking-tight">{{ t('login.Sign_in') }}</h2>
      <p class="mt-2 text-sm text-base-content/60">{{ t('login.Content') }}</p>
    </div>

    <form @submit.prevent="login" class="space-y-5">
      <div>
        <label for="login-email" class="mb-2 block text-sm font-semibold">{{ t('login.Email') }}</label>
        <div class="relative">
          <svg class="pointer-events-none absolute left-4 top-1/2 size-5 -translate-y-1/2 text-base-content/40" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25H4.5a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0l-7.5-4.615a2.25 2.25 0 0 1-1.07-1.916V6.75" />
          </svg>
          <input id="login-email" v-model="email" type="email" placeholder="you@example.com" class="input input-bordered w-full pl-12" required autocomplete="email" />
        </div>
      </div>

      <div>
        <div class="mb-2 flex items-center justify-between">
          <label for="login-password" class="text-sm font-semibold">{{ t('login.Password') }}</label>
          <a href="#" class="text-xs font-semibold text-primary hover:underline">{{ t('login.ForgotP') }}</a>
        </div>
        <div class="relative">
          <svg class="pointer-events-none absolute left-4 top-1/2 size-5 -translate-y-1/2 text-base-content/40" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M16.5 10.5V6.75a4.5 4.5 0 0 0-9 0v3.75m-.75 0h10.5A2.25 2.25 0 0 1 19.5 12.75v6A2.25 2.25 0 0 1 17.25 21h-10.5a2.25 2.25 0 0 1-2.25-2.25v-6A2.25 2.25 0 0 1 6.75 10.5Z" />
          </svg>
          <input id="login-password" v-model="password" :type="isPasswordVisible ? 'text' : 'password'" class="input input-bordered w-full pl-12 pr-12" placeholder="Enter your password" required autocomplete="current-password" />
          <button
            type="button"
            @click="isPasswordVisible = !isPasswordVisible"
            class="absolute right-3 top-1/2 -translate-y-1/2 rounded-lg p-1 text-base-content/50 transition hover:bg-base-content/5 hover:text-primary"
            :aria-label="isPasswordVisible ? 'Hide password' : 'Show password'"
          >
            <svg v-if="!isPasswordVisible" class="size-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M2.25 12s3.5-6 9.75-6 9.75 6 9.75 6-3.5 6-9.75 6-9.75-6-9.75-6Z" /><circle cx="12" cy="12" r="2.5" stroke-width="1.8" /></svg>
            <svg v-else class="size-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="m3 3 18 18M10.58 10.58a2 2 0 0 0 2.83 2.83M9.88 5.09A10.8 10.8 0 0 1 12 4.9c6.25 0 9.75 6 9.75 6a17.7 17.7 0 0 1-3.04 3.75M6.23 6.23C3.7 7.92 2.25 10.9 2.25 10.9s3.5 6 9.75 6c1.1 0 2.12-.18 3.03-.49" /></svg>
          </button>
        </div>
      </div>

      <label class="flex items-center gap-2 text-xs text-base-content/60">
        <input type="checkbox" class="checkbox checkbox-sm checkbox-primary" />
          {{ t('login.Remember') }}
      </label>

      <div v-if="errorMessage" role="alert" class="rounded-xl border border-error/20 bg-error/10 px-4 py-3 text-sm text-error">
        {{ $t("login.errorMessage") }}
      </div>

      <button type="submit" :disabled="isLoading" class="btn btn-primary h-12 w-full rounded-xl text-sm font-bold shadow-lg shadow-primary/20 transition hover:-translate-y-0.5 hover:shadow-primary/30">
        <span v-if="isLoading" class="loading loading-spinner loading-sm"></span>
        {{ isLoading ? 'Signing in...' : t('nav.login') }}
      </button>
    </form>

    <div class="divider my-6 text-xs text-base-content/40">{{ t('login.Or') }}</div>

    <button type="button" class="btn btn-outline h-11 w-full gap-2 rounded-xl border-base-content/15 bg-base-100 font-semibold hover:border-primary hover:bg-primary/5">
      <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/google-icon.png" class="size-4" alt="Google" />
      {{ t('login.google') }}
    </button>

     <!-- Don't have an account  -->
    <p class="mt-7 text-center text-sm text-base-content/60">
      {{ t('login.NOAC') }}
      <button type="button" @click="emit('open-register')" class="ml-1 font-bold text-primary hover:underline">
        {{ t('login.SignUP') }}
      </button>
    </p>

  </div>
</template>


