<template>
  <div v-if="isOpen" class="modal-overlay" @click="closeModal">
    <div class="modal-content" @click.stop>
      <button class="modal-close" @click="closeModal">
        <i class="fas fa-times"></i>
      </button>
      
      <div class="modal-header">
        <div class="modal-icon">
          <i :class="modalData.icon"></i>
        </div>
        <h2>{{ modalData.title }}</h2>
      </div>
      
      <div class="modal-body">
        <div v-if="modalData.image" class="modal-image">
          <img :src="modalData.image" :alt="modalData.title" />
        </div>
        
        <div class="modal-text">
          <p v-for="paragraph in modalData.content" :key="paragraph" class="modal-paragraph">
            {{ paragraph }}
          </p>
        </div>
        
        <div v-if="modalData.tips" class="modal-tips">
          <h3>💡 Helpful Tips:</h3>
          <ul>
            <li v-for="tip in modalData.tips" :key="tip">{{ tip }}</li>
          </ul>
        </div>
        
        <div v-if="modalData.features" class="modal-features">
          <h3>✨ Key Features:</h3>
          <div class="features-grid">
            <div v-for="feature in modalData.features" :key="feature.name" class="feature-item">
              <i :class="feature.icon"></i>
              <span>{{ feature.name }}</span>
            </div>
          </div>
        </div>
        
        <div v-if="modalData.pricing" class="modal-pricing">
          <h3>💰 Investment Range:</h3>
          <div class="pricing-info">
            <div class="price-range">{{ modalData.pricing.range }}</div>
            <div class="price-note">{{ modalData.pricing.note }}</div>
          </div>
        </div>
      </div>
      
      <div class="modal-footer">
        <button @click="scrollToQuote" class="btn-primary">
          <i class="fas fa-calculator"></i>
          Get Free Quote
        </button>
        <a href="tel:216-268-2990" class="btn-secondary">
          <i class="fas fa-phone"></i>
          Call Now
        </a>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  isOpen: Boolean,
  modalData: Object
})

const emit = defineEmits(['close'])

const closeModal = () => {
  emit('close')
}

const scrollToQuote = () => {
  closeModal()
  setTimeout(() => {
    const el = document.querySelector('#quote-form')
    if (el) el.scrollIntoView({ behavior: 'smooth' })
  }, 300)
}

// Close modal on escape key
watch(() => props.isOpen, (isOpen) => {
  if (isOpen) {
    document.addEventListener('keydown', handleEscape)
    document.body.style.overflow = 'hidden'
  } else {
    document.removeEventListener('keydown', handleEscape)
    document.body.style.overflow = 'auto'
  }
})

const handleEscape = (e) => {
  if (e.key === 'Escape') {
    closeModal()
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 1rem;
}

.modal-content {
  background: white;
  border-radius: 16px;
  max-width: 600px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  position: relative;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.modal-close {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: none;
  border: none;
  font-size: 1.5rem;
  color: #666;
  cursor: pointer;
  z-index: 10;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.modal-close:hover {
  background: #f1f1f1;
  color: #333;
}

.modal-header {
  text-align: center;
  padding: 2rem 2rem 1rem;
  border-bottom: 1px solid #eee;
}

.modal-icon {
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1rem;
  font-size: 2rem;
  color: white;
}

.modal-header h2 {
  font-family: 'Playfair Display', serif;
  font-size: 2rem;
  color: #2c3e50;
  margin: 0;
}

.modal-body {
  padding: 2rem;
}

.modal-image {
  margin-bottom: 1.5rem;
  border-radius: 12px;
  overflow: hidden;
}

.modal-image img {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.modal-paragraph {
  margin-bottom: 1rem;
  line-height: 1.6;
  color: #555;
}

.modal-tips {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 12px;
  margin: 1.5rem 0;
}

.modal-tips h3 {
  color: #f39c12;
  margin-bottom: 1rem;
  font-size: 1.2rem;
}

.modal-tips ul {
  list-style: none;
  padding: 0;
}

.modal-tips li {
  padding: 0.5rem 0;
  padding-left: 1.5rem;
  position: relative;
}

.modal-tips li::before {
  content: '✓';
  position: absolute;
  left: 0;
  color: #27ae60;
  font-weight: bold;
}

.modal-features {
  margin: 1.5rem 0;
}

.modal-features h3 {
  color: #2c3e50;
  margin-bottom: 1rem;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem;
  background: #f8f9fa;
  border-radius: 8px;
}

.feature-item i {
  color: #f39c12;
  width: 20px;
}

.modal-pricing {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
  padding: 1.5rem;
  border-radius: 12px;
  margin: 1.5rem 0;
  text-align: center;
}

.modal-pricing h3 {
  margin-bottom: 1rem;
}

.price-range {
  font-size: 1.5rem;
  font-weight: bold;
  margin-bottom: 0.5rem;
}

.price-note {
  opacity: 0.9;
  font-size: 0.9rem;
}

.modal-footer {
  padding: 1.5rem 2rem;
  border-top: 1px solid #eee;
  display: flex;
  gap: 1rem;
  justify-content: center;
}

.btn-primary, .btn-secondary {
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  text-decoration: none;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
  border: none;
  cursor: pointer;
}

.btn-primary {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(243, 156, 18, 0.3);
}

.btn-secondary {
  background: transparent;
  color: #2c3e50;
  border: 2px solid #2c3e50;
}

.btn-secondary:hover {
  background: #2c3e50;
  color: white;
}

@media (max-width: 768px) {
  .modal-content {
    margin: 1rem;
    max-height: 95vh;
  }
  
  .modal-header {
    padding: 1.5rem 1rem 1rem;
  }
  
  .modal-body {
    padding: 1.5rem 1rem;
  }
  
  .modal-footer {
    padding: 1rem;
    flex-direction: column;
  }
  
  .features-grid {
    grid-template-columns: 1fr;
  }
}
</style>
