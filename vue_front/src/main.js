import { createApp } from 'vue'
import { createPinia } from 'pinia'
import './style.css'
import router from './route'
import App from './App.vue'
import Chart from 'chart.js/auto'
import 'ldrs/ring'
import i18n from './components/i18n/index.js'

const pinia = createPinia()
const app = createApp(App)

app.use(pinia)
app.use(router)
app.use(i18n)
app.mount('#app')