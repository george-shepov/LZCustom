<template>
  <div id="app" :class="`theme-${getDomainBrand()}`">
    <Navigation />
    <HeroSection />
    <ServicesGrid />
    <TrustBlock />
    <GalleryPreview />
    <Testimonials />
    <QuoteForm />
    <Footer />
    <CustomerServiceChat />
  </div>
</template>

<script setup>
import { provide } from 'vue'
import Navigation from './components/Navigation.vue'
import HeroSection from './components/HeroSection.vue'
import ServicesGrid from './components/ServicesGrid.vue'
import TrustBlock from './components/TrustBlock.vue'
import GalleryPreview from './components/GalleryPreview.vue'
import Testimonials from './components/Testimonials.vue'
import QuoteForm from './components/QuoteForm.vue'
import Footer from './components/Footer.vue'
import CustomerServiceChat from './components/CustomerServiceChat.vue'
import { useDomainBranding } from './composables/useDomainBranding'

const { brandConfig, getDomainBrand } = useDomainBranding()

// Provide brand config to all child components
provide('brandConfig', brandConfig)
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Cormorant+Garamond:wght@400;500;600;700&display=swap');

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Poppins', sans-serif;
  background: #f8f9fa;
  color: #2c3e50;
  line-height: 1.6;
}

h1, h2, h3 {
  font-family: 'Cormorant Garamond', serif;
  font-weight: 600;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
}

.section-padding {
  padding: 5rem 0;
}

.btn-primary {
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  color: white;
  padding: 1rem 2rem;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-block;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(44, 62, 80, 0.3);
}

.btn-secondary {
  background: transparent;
  color: white;
  padding: 1rem 2rem;
  border: 2px solid white;
  border-radius: 8px;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-block;
}

.btn-secondary:hover {
  background: white;
  color: #2c3e50;
  transform: translateY(-2px);
}

/* Smooth scrolling for the entire page */
html {
  scroll-behavior: smooth;
}

/* Loading animation */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.fade-in-up {
  animation: fadeInUp 0.6s ease-out;
}

/* Utility classes */
.text-center {
  text-align: center;
}

/* Domain-specific themes */
.theme-giorgiy {
  --primary-color: #2c5282;
  --secondary-color: #4a5568;
  --accent-color: #3182ce;
}

.theme-giorgiy-shepov {
  --primary-color: #1a202c;
  --secondary-color: #2d3748;
  --accent-color: #ecc94b;
}

.theme-bravoohio {
  --primary-color: #c53030;
  --secondary-color: #2b6cb0;
  --accent-color: #ed8936;
}

.theme-lodexinc {
  --primary-color: #2d3748;
  --secondary-color: #4a5568;
  --accent-color: #718096;
}

.text-left {
  text-align: left;
}

.text-right {
  text-align: right;
}

.mb-1 { margin-bottom: 0.5rem; }
.mb-2 { margin-bottom: 1rem; }
.mb-3 { margin-bottom: 1.5rem; }
.mb-4 { margin-bottom: 2rem; }

.mt-1 { margin-top: 0.5rem; }
.mt-2 { margin-top: 1rem; }
.mt-3 { margin-top: 1.5rem; }
.mt-4 { margin-top: 2rem; }

/* Responsive utilities */
@media (max-width: 768px) {
  .container {
    padding: 0 1rem;
  }

  .section-padding {
    padding: 3rem 0;
  }

  .btn-primary,
  .btn-secondary {
    padding: 0.8rem 1.5rem;
    font-size: 0.9rem;
  }
}

@media (max-width: 480px) {
  .container {
    padding: 0 0.5rem;
  }

  .section-padding {
    padding: 2rem 0;
  }
}

/* Focus styles for accessibility */
button:focus,
input:focus,
select:focus,
textarea:focus,
a:focus {
  outline: 2px solid #f39c12;
  outline-offset: 2px;
}

/* Print styles */
@media print {
  .hero-container,
  .cta-buttons,
  .scroll-indicator {
    display: none;
  }

  body {
    font-size: 12pt;
    line-height: 1.4;
  }
}

/* Smooth transitions for all interactive elements */
* {
  transition: color 0.3s ease, background-color 0.3s ease, transform 0.3s ease, box-shadow 0.3s ease;
}

/* Custom scrollbar */
::-webkit-scrollbar {
  width: 8px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
}

::-webkit-scrollbar-thumb {
  background: #f39c12;
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: #e67e22;
}


</style>