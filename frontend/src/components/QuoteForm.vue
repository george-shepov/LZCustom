
<template>
  <section id="quote-form" class="quote-section section-padding">
    <div class="container">
      <div class="quote-container">
        <div class="quote-header">
          <h2 class="section-title">Get Your Free Quote</h2>
          <p class="section-subtitle">Ready to start your project? Tell us about your vision and we'll provide a detailed quote.</p>
        </div>

        <div class="quote-content">
          <div class="contact-info">
            <div class="business-status" :class="businessStatus.class">
              <div class="status-indicator">
                <i :class="businessStatus.icon"></i>
                <span class="status-text">{{ businessStatus.text }}</span>
              </div>
              <div class="status-details">{{ businessStatus.details }}</div>
            </div>

            <div class="contact-item">
              <div class="contact-icon">
                <i class="fas fa-phone"></i>
              </div>
              <div class="contact-text">
                <h4>Call Us</h4>
                <a href="tel:216-268-2990">216-268-2990</a>
              </div>
            </div>

            <div class="contact-item">
              <div class="contact-icon">
                <i class="fas fa-clock"></i>
              </div>
              <div class="contact-text">
                <h4>Business Hours</h4>
                <p>Mon-Fri: 8AM-5PM<br>Sat: 9AM-3PM<br>Sun: Closed</p>
              </div>
            </div>

            <div class="contact-item">
              <div class="contact-icon">
                <i class="fas fa-map-marker-alt"></i>
              </div>
              <div class="contact-text">
                <h4>Service Area</h4>
                <p>30-mile radius from Cleveland<br>Free estimates within our service area</p>
              </div>
            </div>
          </div>

          <div class="quote-form">
            <form @submit.prevent="submitForm" v-if="!showSuccess">
              <!-- Basic Info -->
              <div class="form-section">
                <h3>Contact Information</h3>
                <div class="form-row">
                  <div class="form-group">
                    <label for="name">Full Name *</label>
                    <input id="name" type="text" v-model="form.name" required />
                  </div>
                  <div class="form-group">
                    <label for="phone">Phone Number *</label>
                    <input id="phone" type="tel" v-model="form.phone" required />
                  </div>
                </div>
                <div class="form-group">
                  <label for="email">Email Address *</label>
                  <input id="email" type="email" v-model="form.email" required />
                </div>
              </div>

              <!-- Project Details -->
              <div class="form-section">
                <h3>Project Information</h3>
                <div class="form-group">
                  <label for="project">Project Type *</label>
                  <select id="project" v-model="form.project" required @change="updateProjectFields">
                    <option value="">Select your project type</option>
                    <option value="cabinets">Custom Cabinets</option>
                    <option value="countertops">Countertops</option>
                    <option value="stone">Stone Fabrication</option>
                    <option value="plastics">Plastics & Laminate</option>
                    <option value="tile">Tile & Flooring</option>
                    <option value="painting">Commercial Painting</option>
                    <option value="multiple">Multiple Services</option>
                  </select>
                </div>

                <div class="form-row">
                  <div class="form-group">
                    <label for="budget">Budget Range</label>
                    <select id="budget" v-model="form.budget">
                      <option value="">Select budget range</option>
                      <option value="under-5k">Under $5,000</option>
                      <option value="5k-15k">$5,000 - $15,000</option>
                      <option value="15k-30k">$15,000 - $30,000</option>
                      <option value="30k-50k">$30,000 - $50,000</option>
                      <option value="over-50k">Over $50,000</option>
                    </select>
                  </div>
                </div>
                <div class="form-group">
                  <label for="timeline">Project Timeline</label>
                  <select id="timeline" v-model="form.timeline">
                    <option value="">Select timeline</option>
                    <option value="asap">ASAP</option>
                    <option value="1-month">Within 1 month</option>
                    <option value="3-months">Within 3 months</option>
                    <option value="6-months">Within 6 months</option>
                    <option value="planning">Just planning ahead</option>
                  </select>
                </div>

                <!-- Cabinet Fields -->
                <div v-if="form.project === 'cabinets'">
                  <div class="form-row">
                    <div class="form-group">
                      <label>Wood Species</label>
                      <select v-model="form.woodSpecies">
                        <option value="">Select wood</option>
                        <option value="oak">Oak</option>
                        <option value="maple">Maple</option>
                        <option value="cherry">Cherry</option>
                        <option value="hickory">Hickory</option>
                        <option value="walnut">Walnut</option>
                      </select>
                    </div>
                    <div class="form-group">
                      <label>Cabinet Style</label>
                      <select v-model="form.cabinetStyle">
                        <option value="">Select style</option>
                        <option value="shaker">Shaker</option>
                        <option value="raised-panel">Raised Panel</option>
                        <option value="flat-panel">Flat Panel</option>
                        <option value="custom">Custom Design</option>
                      </select>
                    </div>
                  </div>
                </div>

                <!-- Countertop Fields -->
                <div v-if="form.project === 'countertops'">
                  <div class="form-row">
                    <div class="form-group">
                      <label>Material Type</label>
                      <select v-model="form.materialType">
                        <option value="">Select material</option>
                        <option value="granite">Granite</option>
                        <option value="quartz">Engineered Quartz</option>
                        <option value="marble">Marble</option>
                        <option value="quartzite">Quartzite</option>
                      </select>
                    </div>
                    <div class="form-group">
                      <label>Approximate Square Footage</label>
                      <input type="number" v-model="form.squareFootage" placeholder="e.g., 45" min="1" step="1" />
                    </div>
                  </div>
                </div>
              </div>

              <button type="submit" class="submit-btn" :disabled="isSubmitting">
                <span v-if="!isSubmitting">
                  <i class="fas fa-paper-plane"></i>
                  Send Request
                </span>
                <span v-else>
                  <i class="fas fa-spinner fa-spin"></i>
                  Sending...
                </span>
              </button>
            </form>

            <!-- Success Message -->
            <div v-if="showSuccess" class="success-message">
              <div class="success-icon">
                <i class="fas fa-check-circle"></i>
              </div>
              <h3>Thank You!</h3>
              <p>{{ successMessage }}</p>
              <button @click="resetForm" class="btn-secondary">Submit Another Quote</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, computed } from 'vue'

