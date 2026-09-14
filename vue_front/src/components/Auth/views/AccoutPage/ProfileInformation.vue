<script setup>
import { computed, ref, onMounted } from 'vue'
import { useAuthStore } from '../../../../Store/Auth.js'
import apiClient from '../../../../services/api.js'

const auth = useAuthStore()

const editing = ref(false)
const isSaving = ref(false)
const isLoading = ref(false)

const user = ref({
  name: '',
  email: '',
  phone: '',
  country: '',
  avatar: '',
})

/*
|--------------------------------------------------------------------------
| User initials
|--------------------------------------------------------------------------
*/
const userInitials = computed(() => {
  if (!user.value.name) return '?'

  return user.value.name
    .split(' ')
    .map(word => word.charAt(0))
    .join('')
    .substring(0, 2)
    .toUpperCase()
})

/*
|--------------------------------------------------------------------------
| Stats
|--------------------------------------------------------------------------
| Change these later to real values from your API.
|--------------------------------------------------------------------------
*/
const stats = computed(() => [
  {
    label: 'Orders',
    value: auth.user?.orders_count ?? 0,
  },
  {
    label: 'Addresses',
    value: auth.user?.addresses_count ?? 0,
  },
  {
    label: 'Payments',
    value: auth.user?.payments_count ?? 0,
  },
])

/*
|--------------------------------------------------------------------------
| Load user from Auth store
|--------------------------------------------------------------------------
*/
const loadUser = () => {
  if (!auth.user) return

  user.value = {
    name: auth.user.name ?? '',
    email: auth.user.email ?? '',
    phone: auth.user.phone ?? '',
    country: auth.user.country ?? '',
    avatar: auth.user.avatar ?? '',
  }
}

/*
|--------------------------------------------------------------------------
| Get latest user from Laravel
|--------------------------------------------------------------------------
*/
const fetchUser = async () => {
  isLoading.value = true

  try {
    const response = await apiClient.get('/user')

    const userData = response.data.user ?? response.data

    // Update local form
    user.value = {
      name: userData.name ?? '',
      email: userData.email ?? '',
      phone: userData.phone ?? '',
      country: userData.country ?? '',
      avatar: userData.avatar ?? '',
    }

    // Update Pinia Auth store
    auth.setUser(userData)
  } catch (error) {
    console.error('Failed to load user:', error)
  } finally {
    isLoading.value = false
  }
}

/*
|--------------------------------------------------------------------------
| Edit / Cancel
|--------------------------------------------------------------------------
*/
const toggleEdit = () => {
  if (editing.value) {
    // Cancel changes
    loadUser()
  }

  editing.value = !editing.value
}

/*
|--------------------------------------------------------------------------
| Save profile
|--------------------------------------------------------------------------
*/
const saveProfile = async () => {
  isSaving.value = true

  try {
    const response = await apiClient.put('/user', {
      name: user.value.name,
      email: user.value.email,
      phone: user.value.phone,
      country: user.value.country,
    })

    const updatedUser = response.data.user ?? response.data

    // Update local data
    user.value = {
      name: updatedUser.name ?? '',
      email: updatedUser.email ?? '',
      phone: updatedUser.phone ?? '',
      country: updatedUser.country ?? '',
      avatar: updatedUser.avatar ?? '',
    }

    // IMPORTANT:
    // Update Pinia state too
    auth.setUser(updatedUser)

    editing.value = false

    console.log('Profile updated successfully')
  } catch (error) {
    console.error('Failed to update profile:', error)

    if (error.response?.data?.message) {
      alert(error.response.data.message)
    } else {
      alert('Failed to update profile.')
    }
  } finally {
    isSaving.value = false
  }
}

/*
|--------------------------------------------------------------------------
| Load when component opens
|--------------------------------------------------------------------------
*/
onMounted(() => {
  if (auth.user) {
    loadUser()
  } else {
    fetchUser()
  }
})
</script>

