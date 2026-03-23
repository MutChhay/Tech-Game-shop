<script setup>
import { ref, computed } from "vue"
import api from "../../services/api"

const emit = defineEmits(['open-login'])

// Form state
const name = ref("")
const email = ref("")
const password = ref("")
const confirmPassword = ref("")
const isLoading = ref(false)

// UI state
const isPasswordVisible = ref(false)
const isConfirmVisible = ref(false)

// Check password match
const passwordsMatch = computed(() => {
  return password.value === confirmPassword.value || confirmPassword.value === ""
})

// Register function
const register = async () => {
  if (password.value !== confirmPassword.value) {
    alert("Passwords do not match!")
    return
  }

  isLoading.value = true
  try {
    const res = await api.post("/register", {
      name: name.value,
      email: email.value,
      password: password.value
    })

    localStorage.setItem("token", res.data.token)
    alert("Register success")

    // 👉 switch back to login after success
    emit('open-login')

  } catch (error) {
    alert("Register failed: " + (error.response?.data?.message || error.message))
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
   <div class="w-full max-w-sm mx-auto">
      <div class=" flex flex-col items-center text-center">
          <div class="bg-primary/10 mb-4 flex size-14 items-center justify-center rounded-2xl">
             <img src="../../assets/images/logo.jpg" class="size-10 object-contain rounded-lg" alt="logo" />
          </div>
    </div>
    <!-- HEADER -->
    <div class="mb-6 text-center">
      <h2 class="text-xl font-bold">Register</h2>
      <p class="text-sm text-gray-500">Create your account</p>
    </div>

    <!-- FORM -->
    <form @submit.prevent="register" class="space-y-4">

      <!-- NAME -->
      <div>
        <label class="text-sm font-medium">Name</label>
        <input 
          v-model="name" 
          type="text" 
          placeholder="Your name"
          class="input input-bordered w-full mt-1"
          required
        />
      </div>

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
            placeholder="••••••••"
            class="input input-bordered w-full pr-10"
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

      <!-- CONFIRM PASSWORD -->
      <div>
        <label class="text-sm font-medium">Confirm Password</label>
        <div class="relative mt-1">
          <input 
            v-model="confirmPassword"
            :type="isConfirmVisible ? 'text' : 'password'"
            placeholder="••••••••"
            class="input input-bordered w-full pr-10"
            required
          />
          <button 
            type="button"
            @click="isConfirmVisible = !isConfirmVisible"
            class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500"
          >
            👁
          </button>
        </div>

        <!-- ERROR -->
        <p v-if="!passwordsMatch" class="text-red-500 text-xs mt-1">
          Passwords do not match
        </p>
      </div>

      <!-- TERMS -->
      <div class="flex items-center gap-2 text-sm">
        <input type="checkbox" class="checkbox checkbox-sm" required />
        <label class="label-text text-base-content/80 p-0 text-base" for="policyagreement"> I agree to <a href="#" class="link link-animated link-primary font-normal">privacy policy & terms?</a> </label>
      </div>

      <!-- BUTTON -->
      <button 
        type="submit"
        :disabled="isLoading || !passwordsMatch"
        class="btn btn-primary w-full h-11"
      >
        <span v-if="isLoading" class="loading loading-spinner"></span>
        Register
      </button>

    </form>

    <!-- SWITCH TO LOGIN -->
    <p class="text-center text-sm mt-6">
      Already have an account?
      <button 
        type="button"
        @click="$emit('open-login')"
        class="text-primary ml-1 font-medium"
      >
        Login
      </button>
    </p>

          
          <!-- <div class="divider">or</div> -->

          <!-- button sign with an icon -->

          <!-- <div class="flex flex-col gap-3">
              <button type="button" class="btn btn-outline btn-block border-base-content/10 hover:bg-base-content/5 h-12 gap-3 transition-all"">
                <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/google-icon.png" alt="google" class="size-5 object-cover" />
                Sign in with google
              </button>
              <button type="button" class="btn btn-outline btn-block border-base-content/10 hover:bg-base-content/5 h-12 gap-3 transition-all"">
                <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/facebook-icon.png" alt="facebook" class="size-5 object-cover" />
                Sign in with facebook
              </button>
              <button type="button" class="btn btn-outline btn-block border-base-content/10 hover:bg-base-content/5 h-12 gap-3 transition-all"">
                <img src="https://cdn.flyonui.com/fy-assets/blocks/marketing-ui/brand-logo/twitter-icon.png" alt="twitter" class="size-5 object-cover" />
                Sign in with Twitter
              </button>
        </div> -->

        
        </div>
</template>