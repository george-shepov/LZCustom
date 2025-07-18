
import { createApp } from 'vue'
import App from './App.vue'

// Create and mount the Vue app
const app = createApp(App)

// Global error handler
app.config.errorHandler = (err, vm, info) => {
  console.error('Vue error:', err, info)
}

app.mount('#app')
