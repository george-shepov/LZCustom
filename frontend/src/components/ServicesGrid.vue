
<template>
  <section id="services" class="services section-padding">
    <div class="container">
      <div class="section-header">
        <h2 class="section-title">Our Expertise</h2>
        <p class="section-subtitle">Comprehensive fabrication and installation services with over 30 years of experience</p>
      </div>

      <!-- Primary Services Row -->
      <div class="services-category">
        <h3 class="category-title">Core Fabrication Services</h3>
        <div class="services-grid primary-services">
          <div
            class="service-card primary"
            v-for="service in primaryServices"
            :key="service.title"
            @mouseenter="playHoverSound"
            @click="openServiceModal(service)"
          >
            <div class="service-icon">
              <i :class="service.icon"></i>
            </div>

            <div class="service-content">
              <h3 class="service-title">{{ service.title }}</h3>
              <p class="service-description">{{ service.description }}</p>

              <div class="service-features">
                <h4 class="features-subhead">{{ service.subhead || 'Services' }}</h4>
                <ul>
                  <li v-for="feature in service.features.slice(0, 3)" :key="feature">{{ feature }}</li>
                </ul>
              </div>

            <div class="service-materials" v-if="service.materials">
              <div class="materials-label">Materials:</div>
              <div class="materials-list">
                <span
                  v-for="material in service.materials.slice(0, 4)"
                  :key="material"
                  class="material-tag"
                >
                  {{ material }}
                </span>
              </div>
            </div>
          </div>

          <div class="service-action">
            <i class="fas fa-arrow-right"></i>
          </div>
        </div>
        </div>
      </div>

      <!-- Secondary Services Row -->
      <div class="services-category">
        <h3 class="category-title">Specialized Services</h3>
        <div class="services-grid secondary-services">
          <div
            class="service-card secondary"
            v-for="service in secondaryServices"
            :key="service.title"
            @mouseenter="playHoverSound"
            @click="openServiceModal(service)"
          >
            <div class="service-icon">
              <i :class="service.icon"></i>
            </div>

            <div class="service-content">
              <h3 class="service-title">{{ service.title }}</h3>
              <p class="service-description">{{ service.description }}</p>

              <div class="service-features">
                <h4 class="features-subhead">{{ service.subhead || 'Services' }}</h4>
                <ul>
                  <li v-for="feature in service.features.slice(0, 3)" :key="feature">{{ feature }}</li>
                </ul>
              </div>

              <div class="service-materials" v-if="service.materials">
                <div class="materials-label">Materials:</div>
                <div class="materials-list">
                  <span
                    v-for="material in service.materials.slice(0, 4)"
                    :key="material"
                    class="material-tag"
                  >
                    {{ material }}
                  </span>
                </div>
              </div>
            </div>

            <div class="service-action">
              <i class="fas fa-arrow-right"></i>
            </div>
          </div>
        </div>
      </div>

      <div class="services-cta">
        <h3>Let's Build Something Beautiful Together</h3>
        <p>Transform your vision into reality with our expert craftsmanship and premium materials</p>
        <button @click="scrollToForm" class="btn-primary">Start with a Free Custom Estimate Today</button>
      </div>
    </div>

    <!-- Helpful Modal -->
    <HelpfulModal
      :isOpen="showModal"
      :modalData="currentModalData"
      @close="closeModal"
    />
  </section>
</template>

<script setup>
import { ref } from 'vue'
import HelpfulModal from './HelpfulModal.vue'

// Primary Services - Core offerings
const primaryServices = [
  {
    title: 'Custom Cabinets',
    icon: 'fas fa-hammer',
    gradient: 'linear-gradient(135deg, #8B4513 0%, #A0522D 100%)',
    description: 'Handcrafted woodwork designed and built to your exact specifications.',
    subhead: 'Craftsmanship',
    features: ['Custom door profiles', 'Soft-close hardware', 'Premium wood species', 'Built-in organizers'],
    materials: ['Oak', 'Maple', 'Cherry', 'Walnut']
  },
  {
    title: 'Countertops',
    icon: 'fas fa-gem',
    gradient: 'linear-gradient(135deg, #2C3E50 0%, #34495E 100%)',
    description: 'Premium natural and engineered stone surfaces for lasting beauty.',
    subhead: 'Surfaces',
    features: ['Precision templating', 'Professional installation', 'Edge profiling', 'Seamless joints'],
    materials: ['Granite', 'Quartzite', 'Marble', 'Engineered Quartz']
  },
  {
    title: 'Engineered Stone',
    icon: 'fas fa-cube',
    gradient: 'linear-gradient(135deg, #2C3E50 0%, #34495E 100%)',
    description: 'Advanced engineered surfaces combining beauty with durability.',
    subhead: 'Innovation',
    features: ['Non-porous surface', 'Stain resistant', 'Consistent patterns', 'Low maintenance'],
    materials: ['Porcelain', 'Ultra Compact', 'Engineered Quartz']
  }
]

