
<template>
  <div class="hero-container">
    <div class="hero-background" :style="backgroundStyle"></div>
    <div class="hero-overlay"></div>

    <div class="hero-content">
      <div class="container">
        <div class="hero-text hero-fade" :class="{ 'visible': isVisible }">
          <h1 class="hero-title">
            <span class="lz">LZ</span> <span class="custom">Custom</span>
          </h1>

          <div class="hero-tagline">
            <p class="tagline-main">Custom Cabinets & Stone Fabrication</p>
            <p class="tagline-sub">30+ Years Serving Northeast Ohio</p>
          </div>

          <div class="hero-highlights">
            <div class="highlight-item">
              <span class="highlight-text">Licensed & Insured</span>
            </div>
            <div class="highlight-divider">•</div>
            <div class="highlight-item">
              <span class="highlight-text">Free Estimates</span>
            </div>
            <div class="highlight-divider">•</div>
            <div class="highlight-item">
              <span class="highlight-text">Expert Craftsmanship</span>
            </div>
          </div>

          <div class="cta-buttons">
            <button
              @click="scrollToForm"
              class="btn-primary"
              aria-label="Request free consultation - scroll to quote form"
            >
              Request Free Consultation
            </button>
            <button
              @click="scrollToGallery"
              class="btn-secondary"
              aria-label="View our portfolio - scroll to gallery section"
            >
              View Portfolio
            </button>
          </div>


        </div>
      </div>
    </div>

    <!-- Mobile-only Phone FAB -->
    <a href="tel:216-268-2990" class="phone-fab">
      <i class="fas fa-phone"></i>
    </a>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const isVisible = ref(false)

const currentHeroIndex = ref(0)
const screenWidth = ref(window.innerWidth)

const heroImages = {
  mobile: [
    '/assets/gallery/hero/hero-main-hd.png',
    '/assets/gallery/hero/hero-showroom-hd.png',
    '/assets/gallery/hero/hero-kitchen-hd.png'
  ],
  tablet: [
    '/assets/gallery/hero/hero-main-hd.png',
    '/assets/gallery/hero/hero-showroom-hd.png',
    '/assets/gallery/hero/hero-kitchen-hd.png',
    '/assets/gallery/hero/hero-workshop-hd.png'
  ],
  desktop: [
    '/assets/gallery/hero/hero-main-hd.png',
    '/assets/gallery/hero/hero-showroom-hd.png',
    '/assets/gallery/hero/hero-kitchen-hd.png',
    '/assets/gallery/hero/hero-workshop-hd.png',
    '/assets/gallery/hero/hero-1.jpg'
  ],
  large: [
    '/assets/gallery/hero/hero-main-hd.png',
    '/assets/gallery/hero/hero-showroom-hd.png',
    '/assets/gallery/hero/hero-kitchen-hd.png',
    '/assets/gallery/hero/hero-workshop-hd.png',
    '/assets/gallery/hero/hero-1.jpg',
    '/assets/gallery/hero/hero-3.jpg'
  ]
}

const currentImageSet = computed(() => {
  if (screenWidth.value < 768) return heroImages.mobile
  if (screenWidth.value < 1024) return heroImages.tablet
  if (screenWidth.value < 1440) return heroImages.desktop
  return heroImages.large
})

const backgroundStyle = computed(() => ({
  backgroundImage: `url(${currentImageSet.value[currentHeroIndex.value]})`,
  backgroundSize: 'cover',
  backgroundPosition: 'center',
  backgroundRepeat: 'no-repeat',
  transition: 'background-image 1.5s ease-in-out'
}))

onMounted(() => {
  // Handle window resize
  window.addEventListener('resize', () => {
    screenWidth.value = window.innerWidth
  })

  // Rotate images every 6 seconds
  setInterval(() => {
    currentHeroIndex.value = (currentHeroIndex.value + 1) % currentImageSet.value.length
  }, 6000)

  // Trigger entrance animation
  setTimeout(() => {
    isVisible.value = true
  }, 300)
})

const scrollToForm = () => {
  document.querySelector('#quote-form')?.scrollIntoView({ behavior: 'smooth' })
}

const scrollToGallery = () => {
  document.querySelector('#gallery-preview')?.scrollIntoView({ behavior: 'smooth' })
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Playfair+Display:wght@400;500;600;700&display=swap');

.hero-container {
  position: relative;
  height: 100vh;
  min-height: 600px;
  overflow: hidden;
  width: 100%;
  padding-top: 120px;
  padding-bottom: 100px;
}

.hero-background {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1;
  background-size: cover !important;
  background-position: center center !important;
  background-repeat: no-repeat !important;
  background-attachment: fixed;
  will-change: background-image;
  transform: translateZ(0);
}

/* Preload critical hero images */
.hero-background::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: url('/assets/gallery/hero/hero-main.jpg');
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  opacity: 0;
  pointer-events: none;
  z-index: -1;
}

