
<template>
  <section id="services" class="services section-padding">
    <div class="container">
      <div class="section-header">
        <h2 class="section-title">Our Expertise</h2>
        <p class="section-subtitle">Comprehensive fabrication and installation services with over 30 years of experience</p>
      </div>

      <div class="services-grid">
        <div
          class="service-card"
          v-for="service in services"
          :key="service.title"
          @mouseenter="playHoverSound"
        >
          <div class="service-icon">
            <div class="icon-background" :style="{ background: service.gradient }">
              <i :class="service.icon"></i>
            </div>
          </div>

          <div class="service-content">
            <h3 class="service-title">{{ service.title }}</h3>
            <p class="service-description">{{ service.description }}</p>

            <div class="service-features">
              <ul>
                <li v-for="feature in service.features" :key="feature">{{ feature }}</li>
              </ul>
            </div>

            <div class="service-materials" v-if="service.materials">
              <div class="materials-label">Materials:</div>
              <div class="materials-list">
                <span
                  v-for="material in service.materials"
                  :key="material"
                  class="material-tag"
                >
                  {{ material }}
                </span>
              </div>
            </div>
          </div>

          <div class="service-overlay">
            <button class="learn-more-btn" @click="openServiceModal(service)">
              Learn More
            </button>
          </div>
        </div>
      </div>

      <div class="services-cta">
        <h3>Ready to Start Your Project?</h3>
        <p>Get a free consultation and quote for your custom fabrication needs</p>
        <button @click="scrollToForm" class="btn-primary">Get Free Quote</button>
      </div>
    </div>
  </section>
</template>

<script setup>
const services = [
  {
    title: 'Custom Cabinets',
    icon: 'fas fa-hammer',
    gradient: 'linear-gradient(135deg, #8B4513 0%, #A0522D 100%)',
    description: 'Handcrafted woodwork designed and built to your exact specifications.',
    features: ['Custom door profiles', 'Soft-close hardware', 'Premium wood species', 'Built-in organizers'],
    materials: ['Oak', 'Maple', 'Cherry', 'Walnut']
  },
  {
    title: 'Countertops',
    icon: 'fas fa-gem',
    gradient: 'linear-gradient(135deg, #2C3E50 0%, #34495E 100%)',
    description: 'Premium natural and engineered stone surfaces for lasting beauty.',
    features: ['Precision templating', 'Professional installation', 'Edge profiling', 'Seamless joints'],
    materials: ['Granite', 'Quartzite', 'Marble', 'Engineered Quartz']
  },
  {
    title: 'Engineered Stone',
    icon: 'fas fa-cube',
    gradient: 'linear-gradient(135deg, #7F8C8D 0%, #95A5A6 100%)',
    description: 'Advanced engineered surfaces combining beauty with durability.',
    features: ['Non-porous surface', 'Stain resistant', 'Consistent patterns', 'Low maintenance'],
    materials: ['Porcelain', 'Ultra Compact', 'Engineered Quartz']
  },
  {
    title: 'Plastics & Laminate',
    icon: 'fas fa-layer-group',
    gradient: 'linear-gradient(135deg, #E74C3C 0%, #C0392B 100%)',
    description: 'Modern, durable surfaces perfect for commercial applications.',
    features: ['Chemical resistant', 'Easy to clean', 'Cost effective', 'Wide color range'],
    materials: ['HPL', 'Solid Surface', 'Thermoform', 'Acrylic']
  },
  {
    title: 'Tile & Flooring',
    icon: 'fas fa-th',
    gradient: 'linear-gradient(135deg, #27AE60 0%, #2ECC71 100%)',
    description: 'Expert installation of tile and flooring for lasting beauty.',
    features: ['Precision layout', 'Waterproof systems', 'Custom patterns', 'Professional grouting'],
    materials: ['Ceramic', 'Porcelain', 'Natural Stone', 'LVT']
  },
  {
    title: 'Commercial Painting',
    icon: 'fas fa-paint-roller',
    gradient: 'linear-gradient(135deg, #F39C12 0%, #E67E22 100%)',
    description: 'Professional interior and exterior painting services.',
    features: ['Surface preparation', 'Premium coatings', 'Color matching', 'Protective finishes'],
    materials: ['Epoxy', 'Polyurethane', 'Acrylic', 'Specialty Coatings']
  }
]