// Secondary Services - Specialized offerings
const secondaryServices = [
  {
    title: 'Plastics & Laminate',
    icon: 'fas fa-layer-group',
    gradient: 'linear-gradient(135deg, #E74C3C 0%, #C0392B 100%)',
    description: 'Modern, durable surfaces perfect for commercial applications.',
    subhead: 'Commercial',
    features: ['Chemical resistant', 'Easy to clean', 'Cost effective', 'Wide color range'],
    materials: ['HPL', 'Solid Surface', 'Thermoform', 'Acrylic']
  },
  {
    title: 'Tile & Flooring',
    icon: 'fas fa-th',
    gradient: 'linear-gradient(135deg, #27AE60 0%, #2ECC71 100%)',
    description: 'Expert installation of tile and flooring for lasting beauty.',
    subhead: 'Install',
    features: ['Precision layout', 'Waterproof systems', 'Custom patterns', 'Professional grouting'],
    materials: ['Ceramic', 'Porcelain', 'Natural Stone', 'LVT']
  },
  {
    title: 'Commercial Painting',
    icon: 'fas fa-paint-roller',
    gradient: 'linear-gradient(135deg, #F39C12 0%, #E67E22 100%)',
    description: 'Professional interior and exterior painting services.',
    subhead: 'Painting',
    features: ['Surface preparation', 'Premium coatings', 'Color matching', 'Protective finishes'],
    materials: ['Epoxy', 'Polyurethane', 'Acrylic', 'Specialty Coatings']
  }
]

const scrollToForm = () => {
  const el = document.querySelector('#quote-form')
  if (el) el.scrollIntoView({ behavior: 'smooth' })
}

const showModal = ref(false)
const currentModalData = ref({})

const openServiceModal = (service) => {
  currentModalData.value = getServiceModalData(service)
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
}

const getServiceModalData = (service) => {
  const modalData = {
    'Custom Cabinets': {
      icon: 'fas fa-hammer',
      title: 'Custom Cabinet Fabrication',
      image: '/images/custom-cabinets-hero.jpg',
      content: [
        'Transform your kitchen or bathroom with handcrafted custom cabinets built to your exact specifications. Our master craftsmen use premium hardwoods and time-tested techniques to create cabinets that will last generations.',
        'Every cabinet is designed and built in our Northeast Ohio workshop, ensuring the highest quality control and attention to detail. We work with you from initial design through final installation.'
      ],
      tips: [
        'Measure your space carefully - we provide free in-home consultations',
        'Consider your storage needs and daily workflow when planning',
        'Choose wood species that complement your home\'s style',
        'Plan for proper lighting inside cabinets for functionality'
      ],
      features: [
        { icon: 'fas fa-tree', name: 'Premium Hardwoods' },
        { icon: 'fas fa-ruler-combined', name: 'Custom Sizing' },
        { icon: 'fas fa-palette', name: 'Custom Finishes' },
        { icon: 'fas fa-tools', name: 'Expert Installation' }
      ],
      pricing: {
        range: '$15,000 - $50,000+',
        note: 'Pricing varies by size, wood species, and complexity. Free estimates available.'
      }
    },
    'Premium Countertops': {
      icon: 'fas fa-gem',
      title: 'Premium Countertop Installation',
      image: '/images/countertops-hero.jpg',
      content: [
        'Elevate your kitchen or bathroom with stunning natural stone or engineered countertops. We specialize in granite, marble, quartz, and exotic stone materials that combine beauty with durability.',
        'Our precision fabrication and expert installation ensure perfect fit and finish. Each countertop is templated, cut, and polished in our state-of-the-art facility.'
      ],
      tips: [
        'Consider maintenance requirements - quartz needs less care than natural stone',
        'Think about edge profiles that complement your cabinet style',
        'Plan for proper support, especially with overhangs',
        'Choose colors that won\'t date your kitchen design'
      ],
      features: [
        { icon: 'fas fa-mountain', name: 'Natural Stone' },
        { icon: 'fas fa-shield-alt', name: 'Stain Resistant' },
        { icon: 'fas fa-fire', name: 'Heat Resistant' },
        { icon: 'fas fa-cut', name: 'Precision Cut' }
      ],
      pricing: {
        range: '$3,000 - $15,000',
        note: 'Includes templating, fabrication, and installation. Material costs vary.'
      }
    },
    'Stone Fabrication': {
      icon: 'fas fa-mountain',
      title: 'Master Stone Fabrication',
      image: '/images/stone-fabrication.jpg',
      content: [
        'Our master stone fabricators create custom architectural elements, fireplace surrounds, outdoor kitchens, and specialty installations. We work with granite, marble, limestone, and exotic stones.',
        'From concept to completion, we handle every aspect of your stone project with precision and artistry. Our team has over 30 years of experience in complex stone fabrication.'
      ],
      tips: [
        'Consider the environment - outdoor stones need different properties',
        'Plan for proper drainage and support structures',
        'Choose finishes appropriate for the application',
        'Factor in maintenance and sealing requirements'
      ],
      features: [
        { icon: 'fas fa-drafting-compass', name: 'Custom Design' },
        { icon: 'fas fa-industry', name: 'CNC Precision' },
        { icon: 'fas fa-home', name: 'Indoor/Outdoor' },
        { icon: 'fas fa-certificate', name: '30+ Years Experience' }
      ],
      pricing: {
        range: '$2,000 - $20,000',
        note: 'Highly variable based on complexity and materials. Consultation required.'
      }
    }
  }

  return modalData[service.title] || {
    icon: service.icon,
    title: service.title,
    content: [service.description],
    tips: ['Contact us for more information about this service'],
    pricing: { range: 'Contact for pricing', note: 'Free estimates available' }
  }
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
  font-size: clamp(3rem, 6vw, 4.5rem);
  font-weight: 800;
  letter-spacing: -0.5px;
  color: #2c3e50;
  margin-bottom: 1.5rem;
  position: relative;
}

