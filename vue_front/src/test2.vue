<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import Chart from 'chart.js/auto'

const sidebarOpen = ref(false)
const selectedRange = ref('6m')

const revenueRanges = {
  '6m': {
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    values: [28000, 34000, 31000, 39000, 42000, 48000]
  },
  '12m': {
    labels: [
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'
    ],
    values: [
      19000, 21500, 20000, 23500, 25000, 27000,
      28000, 34000, 31000, 39000, 42000, 48000
    ]
  }
}

const orders = [
  {
    customer: 'Nandor the Relentless',
    order: '#3921',
    status: 'Paid',
    amount: '$412.00'
  },
  {
    customer: 'Laszlo Cravensworth',
    order: '#3920',
    status: 'Pending',
    amount: '$128.50'
  },
  {
    customer: 'Nadja',
    order: '#3919',
    status: 'Paid',
    amount: '$894.20'
  },
  {
    customer: 'Guillermo de la Cruz',
    order: '#3918',
    status: 'Refunded',
    amount: '$56.00'
  }
]

let revenueTrendChart = null

function changeRevenueRange(range) {
  selectedRange.value = range

  if (!revenueTrendChart) return

  revenueTrendChart.data.labels = revenueRanges[range].labels
  revenueTrendChart.data.datasets[0].data = revenueRanges[range].values
  revenueTrendChart.update()
}

function statusClass(status) {
  if (status === 'Paid') {
    return 'bg-green-100 text-green-700'
  }

  if (status === 'Pending') {
    return 'bg-yellow-100 text-yellow-700'
  }

  return 'bg-red-100 text-red-700'
}

onMounted(() => {
  // Revenue Sparkline
  const sparklineCanvas = document.getElementById(
    'revenue-trend-sparkline'
  )

  if (sparklineCanvas) {
    new Chart(sparklineCanvas, {
      type: 'line',
      data: {
        labels: revenueRanges['6m'].labels,
        datasets: [
          {
            data: revenueRanges['6m'].values,
            borderColor: '#10b981',
            borderWidth: 2,
            pointRadius: 0,
            tension: 0.35,
            fill: false
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            enabled: false
          }
        },
        scales: {
          x: {
            display: false
          },
          y: {
            display: false
          }
        }
      }
    })
  }

  // Revenue Line Chart
  const revenueCanvas = document.getElementById(
    'revenue-trend-line-chart'
  )

  if (revenueCanvas) {
    const context = revenueCanvas.getContext('2d')

    const gradient = context.createLinearGradient(
      0,
      0,
      0,
      256
    )

    gradient.addColorStop(
      0,
      'rgba(79, 70, 229, 0.25)'
    )

    gradient.addColorStop(
      1,
      'rgba(79, 70, 229, 0)'
    )

    revenueTrendChart = new Chart(revenueCanvas, {
      type: 'line',

      data: {
        labels: revenueRanges['6m'].labels,

        datasets: [
          {
            label: 'Revenue',
            data: revenueRanges['6m'].values,

            borderColor: '#4f46e5',
            backgroundColor: gradient,

            borderWidth: 2,

            pointRadius: 0,
            pointHoverRadius: 5,

            pointHoverBackgroundColor: '#4f46e5',
            pointHoverBorderColor: '#ffffff',
            pointHoverBorderWidth: 2,

            tension: 0.35,
            fill: true
          }
        ]
      },

      options: {
        responsive: true,
        maintainAspectRatio: false,

        interaction: {
          mode: 'index',
          intersect: false
        },

        plugins: {
          legend: {
            display: false
          },

          tooltip: {
            callbacks: {
              label: (tooltipItem) => {
                return `$${tooltipItem.formattedValue}`
              }
            }
          }
        },

        scales: {
          x: {
            grid: {
              display: false
            },

            ticks: {
              color: '#4b5563'
            }
          },

          y: {
            beginAtZero: true,

            grid: {
              color: '#e5e7eb'
            },

            ticks: {
              color: '#4b5563',

              callback: (value) => {
                return `$${Number(value) / 1000}k`
              }
            }
          }
        }
      }
    })
  }

  // Order Status Doughnut
  const orderCanvas = document.getElementById(
    'order-status-donut-chart'
  )

  if (orderCanvas) {
    new Chart(orderCanvas, {
      type: 'doughnut',

      data: {
        labels: [
          'Paid',
          'Pending',
          'Refunded'
        ],

        datasets: [
          {
            data: [68, 22, 10],

            backgroundColor: [
              '#10b981',
              '#f59e0b',
              '#f43f5e'
            ],

            hoverBackgroundColor: [
              '#059669',
              '#d97706',
              '#e11d48'
            ],

            borderColor: '#ffffff',
            borderWidth: 2
          }
        ]
      },

      options: {
        responsive: true,
        maintainAspectRatio: false,

        cutout: '70%',

        plugins: {
          legend: {
            position: 'bottom',

            labels: {
              color: '#4b5563'
            }
          },

          tooltip: {
            callbacks: {
              label: (tooltipItem) => {
                return `${tooltipItem.label}: ${tooltipItem.formattedValue}%`
              }
            }
          }
        }
      }
    })
  }
})
</script>





