import { createApp } from 'vue'
import AdminApp from './AdminApp.vue'

// Create and mount the Admin Vue app
const app = createApp(AdminApp)

// Global error handler
app.config.errorHandler = (err, vm, info) => {
  console.error('Vue error:', err, info)
}

app.mount('#admin-app')
