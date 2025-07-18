<template>
  <section class="trust-block section-padding">
    <div class="container">
      <div class="trust-content">
        <div class="trust-header">
          <h2 class="trust-title">Why Choose LZ Custom?</h2>
          <p class="trust-subtitle">Trusted by Northeast Ohio for over three decades</p>
        </div>
        
        <div class="trust-grid">
          <div class="trust-item" v-for="item in trustItems" :key="item.title">
            <div class="trust-icon">
              <i :class="item.icon"></i>
            </div>
            <div class="trust-text">
              <h3>{{ item.title }}</h3>
              <p>{{ item.description }}</p>
            </div>
          </div>
        </div>
        
        <div class="service-area">
          <h3 class="area-title">Proudly Serving Northeast Ohio</h3>
          <div class="cities-grid">
            <div class="city-item" v-for="city in cities" :key="city">
              <i class="fas fa-map-marker-alt"></i>
              <span>{{ city }}</span>
            </div>
          </div>
          <p class="area-note">And surrounding communities throughout the region</p>
        </div>
        
        <div class="credentials">
          <div class="credential-item">
            <i class="fas fa-certificate"></i>
            <span>Licensed & Insured</span>
          </div>
          <div class="credential-item">
            <i class="fas fa-award"></i>
            <span>BBB Accredited</span>
          </div>
          <div class="credential-item">
            <i class="fas fa-handshake"></i>
            <span>Satisfaction Guaranteed</span>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
const trustItems = [
  {
    icon: 'fas fa-industry',
    title: 'In-House Manufacturing & Fabrication',
    description: 'We control every aspect of production in our own facility. No outsourcing means better quality control, faster turnaround, and competitive pricing.'
  },
  {
    icon: 'fas fa-building',
    title: 'Commercial & Residential',
    description: 'From custom home kitchens to large commercial installations, we have the expertise and capacity to handle projects of any size.'
  },
  {
    icon: 'fas fa-calendar-alt',
    title: '30+ Years in Business',
    description: 'Three decades of experience in Northeast Ohio. We\'ve built lasting relationships with customers, suppliers, and the community.'
  },
  {
    icon: 'fas fa-tools',
    title: 'Complete Service Range',
    description: 'From initial design consultation to final installation, we provide comprehensive services under one roof for your convenience.'
  }
]

const cities = [
  'Cleveland',
  'Akron',
  'Canton',
  'Youngstown',
  'Lorain',
  'Ashtabula'
]
</script>

<style scoped>
.trust-block {
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  color: white;
  position: relative;
  overflow: hidden;
}

.trust-block::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="trustPattern" width="20" height="20" patternUnits="userSpaceOnUse"><path d="M0 0h20v20H0z" fill="none"/><path d="M10 0v20M0 10h20" stroke="%23ffffff" stroke-width="0.5" opacity="0.1"/></pattern></defs><rect width="100" height="100" fill="url(%23trustPattern)"/></svg>');
  pointer-events: none;
}

.trust-content {
  position: relative;
  z-index: 2;
}

.trust-header {
  text-align: center;
  margin-bottom: 4rem;
}

.trust-title {
  font-size: clamp(2.5rem, 5vw, 3.5rem);
  margin-bottom: 1rem;
  position: relative;
}

.trust-title::after {
  content: '';
  position: absolute;
  bottom: -10px;
  left: 50%;
  transform: translateX(-50%);
  width: 80px;
  height: 4px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-radius: 2px;
}

.trust-subtitle {
  font-size: 1.2rem;
  color: #bdc3c7;
  max-width: 600px;
  margin: 0 auto;
}

.trust-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin-bottom: 4rem;
}

.trust-item {
  background: rgba(255, 255, 255, 0.1);
  padding: 2rem;
  border-radius: 16px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
}

.trust-item:hover {
  transform: translateY(-5px);
  background: rgba(255, 255, 255, 0.15);
}

.trust-icon {
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.5rem;
  transition: all 0.3s ease;
}

.trust-item:hover .trust-icon {
  transform: scale(1.1);
}

.trust-icon i {
  font-size: 2rem;
  color: white;
}

.trust-text h3 {
  font-size: 1.3rem;
  margin-bottom: 1rem;
  color: white;
}

.trust-text p {
  color: #bdc3c7;
  line-height: 1.6;
}

.service-area {
  background: rgba(255, 255, 255, 0.1);
  padding: 3rem;
  border-radius: 16px;
  text-align: center;
  margin-bottom: 3rem;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.area-title {
  font-size: 2rem;
  margin-bottom: 2rem;
  color: white;
}

.cities-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.city-item {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.8rem;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  transition: all 0.3s ease;
}

.city-item:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
}

.city-item i {
  color: #f39c12;
}

.area-note {
  color: #bdc3c7;
  font-style: italic;
}

.credentials {
  display: flex;
  justify-content: center;
  gap: 3rem;
  flex-wrap: wrap;
}

.credential-item {
  display: flex;
  align-items: center;
  gap: 0.8rem;
  padding: 1rem 1.5rem;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
}

.credential-item:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
}

.credential-item i {
  color: #f39c12;
  font-size: 1.2rem;
}

.credential-item span {
  font-weight: 600;
  white-space: nowrap;
}

/* Mobile Responsiveness */
@media (max-width: 768px) {
  .trust-grid {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }
  
  .service-area {
    padding: 2rem;
  }
  
  .cities-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .credentials {
    flex-direction: column;
    align-items: center;
    gap: 1rem;
  }
}

@media (max-width: 480px) {
  .trust-item {
    padding: 1.5rem;
  }
  
  .trust-icon {
    width: 60px;
    height: 60px;
  }
  
  .trust-icon i {
    font-size: 1.5rem;
  }
  
  .cities-grid {
    grid-template-columns: 1fr;
  }
}
</style>
