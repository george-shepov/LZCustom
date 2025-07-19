import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import AdminDashboard from './components/AdminDashboard.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: App
  },
  {
    path: '/admin',
    name: 'Admin',
    component: AdminDashboard
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
