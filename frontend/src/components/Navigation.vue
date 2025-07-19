<template>
  <nav class="navigation" :class="{ 'scrolled': isScrolled }">
    <div class="nav-container">
      <div class="nav-logo">
        <h1>
          <span class="logo-lz">LZ</span>
          <span class="logo-custom">Custom</span>
        </h1>
        <span class="logo-fabrication">Fabrication</span>
      </div>

      <div class="nav-links" :class="{ 'active': mobileMenuOpen }">
        <a href="#services" @click="scrollToSection('services')">Services</a>
        <a href="#gallery-preview" @click="scrollToSection('gallery-preview')">Portfolio</a>
        <a href="#quote-form" @click="scrollToSection('quote-form')">Get Quote</a>
        <a href="tel:216-268-2990" class="nav-phone">
          <i class="fas fa-phone"></i>
          216-268-2990
        </a>
      </div>

      <button
        class="mobile-menu-toggle"
        @click="toggleMobileMenu"
        :class="{ 'active': mobileMenuOpen }"
        :aria-label="mobileMenuOpen ? 'Close menu' : 'Open menu'"
        :aria-expanded="mobileMenuOpen"
      >
        <span></span>
        <span></span>
        <span></span>
      </button>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const isScrolled = ref(false)
const mobileMenuOpen = ref(false)

const handleScroll = () => {
  isScrolled.value = window.scrollY > 50
}

const toggleMobileMenu = () => {
  mobileMenuOpen.value = !mobileMenuOpen.value
}

const scrollToSection = (sectionId) => {
  const element = document.getElementById(sectionId)
  if (element) {
    element.scrollIntoView({ behavior: 'smooth' })
  }
  mobileMenuOpen.value = false
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>

<style scoped>
.navigation {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.navigation.scrolled {
  background: rgba(255, 255, 255, 0.98);
  box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
}

.nav-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.nav-logo h1 {
  font-size: 1.8rem;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
  font-family: 'Playfair Display', serif;
  display: flex;
  align-items: baseline;
  gap: 0.3rem;
}

.logo-lz {
  font-size: 1.3em;
  font-weight: 900;
  color: #f39c12;
}

.logo-custom {
  font-weight: 400;
  color: #2c3e50;
}

.logo-fabrication {
  font-size: 0.9rem;
  color: #f39c12;
  font-weight: 500;
  margin-left: 0.5rem;
}

.nav-links {
  display: flex;
  align-items: center;
  gap: 2rem;
}

.nav-links a {
  text-decoration: none;
  color: #2c3e50;
  font-weight: 500;
  transition: color 0.3s ease;
  position: relative;
}

.nav-links a:hover,
.nav-links a:focus {
  color: #f39c12;
  outline: none;
}

.nav-links a::after {
  content: '';
  position: absolute;
  bottom: -5px;
  left: 0;
  width: 0;
  height: 2px;
  background: #f39c12;
  transition: width 0.3s ease;
}

.nav-links a:hover::after,
.nav-links a:focus::after {
  width: 100%;
}

.nav-phone {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white !important;
  padding: 0.75rem 1.5rem;
  border-radius: 25px;
  font-weight: 600;
  box-shadow: 0 4px 15px rgba(243, 156, 18, 0.3);
}

.nav-phone:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(243, 156, 18, 0.4);
  color: white !important;
}

.nav-phone::after {
  display: none;
}

.nav-phone i {
  margin-right: 0.5rem;
}

.mobile-menu-toggle {
  display: none;
  flex-direction: column;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
}

.mobile-menu-toggle span {
  width: 25px;
  height: 3px;
  background: #2c3e50;
  margin: 3px 0;
  transition: 0.3s;
  border-radius: 2px;
}

.mobile-menu-toggle.active span:nth-child(1) {
  transform: rotate(-45deg) translate(-5px, 6px);
}

.mobile-menu-toggle.active span:nth-child(2) {
  opacity: 0;
}

.mobile-menu-toggle.active span:nth-child(3) {
  transform: rotate(45deg) translate(-5px, -6px);
}

@media (max-width: 768px) {
  .nav-container {
    padding: 1rem;
  }

  .nav-logo h1 {
    font-size: 1.5rem;
  }

  .mobile-menu-toggle {
    display: flex;
  }

  .nav-links {
    position: fixed;
    top: 70px;
    left: 0;
    right: 0;
    background: white;
    flex-direction: column;
    padding: 2rem;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
    transform: translateY(-100%);
    opacity: 0;
    visibility: hidden;
    transition: all 0.3s ease;
  }

  .nav-links.active {
    transform: translateY(0);
    opacity: 1;
    visibility: visible;
  }

  .nav-links a {
    padding: 1rem 0;
    border-bottom: 1px solid #f1f5f9;
    width: 100%;
    text-align: center;
  }

  .nav-phone {
    margin-top: 1rem;
    display: inline-block;
  }
}
</style>