.hero-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(
    135deg,
    rgba(44, 62, 80, 0.85) 0%,
    rgba(52, 73, 94, 0.75) 30%,
    rgba(44, 62, 80, 0.6) 70%,
    rgba(44, 62, 80, 0.85) 100%
  );
  z-index: 2;
}

.hero-content {
  position: relative;
  z-index: 3;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 5rem 2rem;
}

.hero-text {
  max-width: 800px;
  color: white;
  animation: fadeInUp 1s ease-out;
}

.hero-title {
  font-family: 'Playfair Display', serif;
  font-size: clamp(4rem, 10vw, 8rem);
  font-weight: 800;
  letter-spacing: -0.5px;
  text-align: center;
  line-height: 1.1;
  margin-bottom: 0.5rem;
  text-shadow: 3px 3px 6px rgba(0, 0, 0, 0.4);
}

.lz {
  color: #f39c12;
  font-weight: 900;
  font-size: 1.2em;
  margin-right: 0.2em;
}

.custom {
  color: #fff;
  font-weight: 700;
}

.hero-subtitle {
  font-size: clamp(1rem, 2vw, 1.5rem);
  color: rgba(255, 255, 255, 0.8);
  font-weight: 300;
  text-align: center;
  margin-bottom: 2rem;
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

.hero-tagline {
  margin-top: 1.5rem;
  margin-bottom: 3rem;
}

.tagline-main {
  font-size: clamp(1.25rem, 2.5vw, 1.5rem);
  font-weight: 500;
  line-height: 1.6;
  margin-bottom: 1rem;
  color: rgba(255, 255, 255, 0.95);
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
}

.tagline-sub {
  font-size: clamp(1rem, 2vw, 1.25rem);
  font-weight: 400;
  line-height: 1.6;
  margin-bottom: 0;
  color: rgba(255, 255, 255, 0.85);
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
}

.cta-buttons {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  justify-content: center;
}

.phone-fab {
  position: fixed;
  bottom: 20px;
  right: 20px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
  border-radius: 50%;
  width: 56px;
  height: 56px;
  display: none;
  align-items: center;
  justify-content: center;
  font-size: 1.25rem;
  text-decoration: none;
  box-shadow: 0 4px 15px rgba(243, 156, 18, 0.4);
  z-index: 1000;
  transition: all 0.3s ease;
}

.phone-fab:hover {
  transform: scale(1.1);
  box-shadow: 0 6px 20px rgba(243, 156, 18, 0.5);
  color: white;
  text-decoration: none;
}

.hero-fade {
  opacity: 0;
  transform: translateY(30px);
  transition: all 0.8s ease-out;
}

.hero-fade.visible {
  opacity: 1;
  transform: translateY(0);
}

.hero-subtitle {
  font-family: 'Inter', sans-serif;
  font-size: clamp(1.1rem, 2.5vw, 1.4rem);
  font-weight: 400;
  line-height: 1.6;
  margin-bottom: 2.5rem;
  opacity: 0.95;
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
}

.hero-cta {
  display: flex;
  gap: 1.5rem;
  justify-content: center;
  flex-wrap: wrap;
}

.btn-primary, .btn-secondary {
  padding: 1rem 2rem;
  border-radius: 8px;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 160px;
  font-family: 'Inter', sans-serif;
  border: none;
}

.btn-primary {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
  box-shadow: 0 6px 20px rgba(243, 156, 18, 0.4);
  position: relative;
  overflow: hidden;
}

.btn-primary::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s;
}

.btn-primary:hover::before {
  left: 100%;
}

.btn-primary:hover,
.btn-primary:focus {
  transform: translateY(-3px);
  box-shadow: 0 10px 30px rgba(243, 156, 18, 0.5);
  background: linear-gradient(135deg, #e67e22 0%, #d35400 100%);
  outline: 2px solid #f39c12;
  outline-offset: 2px;
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.3);
  backdrop-filter: blur(10px);
}

.btn-secondary:hover,
.btn-secondary:focus {
  background: rgba(255, 255, 255, 0.2);
  border-color: rgba(255, 255, 255, 0.5);
  transform: translateY(-2px);
  outline: 2px solid rgba(255, 255, 255, 0.5);
  outline-offset: 2px;
}

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

/* Mobile Responsiveness */
@media (max-width: 768px) {
  .hero-background {
    background-attachment: scroll;
  }
  
  .hero-content {
    padding: 3rem 1rem;
  }

  .cta-buttons {
    flex-direction: column;
    align-items: center;
    gap: 0.75rem;
  }

  .cta-buttons button {
    width: 100%;
    max-width: 280px;
  }

  .phone-fab {
    display: flex;
  }
  
  .btn-primary, .btn-secondary {
    width: 100%;
    max-width: 280px;
  }
}

@media (max-width: 480px) {
  .hero-container {
    min-height: 500px;
  }
  
  .hero-title {
    margin-bottom: 1rem;
  }
  
  .hero-subtitle {
    margin-bottom: 2rem;
  }
}

/* High DPI Display Support */
@media (-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi) {
  .hero-background {
    image-rendering: -webkit-optimize-contrast;
    image-rendering: crisp-edges;
  }
}
</style>
