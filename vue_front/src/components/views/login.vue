<script setup>
import { ref } from "vue"
import api from "../../services/api"
import register from "./register.vue"
const email = ref("")
const password = ref("")
const isLoading = ref(false)

// 1. ADDED: This tracks if the password should be shown as text
const isPasswordVisible = ref(false)

const login = async () => {
  isLoading.value = true
  try {
    const res = await api.post("/login", {
      email: email.value,
      password: password.value
    })
    localStorage.setItem("token", res.data.token)
    alert("Login success")
  } catch (error) {
    alert("Login failed: " + (error.response?.data?.message || error.message))
  } finally {
    isLoading.value = false
  }
  
}
</script>

<template>
  <div class="w-full max-w-sm mx-auto">
    
    <div class="mb-10 flex flex-col items-center text-center">
      <div class="bg-primary/10 mb-4 flex size-14 items-center justify-center rounded-2xl">
        <img src="../../assets/images/logo.jpg" class="size-10 object-contain rounded-lg" />
      </div>
      <h2 class="text-base-content text-2xl font-extrabold">Tech Store Game</h2>
      <p class="text-base-content/60 mt-2 text-sm">
        Enter your credentials
      </p>
    </div>

    <form @submit.prevent="login" class="space-y-4">

      <!-- EMAIL -->
      <div>
        <label class="text-sm font-medium">Email</label>
        <input 
          v-model="email" 
          type="email" 
          placeholder="name@company.com" 
          class="input input-bordered w-full mt-1"
          required 
        />
      </div>

      <!-- PASSWORD -->
      <div>
        <label class="text-sm font-medium">Password</label>
        <div class="relative mt-1">
          <input 
            v-model="password" 
            :type="isPasswordVisible ? 'text' : 'password'" 
            class="input input-bordered w-full pr-10"
            placeholder="••••••••"
            required
          />
          <button
            type="button"
            @click="isPasswordVisible = !isPasswordVisible"
            class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500"
          >
            👁
          </button>
        </div>
      </div>

      <!-- OPTIONS -->
      <div class="flex justify-between text-xs">
        <label class="flex items-center gap-2">
          <input type="checkbox" class="checkbox checkbox-sm" />
          Remember me
        </label>
        <a href="#" class="text-primary">Forgot?</a>
      </div>

      <!-- BUTTON -->
      <button 
        type="submit" 
        :disabled="isLoading"
        class="btn btn-primary w-full h-11"
      >
        <span v-if="isLoading" class="loading loading-spinner"></span>
        Sign In
      </button>

    </form>

    <div class="divider text-xs my-6">Or</div>

    <button class="btn btn-outline w-full h-11 gap-2">
      <img
        src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/google-icon.png"
        class="size-4"
      />
      Google
    </button>

    <p class="text-center text-sm mt-6">
      Don't have an account?
            <button 
        type="button"
        @click="$emit('open-register')"
        class="text-primary font-medium ml-1"
      >
        Sign up now
      </button>
    </p>

  </div>
</template>