const isSubmitting = ref(false)
const showSuccess = ref(false)
const successMessage = ref('')
const showDescriptionHelp = ref(false)

const form = ref({
  name: '',
  email: '',
  phone: '',
  project: '',
  budget: '',
  timeline: '',
  message: '',
  // Project-specific fields
  woodSpecies: '',
  cabinetStyle: '',
  materialType: '',
  squareFootage: '',
  roomDimensions: '',
  measurements: ''
})

// Business status computed property
const businessStatus = computed(() => {
  const now = new Date()
  const day = now.getDay() // 0 = Sunday, 1 = Monday, etc.
  const hour = now.getHours()

  // Business hours: Mon-Fri 8AM-5PM, Sat 9AM-3PM, Sun Closed
  const isWeekday = day >= 1 && day <= 5
  const isSaturday = day === 6
  const isSunday = day === 0

  if (isSunday) {
    return {
      class: 'closed',
      icon: 'fas fa-moon',
      text: 'Closed Today',
      details: 'We\'ll respond first thing Monday morning!'
    }
  }

  if (isWeekday && hour >= 8 && hour < 17) {
    return {
      class: 'open',
      icon: 'fas fa-circle',
      text: 'Open Now',
      details: 'Call now for immediate assistance!'
    }
  }

  if (isSaturday && hour >= 9 && hour < 15) {
    return {
      class: 'open',
      icon: 'fas fa-circle',
      text: 'Open Now',
      details: 'Saturday hours: 9AM-3PM'
    }
  }

  return {
    class: 'closed',
    icon: 'fas fa-moon',
    text: 'Currently Closed',
    details: 'We\'ll respond during our next business hours!'
  }
})