.section-title::after {
  content: '';
  position: absolute;
  bottom: -12px;
  left: 50%;
  transform: translateX(-50%);
  width: 100px;
  height: 4px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-radius: 2px;
}

.section-subtitle {
  font-size: 1.25rem;
  color: #666;
  max-width: 700px;
  margin: 0 auto 3rem auto;
  line-height: 1.6;
  font-weight: 400;
}

.services-category {
  margin-bottom: 4rem;
}

.category-title {
  font-size: 2.25rem;
  font-weight: 700;
  color: #2c3e50;
  text-align: center;
  margin-bottom: 2.5rem;
  position: relative;
}

.category-title::after {
  content: '';
  position: absolute;
  bottom: -8px;
  left: 50%;
  transform: translateX(-50%);
  width: 60px;
  height: 3px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-radius: 2px;
}

.services-grid {
  display: grid;
  gap: 2rem;
  margin-bottom: 2rem;
}

.primary-services {
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
}

.secondary-services {
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
}

.service-card {
  background: white;
  border-radius: 16px;
  padding: 2rem;
  position: relative;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  border: 2px solid #f1f5f9;
  cursor: pointer;
  display: block;
  text-align: center;
}

.service-card.primary {
  border: 2px solid #f39c12;
  box-shadow: 0 6px 20px rgba(243, 156, 18, 0.1);
}

.service-card.secondary {
  border: 1px solid #e2e8f0;
  box-shadow: 0 3px 10px rgba(0, 0, 0, 0.06);
}

.service-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, #f39c12, #e67e22);
  transform: scaleX(0);
  transition: transform 0.3s ease;
  border-radius: 12px 12px 0 0;
}

.service-card:hover {
  transform: translateY(-6px) scale(1.02);
  box-shadow: 0 12px 35px rgba(243, 156, 18, 0.2);
  border-color: #f39c12;
}

.service-card:hover::before {
  transform: scaleX(1);
}

.service-icon {
  width: 60px;
  height: 60px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1.5rem auto;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(243, 156, 18, 0.2);
}

.service-icon i {
  font-size: 1.5rem;
  color: white;
}

.service-content {
  text-align: left;
}

.service-title {
  font-size: 1.5rem;
  color: #2c3e50;
  margin-bottom: 1rem;
  font-weight: 700;
  font-family: 'Playfair Display', serif;
  text-align: center;
}

.service-description {
  color: #7f8c8d;
  margin-bottom: 1rem;
  line-height: 1.5;
  font-size: 0.95rem;
}

.features-subhead {
  font-size: 0.9rem;
  font-weight: 700;
  color: #2c3e50;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 0.75rem;
  margin-top: 0;
}

.service-features ul {
  list-style: none;
  padding: 0;
  margin-bottom: 1rem;
}

.service-features li {
  color: #34495e;
  margin-bottom: 0.25rem;
  position: relative;
  padding-left: 1.2rem;
  font-size: 0.85rem;
}

.service-features li::before {
  content: '✓';
  position: absolute;
  left: 0;
  color: #f39c12;
  font-weight: bold;
  font-size: 0.8rem;
}

.service-materials {
  margin-top: 0.75rem;
}

.materials-label {
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.25rem;
  font-size: 0.85rem;
}

.materials-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.25rem;
}

.material-tag {
  background: #f8fafc;
  color: #64748b;
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 500;
  border: 1px solid #e2e8f0;
}

.service-action {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  background: #f8fafc;
  border-radius: 50%;
  color: #f39c12;
  transition: all 0.3s ease;
  flex-shrink: 0;
}

.service-card:hover .service-action {
  background: #f39c12;
  color: white;
  transform: translateX(5px);
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
