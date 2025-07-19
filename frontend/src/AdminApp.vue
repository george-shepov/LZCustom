<template>
  <div id="admin-app">
    <AdminDashboard />
  </div>
</template>

<script setup>
import AdminDashboard from './components/AdminDashboard.vue'
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Playfair+Display:wght@400;500;600;700&display=swap');
@import url('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css');

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Inter', sans-serif;
  background: #f8fafc;
}

#admin-app {
  min-height: 100vh;
}
</style>