const updateProjectFields = () => {
  // Reset project-specific fields when project type changes
  form.value.woodSpecies = ''
  form.value.cabinetStyle = ''
  form.value.materialType = ''
  form.value.squareFootage = ''
}

const submitForm = async () => {
  isSubmitting.value = true

  try {
    // Prepare form data with proper type conversion
    const formData = {
      ...form.value,
      squareFootage: form.value.squareFootage && String(form.value.squareFootage).trim() !== ''
        ? parseInt(form.value.squareFootage)
        : null
    }

    // Validate squareFootage if provided
    if (form.value.squareFootage && String(form.value.squareFootage).trim() !== '' && isNaN(parseInt(form.value.squareFootage))) {
      alert('Please enter a valid number for square footage.')
      return
    }

    console.log('Submitting form data:', formData)

    const response = await fetch('/api/prospects', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(formData)
    })

    console.log('Response status:', response.status)

    if (response.ok) {
      const result = await response.json()
      console.log('Success response:', result)
      showSuccess.value = true
      successMessage.value = businessStatus.value.class === 'open'
        ? "We'll contact you within 2 hours to discuss your project!"
        : "We'll contact you first thing during our next business hours!"
    } else {
      const errorData = await response.text()
      console.error('Error response:', response.status, errorData)
      throw new Error(`Server error: ${response.status}`)
    }
  } catch (error) {
    console.error('Form submission error:', error)
    alert(`There was an error submitting your request: ${error.message}. Please try again or call us directly at 216-268-2990.`)
  } finally {
    isSubmitting.value = false
  }
}

const resetForm = () => {
  showSuccess.value = false
  form.value = {
    name: '',
    email: '',
    phone: '',
    project: '',
    budget: '',
    timeline: '',
    message: '',
    woodSpecies: '',
    cabinetStyle: '',
    materialType: '',
    squareFootage: '',
    roomDimensions: '',
    measurements: ''
  }
}
</script>

<style scoped>
.quote-section {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  position: relative;
  overflow: hidden;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
  position: relative;
  z-index: 1;
}