const scrollToForm = () => {
  const el = document.querySelector('#quote-form')
  if (el) el.scrollIntoView({ behavior: 'smooth' })
}

const openServiceModal = (service) => {
  // This would open a modal with more details about the service
  console.log('Opening modal for:', service.title)
  alert(`Learn more about ${service.title} - Feature coming soon!`)
}

const playHoverSound = () => {
  // Optional: Add subtle hover sound effect
}
</script>

<style scoped>
.services {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  position: relative;
}

.services::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="50" height="50" patternUnits="userSpaceOnUse"><circle cx="10" cy="10" r="0.5" fill="%23000000" opacity="0.02"/><circle cx="40" cy="20" r="0.5" fill="%23000000" opacity="0.02"/><circle cx="20" cy="40" r="0.5" fill="%23000000" opacity="0.02"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
  pointer-events: none;
}

.section-header {
  text-align: center;
  margin-bottom: 4rem;
}

.section-title {
  font-size: clamp(2.5rem, 5vw, 3.5rem);
  color: #2c3e50;
  margin-bottom: 1rem;
  position: relative;
}

.section-title::after {
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

.section-subtitle {
  font-size: 1.2rem;
  color: #7f8c8d;
  max-width: 600px;
  margin: 0 auto;
  line-height: 1.6;
}

.services-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 2rem;
  margin-bottom: 4rem;
}

.service-card {
  background: white;
  border-radius: 16px;
  padding: 2rem;
  position: relative;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.service-card:hover {
  transform: translateY(-8px) scale(1.02);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

.service-card:hover .service-overlay {
  opacity: 1;
  visibility: visible;
}

.service-card:hover .service-icon .icon-background {
  transform: scale(1.1) rotate(5deg);
}

.service-icon {
  margin-bottom: 1.5rem;
}

.icon-background {
  width: 80px;
  height: 80px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
  transition: all 0.3s ease;
  position: relative;
}

.icon-background i {
  font-size: 2rem;
  color: white;
  z-index: 2;
}

.service-content {
  text-align: center;
}

.service-title {
  font-size: 1.5rem;
  color: #2c3e50;
  margin-bottom: 1rem;
  font-weight: 600;
}

.service-description {
  color: #7f8c8d;
  margin-bottom: 1.5rem;
  line-height: 1.6;
}

.service-features ul {
  list-style: none;
  padding: 0;
  margin-bottom: 1.5rem;
}

.service-features li {
  color: #34495e;
  margin-bottom: 0.5rem;
  position: relative;
  padding-left: 1.5rem;
  font-size: 0.9rem;
}

.service-features li::before {
  content: '✓';
  position: absolute;
  left: 0;
  color: #27ae60;
  font-weight: bold;
}

.service-materials {
  margin-top: 1rem;
}

.materials-label {
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
}

.materials-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  justify-content: center;
}

.material-tag {
  background: #ecf0f1;
  color: #2c3e50;
  padding: 0.3rem 0.8rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
}

.service-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(44, 62, 80, 0.95);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s ease;
  border-radius: 16px;
}

.learn-more-btn {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  transform: translateY(20px);
}

.service-card:hover .learn-more-btn {
  transform: translateY(0);
}

.learn-more-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(243, 156, 18, 0.3);
}

.services-cta {
  text-align: center;
  background: white;
  padding: 3rem;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.services-cta h3 {
  font-size: 2rem;
  color: #2c3e50;
  margin-bottom: 1rem;
}

.services-cta p {
  color: #7f8c8d;
  margin-bottom: 2rem;
  font-size: 1.1rem;
}

/* Mobile Responsiveness */
@media (max-width: 768px) {
  .services-grid {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }

  .service-card {
    padding: 1.5rem;
  }

  .services-cta {
    padding: 2rem;
  }
}

@media (max-width: 480px) {
  .service-card {
    padding: 1rem;
  }

  .icon-background {
    width: 60px;
    height: 60px;
  }

  .icon-background i {
    font-size: 1.5rem;
  }
}
</style>