<template>
  <section class="space-y-6">

    <!-- Profile Card -->
    <div class="rounded-2xl border border-gray-200 bg-white p-6">

      <!-- Header -->
      <div class="mb-6 flex items-center justify-between">

        <div>
          <h2 class="text-lg font-semibold text-gray-900">
            Profile Information
          </h2>

          <p class="text-sm text-gray-500">
            Update your personal information.
          </p>
        </div>

        <button
          type="button"
          class="rounded-lg border border-gray-200 px-4 py-2 text-sm font-medium hover:bg-gray-50"
          @click="toggleEdit"
        >
          {{ editing ? 'Cancel' : 'Edit Profile' }}
        </button>

      </div>

      <!-- Loading -->
      <div
        v-if="isLoading"
        class="py-10 text-center text-sm text-gray-500"
      >
        Loading profile...
      </div>

      <template v-else>

        <!-- Avatar -->
        <div class="mb-8 flex items-center gap-5">

          <div
            class="flex h-24 w-24 items-center justify-center overflow-hidden rounded-full bg-gray-100"
          >
            <img
              v-if="user.avatar"
              :src="user.avatar"
              :alt="user.name"
              class="h-full w-full object-cover"
            />

            <span
              v-else
              class="text-3xl font-semibold text-gray-400"
            >
              {{ userInitials }}
            </span>
          </div>

          <div>

            <button
              type="button"
              :disabled="!editing"
              class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50"
            >
              Change Avatar
            </button>

            <p class="mt-2 text-xs text-gray-400">
              JPG, PNG. Maximum 2MB.
            </p>

          </div>

        </div>

        <!-- Form -->
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">

          <!-- Name -->
          <label>
            <span class="mb-2 block text-sm font-medium text-gray-700">
              Full Name
            </span>

            <input
              v-model="user.name"
              type="text"
              :disabled="!editing"
              class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm outline-none transition focus:border-gray-900 disabled:bg-gray-50 disabled:text-gray-500"
            />
          </label>

          <!-- Email -->
          <label>
            <span class="mb-2 block text-sm font-medium text-gray-700">
              Email
            </span>

            <input
              v-model="user.email"
              type="email"
              :disabled="!editing"
              class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm outline-none transition focus:border-gray-900 disabled:bg-gray-50 disabled:text-gray-500"
            />
          </label>

          <!-- Phone -->
          <label>
            <span class="mb-2 block text-sm font-medium text-gray-700">
              Phone
            </span>

            <input
              v-model="user.phone"
              type="text"
              :disabled="!editing"
              class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm outline-none transition focus:border-gray-900 disabled:bg-gray-50 disabled:text-gray-500"
            />
          </label>

          <!-- Country -->
          <label>
            <span class="mb-2 block text-sm font-medium text-gray-700">
              Country
            </span>

            <input
              v-model="user.country"
              type="text"
              :disabled="!editing"
              class="w-full rounded-xl border border-gray-200 px-4 py-3 text-sm outline-none transition focus:border-gray-900 disabled:bg-gray-50 disabled:text-gray-500"
            />
          </label>

        </div>

        <!-- Save -->
        <div
          v-if="editing"
          class="mt-6 flex justify-end"
        >

          <button
            type="button"
            :disabled="isSaving"
            class="rounded-xl bg-gray-900 px-5 py-3 text-sm font-medium text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
            @click="saveProfile"
          >
            {{ isSaving ? 'Saving...' : 'Save Changes' }}
          </button>

        </div>

      </template>

    </div>

    <!-- Stats -->
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">

      <div
        v-for="stat in stats"
        :key="stat.label"
        class="rounded-2xl border border-gray-200 bg-white p-5"
      >

        <p class="text-sm text-gray-500">
          {{ stat.label }}
        </p>

        <p class="mt-2 text-2xl font-bold text-gray-900">
          {{ stat.value }}
        </p>

      </div>

    </div>

  </section>
</template>