.quote-container {
  background: white;
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.quote-header {
  text-align: center;
  padding: 3rem 2rem 2rem;
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  color: white;
  position: relative;
}

.section-title {
  font-family: 'Playfair Display', serif;
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 1rem;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.section-subtitle {
  font-size: 1.2rem;
  opacity: 0.9;
  max-width: 600px;
  margin: 0 auto;
  line-height: 1.6;
}

.quote-content {
  display: grid;
  grid-template-columns: 1fr 2fr;
  gap: 3rem;
  padding: 3rem;
}

.contact-info {
  background: #f8f9fa;
  padding: 2rem;
  border-radius: 16px;
  height: fit-content;
  position: sticky;
  top: 2rem;
}

.business-status {
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  margin-bottom: 2rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  border-left: 4px solid #f39c12;
}

.business-status.open {
  border-left-color: #27ae60;
}

.business-status.closed {
  border-left-color: #e74c3c;
}

.status-indicator {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.5rem;
}

.status-indicator i {
  font-size: 0.9rem;
}

.business-status.open .status-indicator i {
  color: #27ae60;
  animation: pulse 2s infinite;
}

.business-status.closed .status-indicator i {
  color: #e74c3c;
}

.status-text {
  font-weight: 600;
  font-size: 1.1rem;
}

.status-details {
  font-size: 0.9rem;
  color: #666;
  font-style: italic;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.contact-item {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: white;
  border-radius: 12px;
  transition: all 0.3s ease;
}

.contact-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.contact-icon {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1rem;
  flex-shrink: 0;
}

.contact-text h4 {
  margin: 0 0 0.5rem 0;
  color: #2c3e50;
  font-weight: 600;
}

.contact-text p {
  margin: 0;
  color: #666;
  line-height: 1.4;
}

.contact-text a {
  color: #f39c12;
  text-decoration: none;
  font-weight: 600;
  font-size: 1.1rem;
}

.contact-text a:hover {
  color: #e67e22;
}

.quote-form {
  background: white;
}

.form-section {
  margin-bottom: 2.5rem;
  padding-bottom: 2rem;
  border-bottom: 1px solid #eee;
}

.form-section:last-of-type {
  border-bottom: none;
  margin-bottom: 0;
}

.form-section h3 {
  color: #2c3e50;
  font-size: 1.4rem;
  font-weight: 600;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.form-section h3::before {
  content: '';
  width: 4px;
  height: 20px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-radius: 2px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  color: #2c3e50;
  font-weight: 600;
  font-size: 0.95rem;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 0.875rem 1rem;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  font-size: 1rem;
  transition: all 0.3s ease;
  background: white;
  box-sizing: border-box;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #f39c12;
  box-shadow: 0 0 0 3px rgba(243, 156, 18, 0.1);
  transform: translateY(-1px);
}

.form-group textarea {
  resize: vertical;
  min-height: 100px;
  font-family: inherit;
}

.measurements-section {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 12px;
  margin-top: 1.5rem;
}

.measurements-section h4 {
  color: #2c3e50;
  margin-bottom: 1rem;
  font-size: 1.1rem;
}

.input-with-help {
  position: relative;
}

.help-bubble-inline {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: white;
  border: 2px solid #f39c12;
  border-radius: 12px;
  padding: 1rem;
  margin-top: 0.5rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  z-index: 10;
  animation: slideDown 0.3s ease;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.help-content h4 {
  color: #f39c12;
  margin-bottom: 0.75rem;
  font-size: 1rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.help-content ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.help-content li {
  padding: 0.25rem 0;
  padding-left: 1.5rem;
  position: relative;
  color: #666;
  font-size: 0.9rem;
}

.help-content li::before {
  content: '✓';
  position: absolute;
  left: 0;
  color: #27ae60;
  font-weight: bold;
}

.submit-btn {
  width: 100%;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-top: 2rem;
}

.submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(243, 156, 18, 0.3);
}

.submit-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.success-message {
  text-align: center;
  padding: 3rem 2rem;
}

.success-icon {
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1.5rem;
  font-size: 2rem;
  color: white;
  animation: successPulse 0.6s ease;
}

@keyframes successPulse {
  0% {
    transform: scale(0);
  }
  50% {
    transform: scale(1.1);
  }
  100% {
    transform: scale(1);
  }
}

.success-message h3 {
  color: #2c3e50;
  font-size: 1.8rem;
  margin-bottom: 1rem;
}

.success-message p {
  color: #666;
  font-size: 1.1rem;
  margin-bottom: 2rem;
  line-height: 1.6;
}

.btn-secondary {
  background: transparent;
  color: #2c3e50;
  border: 2px solid #2c3e50;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-secondary:hover {
  background: #2c3e50;
  color: white;
}

/* Mobile Responsiveness */
@media (max-width: 768px) {
  .quote-content {
    grid-template-columns: 1fr;
    gap: 2rem;
    padding: 2rem 1.5rem;
  }

  .contact-info {
    position: static;
    order: 2;
  }

  .quote-form {
    order: 1;
  }

  .form-row {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .section-title {
    font-size: 2rem;
  }

  .quote-header {
    padding: 2rem 1rem;
  }

  .container {
    padding: 0 1rem;
  }
}

@media (max-width: 480px) {
  .section-title {
    font-size: 1.8rem;
  }

  .section-subtitle {
    font-size: 1rem;
  }

  .quote-content {
    padding: 1.5rem 1rem;
  }

  .contact-info {
    padding: 1.5rem;
  }

  .form-section h3 {
    font-size: 1.2rem;
  }
}
</style>