<template>
  <div class="flex min-h-screen bg-gray-50">

    <!-- Mobile Sidebar Overlay -->
    <div
      v-if="sidebarOpen"
      class="fixed inset-0 z-30 bg-gray-900/50 lg:hidden"
      @click="sidebarOpen = false"
    ></div>

    <!-- Sidebar -->
    <aside
      class="fixed inset-y-0 start-0 z-40 flex w-64
             flex-col justify-between overflow-y-auto
             border-e border-gray-200 bg-white
             transition-transform duration-300
             lg:static lg:translate-x-0"
      :class="sidebarOpen
        ? 'translate-x-0'
        : '-translate-x-full lg:translate-x-0'"
    >

      <div class="p-4">

        <!-- Logo -->
        <span
          class="grid h-12 w-32 place-content-center
                 rounded-lg bg-gray-100 text-sm text-gray-600"
        >
          Logo
        </span>

        <!-- Navigation -->
        <nav
          aria-label="Dashboard"
          class="mt-4"
        >
          <ul class="space-y-1">

            <li>
              <a
                href="#"
                class="block rounded-lg bg-gray-100
                       px-4 py-2 text-sm font-medium
                       text-gray-900"
              >
                Overview
              </a>
            </li>

            <li>
              <a
                href="#"
                class="block rounded-lg px-4 py-2
                       text-sm font-medium text-gray-600
                       transition-colors hover:bg-gray-100
                       hover:text-gray-900"
              >
                Customers
              </a>
            </li>

            <li>
              <a
                href="#"
                class="block rounded-lg px-4 py-2
                       text-sm font-medium text-gray-600
                       transition-colors hover:bg-gray-100
                       hover:text-gray-900"
              >
                Orders
              </a>
            </li>

            <li>
              <a
                href="#"
                class="block rounded-lg px-4 py-2
                       text-sm font-medium text-gray-600
                       transition-colors hover:bg-gray-100
                       hover:text-gray-900"
              >
                Billing
              </a>
            </li>

            <li>
              <a
                href="#"
                class="block rounded-lg px-4 py-2
                       text-sm font-medium text-gray-600
                       transition-colors hover:bg-gray-100
                       hover:text-gray-900"
              >
                Settings
              </a>
            </li>

          </ul>
        </nav>
      </div>

      <!-- User -->
      <div class="sticky inset-x-0 bottom-0 border-t border-gray-200">

        <a
          href="#"
          class="flex items-center gap-2
                 bg-white p-4 hover:bg-gray-50"
        >

          <img
            alt=""
            src="https://images.unsplash.com/photo-1600486913747-55e5470d6f40?auto=format&fit=crop&q=80&w=1160"
            class="size-10 rounded-full object-cover"
          />

          <p class="text-xs text-gray-900">
            <strong class="block font-medium">
              Priya Natarajan
            </strong>

            <span>
              priya@orbitly.com
            </span>
          </p>

        </a>

      </div>

    </aside>

    <!-- Main -->
    <div class="flex flex-1 flex-col overflow-y-auto">

      <!-- Header -->
      <header
        class="flex items-center justify-between
               border-b border-gray-200 bg-white
               px-6 py-4"
      >

        <div class="flex items-center gap-4">

          <!-- Mobile menu -->
          <button
            type="button"
            class="rounded-md p-2 text-gray-600
                   hover:bg-gray-100 lg:hidden"
            @click="sidebarOpen = !sidebarOpen"
          >
            <span class="sr-only">
              Toggle menu
            </span>

            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="size-5"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M4 6h16M4 12h16M4 18h16"
              />
            </svg>
          </button>

          <h1
            class="text-lg font-semibold text-gray-900"
          >
            Overview
          </h1>

        </div>

        <button
          type="button"
          class="rounded-md bg-gray-900
                 px-4 py-2 text-sm font-medium
                 text-white hover:bg-gray-800"
        >
          New report
        </button>

      </header>

      <!-- Dashboard -->
      <main
        class="flex-1 space-y-6 p-6"
      >

        <!-- Stats -->
        <div
          class="grid grid-cols-1 gap-4 sm:grid-cols-3"
        >

          <!-- Revenue -->
          <article
            class="flex flex-col gap-4
                   rounded-lg border border-gray-200
                   bg-white p-6"
          >

            <div
              class="inline-flex gap-2 self-end
                     rounded-sm bg-green-100
                     p-1 text-green-600"
            >
              <span class="text-xs font-medium">
                ↑ 12.4%
              </span>
            </div>

            <div>
              <strong
                class="block text-sm font-medium
                       text-gray-600"
              >
                Monthly revenue
              </strong>

              <p>
                <span
                  class="text-2xl font-medium
                         text-gray-900"
                >
                  $48,204
                </span>

                <span class="text-xs text-gray-600">
                  from $42,910
                </span>
              </p>
            </div>

            <div class="h-10">
              <canvas
                id="revenue-trend-sparkline"
              ></canvas>
            </div>

          </article>

          <!-- Customers -->
          <article
            class="flex flex-col gap-4
                   rounded-lg border border-gray-200
                   bg-white p-6"
          >

            <div
              class="inline-flex gap-2 self-end
                     rounded-sm bg-green-100
                     p-1 text-green-600"
            >
              <span class="text-xs font-medium">
                ↑ 4.1%
              </span>
            </div>

            <div>
              <strong
                class="block text-sm font-medium
                       text-gray-600"
              >
                Active customers
              </strong>

              <p>
                <span
                  class="text-2xl font-medium
                         text-gray-900"
                >
                  2,318
                </span>

                <span class="text-xs text-gray-600">
                  from 2,227
                </span>
              </p>
            </div>

          </article>

          <!-- Churn -->
          <article
            class="flex flex-col gap-4
                   rounded-lg border border-gray-200
                   bg-white p-6"
          >

            <div
              class="inline-flex gap-2 self-end
                     rounded-sm bg-red-100
                     p-1 text-red-600"
            >
              <span class="text-xs font-medium">
                ↓ 2.6%
              </span>
            </div>

            <div>
              <strong
                class="block text-sm font-medium
                       text-gray-600"
              >
                Churn rate
              </strong>

              <p>
                <span
                  class="text-2xl font-medium
                         text-gray-900"
                >
                  1.8%
                </span>

                <span class="text-xs text-gray-600">
                  from 2.1%
                </span>
              </p>
            </div>

          </article>

        </div>

        <!-- Charts -->
        <div
          class="grid grid-cols-1 gap-4 lg:grid-cols-3"
        >

          <!-- Revenue -->
          <div
            class="rounded-lg border border-gray-200
                   bg-white p-6 lg:col-span-2"
          >

            <div
              class="flex items-center
                     justify-between"
            >

              <h2
                class="text-sm font-medium
                       text-gray-900"
              >
                Revenue trend
              </h2>

              <div
                class="inline-flex rounded-md
                       border border-gray-200 p-0.5
                       text-xs font-medium"
              >

                <button
                  type="button"
                  class="rounded-sm px-2 py-1"
                  :class="selectedRange === '6m'
                    ? 'bg-gray-100 text-gray-900'
                    : 'text-gray-600'"
                  @click="changeRevenueRange('6m')"
                >
                  6M
                </button>

                <button
                  type="button"
                  class="rounded-sm px-2 py-1"
                  :class="selectedRange === '12m'
                    ? 'bg-gray-100 text-gray-900'
                    : 'text-gray-600'"
                  @click="changeRevenueRange('12m')"
                >
                  12M
                </button>

              </div>

            </div>

            <div class="mt-4 h-64">
              <canvas
                id="revenue-trend-line-chart"
              ></canvas>
            </div>

          </div>

          <!-- Order Status -->
          <div
            class="rounded-lg border border-gray-200
                   bg-white p-6"
          >

            <h2
              class="text-sm font-medium
                     text-gray-900"
            >
              Orders by status
            </h2>

            <div class="mt-4 h-64">
              <canvas
                id="order-status-donut-chart"
              ></canvas>
            </div>

          </div>

        </div>

        <!-- Orders -->
        <div
          class="rounded-lg border border-gray-200
                 bg-white p-6"
        >

          <h2
            class="text-sm font-medium
                   text-gray-900"
          >
            Recent orders
          </h2>

          <div class="mt-4 overflow-x-auto">

            <table
              class="min-w-full divide-y-2
                     divide-gray-200"
            >

              <thead>
                <tr
                  class="text-left text-sm
                         font-medium text-gray-900"
                >
                  <th class="px-3 py-2">
                    Customer
                  </th>

                  <th class="px-3 py-2">
                    Order
                  </th>

                  <th class="px-3 py-2">
                    Status
                  </th>

                  <th class="px-3 py-2">
                    Amount
                  </th>
                </tr>
              </thead>

              <tbody
                class="divide-y divide-gray-200"
              >

                <tr
                  v-for="order in orders"
                  :key="order.order"
                  class="text-gray-900"
                >

                  <td
                    class="px-3 py-2 whitespace-nowrap
                           font-medium"
                  >
                    {{ order.customer }}
                  </td>

                  <td
                    class="px-3 py-2 whitespace-nowrap"
                  >
                    {{ order.order }}
                  </td>

                  <td
                    class="px-3 py-2 whitespace-nowrap"
                  >
                    <span
                      class="rounded-full px-2.5
                             py-0.5 text-xs"
                      :class="statusClass(order.status)"
                    >
                      {{ order.status }}
                    </span>
                  </td>

                  <td
                    class="px-3 py-2 whitespace-nowrap"
                  >
                    {{ order.amount }}
                  </td>

                </tr>

              </tbody>

            </table>

          </div>

        </div>

      </main>

    </div>

  </div>
</template>