<template>
  <div class="min-h-screen bg-white">
    <!-- Hero -->
    <section class="bg-neutral-950 px-6 py-20 text-white lg:px-12">
      <div class="mx-auto max-w-7xl">
        <div class="max-w-3xl">
          <p class="mb-4 text-sm font-semibold uppercase tracking-widest text-neutral-400">
            {{ t('Footer.About') }}
          </p>

          <h1 class="text-4xl font-bold tracking-tight sm:text-5xl lg:text-6xl">
            {{ t('AboutUS.Techno') }}
            <span class="text-neutral-400">{{ t('AboutUS.simple') }}</span>
          </h1>

          <p class="mt-6 max-w-2xl text-lg leading-8 text-neutral-300">
           {{ t('AboutUS.content1') }}
          </p>
        </div>
      </div>
    </section>

    <!-- About -->
    <section class="px-6 py-20 lg:px-12">
      <div class="mx-auto grid max-w-7xl gap-16 lg:grid-cols-2 lg:items-center">
        <div>
          <p class="mb-3 text-sm font-semibold uppercase tracking-widest text-neutral-500">
            {{ t('AboutUS.who') }}
          </p>

          <h2 class="text-3xl font-bold text-neutral-900 sm:text-4xl">
            {{ t('AboutUS.trusted') }}
          </h2>

          <p class="mt-6 leading-7 text-neutral-600">
            {{ t('AboutUS.Content2') }}
          </p>

          <p class="mt-4 leading-7 text-neutral-600">
           {{ t('AboutUS.Content3') }}
          </p>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div
            v-for="item in stats"
            :key="item.label"
            class="rounded-2xl bg-neutral-100 p-6"
          >
            <div class="text-3xl font-bold text-neutral-900">
              {{ item.value }}
            </div>

            <div class="mt-2 text-sm text-neutral-500">
              {{ item.label }}
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Values -->
    <section class="bg-neutral-50 px-6 py-20 lg:px-12">
      <div class="mx-auto max-w-7xl">
        <div class="max-w-2xl">
          <p class="mb-3 text-sm font-semibold uppercase tracking-widest text-neutral-500">
            {{ t('AboutUS.value.T1') }}
          </p>

          <h2 class="text-3xl font-bold text-neutral-900 sm:text-4xl">
            {{ t('AboutUS.value.T2') }}
          </h2>
        </div>

        <div class="mt-12 grid gap-6 md:grid-cols-3">
          <div
            v-for="value in values"
            :key="value.title"
            class="rounded-2xl border border-neutral-200 bg-white p-8"
          >
            <!-- Icon -->
            <div
              class="flex h-12 w-12 items-center justify-center rounded-xl bg-neutral-900 text-lg text-white"
            >
              <span aria-hidden="true">{{ value.icon }}</span>
            </div>

            <h3 class="mt-6 text-xl font-semibold text-neutral-900">
              {{ value.title }}
            </h3>

            <p class="mt-3 leading-7 text-neutral-600">
              {{ value.description }}
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Mission -->
    <section class="px-6 py-20 lg:px-12">
      <div class="mx-auto max-w-4xl text-center">
        <p class="text-sm font-semibold uppercase tracking-widest text-neutral-500">
          {{ t('AboutUS.Mission.P1') }}
        </p>

        <h2 class="mt-4 text-3xl font-bold text-neutral-900 sm:text-4xl">
          {{ t('AboutUS.Mission.Content1') }}
        </h2>

        <p class="mx-auto mt-6 max-w-2xl leading-8 text-neutral-600">
            {{ t('AboutUS.Mission.content2') }}
        </p>  
      </div>
    </section>

    <!-- CTA -->
    <section class="bg-neutral-950 px-6 py-16 text-white lg:px-12">
      <div
        class="mx-auto flex max-w-7xl flex-col items-start justify-between gap-8 md:flex-row md:items-center"
      >
        <div>
          <h2 class="text-2xl font-bold sm:text-3xl">
            {{ t('AboutUS.CTA.P1') }}
          </h2>

          <p class="mt-2 text-neutral-400">
            {{ t('AboutUS.CTA.Content1') }}
          </p>
        </div>

        <RouterLink
          to="/products"
          class="rounded-xl bg-white px-6 py-3 font-semibold text-neutral-900 transition hover:bg-neutral-200"
        >
          {{ t('home.shopNow') }}
        </RouterLink>
      </div>
    </section>
  </div>
</template>

<script setup>


import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const stats = [
  {
    value: '100+',
    label: t('AboutUS.Technology'),
  },
  {
    value: '24/7',
    label: t('AboutUS.onlineS'),
  },
  {
    value: '100%',
    label: t('AboutUS.CustomerF'),
  },
  {
    value: '1',
    label: t('AboutUS.Experience'),
  },
]

const values = [
  {
    icon: '✓',
    number: '01',
    title: t('AboutUS.Quality'),
    description:
      t('AboutUS.description1')
  },
  {
    icon: '⚡',
    number: '02',
    title: t('AboutUS.Simplicity'),
    description:
      t('AboutUS.description2'),
  },
  {
    icon: '❤',
    number: '03',
    title: t('AboutUS.Customers'),
    description:
      t('AboutUS.description3'),
  },
]
</script>