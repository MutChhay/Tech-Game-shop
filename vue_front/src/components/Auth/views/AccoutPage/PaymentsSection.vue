<script setup>
const spending = [
  { month: 'September', amount: '245', percent: 82 },
  { month: 'August', amount: '180', percent: 60 },
  { month: 'July', amount: '290', percent: 96 },
  { month: 'June', amount: '150', percent: 50 },
]
</script>

<template>
  <section class="space-y-6">
    <div class="rounded-2xl border border-gray-200 bg-white p-6">
      <div class="mb-6">
        <h2 class="text-lg font-semibold text-gray-900">Monthly Spending</h2>
        <p class="text-sm text-gray-500">Your spending overview for this month.</p>
      </div>
      <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <div v-for="stat in [{ label: 'This Month', value: '$245.00' }, { label: 'Total Orders', value: '8' }, { label: 'Average Order', value: '$30.62' }]" :key="stat.label" class="rounded-xl bg-gray-50 p-5">
          <p class="text-sm text-gray-500">{{ stat.label }}</p>
          <p class="mt-2 text-2xl font-bold text-gray-900">{{ stat.value }}</p>
        </div>
      </div>
    </div>
    <div class="rounded-2xl border border-gray-200 bg-white p-6">
      <h3 class="font-semibold text-gray-900">Spending History</h3>
      <div class="mt-6 space-y-5">
        <div v-for="month in spending" :key="month.month">
          <div class="mb-2 flex justify-between text-sm"><span class="text-gray-600">{{ month.month }}</span><span class="font-medium text-gray-900">${{ month.amount }}</span></div>
          <div class="h-2 overflow-hidden rounded-full bg-gray-100"><div class="h-full rounded-full bg-gray-900" :style="{ width: month.percent + '%' }"></div></div>
        </div>
      </div>
    </div>
  </section>
</template>
