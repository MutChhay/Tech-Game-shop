<script setup>
import { onMounted, ref } from 'vue'
import { useAuthStore } from '../../../Store/Auth'
import Myorder from '../../orders/MyOrders.vue'
import AddressSection from './AccoutPage/AddressSection.vue'
import OrdersSection from './AccoutPage/OrdersSection.vue'
import PaymentsSection from './AccoutPage/PaymentsSection.vue'
import ProfileInformation from './AccoutPage/ProfileInformation.vue'
import ProfileSidebar from './AccoutPage/ProfileSidebar.vue'
import SettingsSection from './AccoutPage/SettingsSection.vue'

const auth = useAuthStore()
const activeSection = ref('profile')
const editingProfile = ref(false)
const isSavingProfile = ref(false)
const errorMessage = ref('')

const user = ref({ name: '', email: '', phone: '', country: '', avatar: '' })
const userInitials = ref('U')

const menuItems = [
  { id: 'profile', label: 'Profile', icon: '👤' },
  { id: 'addresses', label: 'My Addresses', icon: '📍' },
  { id: 'orders', label: 'My Orders', icon: '📦' },
  { id: 'payments', label: 'Payments & Spending', icon: '💳' },
  { id: 'settings', label: 'Settings', icon: '⚙️' },
]

const stats = [
  { label: 'Total Orders', value: '24' },
  { label: 'Completed Orders', value: '20' },
  { label: 'This Month', value: '$245' },
]

const setUser = (profile) => {
  user.value = {
    name: profile?.name || profile?.full_name || '',
    email: profile?.email || '',
    phone: profile?.phone || '',
    country: profile?.country || '',
    avatar: profile?.avatar || profile?.profile_photo_url || '',
  }
  userInitials.value = user.value.name.trim().charAt(0).toUpperCase() || 'U'
}

const loadProfile = async () => {
  try {
    const profile = auth.user || await auth.fetchUser()
    setUser(profile)
  } catch (error) {
    errorMessage.value = error.response && error.response.data && error.response.data.message || 'Failed to load your profile.'
  }
}

const saveProfile = async () => {
  isSavingProfile.value = true
  errorMessage.value = ''

  try {
    const profile = await auth.updateUser(user.value)
    setUser(profile)
    editingProfile.value = false
  } catch (error) {
    errorMessage.value = error.response && error.response.data && error.response.data.message || 'Failed to save your profile.'
  } finally {
    isSavingProfile.value = false
  }
}

onMounted(loadProfile)
</script>

<template>
  <div class="min-h-screen bg-gray-50 px-4 py-8 sm:px-6 lg:px-8">
    <div class="mx-auto max-w-7xl">
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900">My Account</h1>
        <p class="mt-1 text-sm text-gray-500">Manage your profile, addresses, orders, and account settings.</p>
      </div>

      <p v-if="errorMessage" class="mb-6 rounded-xl bg-red-50 px-4 py-3 text-sm text-red-700">{{ errorMessage }}</p>

      <div class="grid grid-cols-1 gap-6 lg:grid-cols-4">
        <ProfileSidebar
          :user="user"
          :user-initials="userInitials"
          :active-section="activeSection"
          :menu-items="menuItems"
          @select="activeSection = $event"
        />

        <main class="lg:col-span-3">
          <ProfileInformation
            v-if="activeSection === 'profile'"
            :user="user"
            :user-initials="userInitials"
            :editing="editingProfile"
            :is-saving="isSavingProfile"
            :stats="stats"
            @toggle-edit="editingProfile = !editingProfile"
            @save="saveProfile"
          />
          <AddressSection v-else-if="activeSection === 'addresses'" />
          <Myorder v-else-if="activeSection === 'orders'" />
          <PaymentsSection v-else-if="activeSection === 'payments'" />
          <SettingsSection v-else-if="activeSection === 'settings'" />
        </main>
      </div>
    </div>
  </div>
</template>
