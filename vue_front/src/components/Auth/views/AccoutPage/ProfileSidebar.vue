<script setup>
defineProps({
  user: { type: Object, required: true },
  userInitials: { type: String, default: 'U' },
  activeSection: { type: String, required: true },
  menuItems: { type: Array, required: true },
})

defineEmits(['select'])
</script>

<template>
  <aside class="h-fit rounded-2xl border border-gray-200 bg-white p-3">
    <div class="mb-4 border-b border-gray-100 px-3 py-4">
      <div class="flex items-center gap-3">
        <div class="flex h-12 w-12 items-center justify-center overflow-hidden rounded-full bg-gray-100">
          <img v-if="user.avatar" :src="user.avatar" :alt="user.name" class="h-full w-full object-cover" />
          <span v-else class="text-lg font-semibold text-gray-500">{{ userInitials }}</span>
        </div>
        <div class="min-w-0">
          <p class="truncate font-semibold text-gray-900">{{ user.name }}</p>
          <p class="truncate text-xs text-gray-500">{{ user.email }}</p>
        </div>
      </div>
    </div>

    <nav class="space-y-1">
      <button
        v-for="item in menuItems"
        :key="item.id"
        class="flex w-full items-center gap-3 rounded-xl px-3 py-3 text-sm font-medium transition"
        :class="activeSection === item.id ? 'bg-gray-900 text-white' : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'"
        @click="$emit('select', item.id)"
      >
        <span class="text-base">{{ item.icon }}</span>
        {{ item.label }}
      </button>
    </nav>

    <button class="mt-4 flex w-full items-center gap-3 rounded-xl px-3 py-3 text-sm font-medium text-red-600 hover:bg-red-50">
      <span>↪</span>
      Logout
    </button>
  </aside>
</template>
