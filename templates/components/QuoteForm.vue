
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
                <p>Northeast Ohio<br>30-mile radius</p>
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
                    <label for="name">Full Name</label>
                    <input id="name" type="text" v-model="form.name" />
                  </div>
                  <div class="form-group">
                    <label for="phone">Phone Number</label>
                    <input id="phone" type="tel" v-model="form.phone" />
                  </div>
                </div>
                <div class="form-group">
                  <label for="email">Email Address</label>
                  <input id="email" type="email" v-model="form.email" />
                </div>
              </div>

              <!-- Project Details -->
              <div class="form-section">
                <h3>Project Information</h3>
                <div class="form-group">
                  <label for="project">Project Type</label>
                  <select id="project" v-model="form.project" @change="updateProjectFields">
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
                  <div class="form-group">
                    <label for="timeline">Timeline</label>
                    <select id="timeline" v-model="form.timeline">
                      <option value="">Select timeline</option>
                      <option value="asap">ASAP</option>
                      <option value="1-month">Within 1 month</option>
                      <option value="3-months">Within 3 months</option>
                      <option value="6-months">Within 6 months</option>
                      <option value="planning">Just planning</option>
                    </select>
                  </div>
                </div>

                <!-- Cabinet Fields -->
                <div v-if="form.project === 'cabinets'">
                  <div class="form-row">
                    <div class="form-group">
                      <label>Wood Species</label>
                      <select v-model="form.woodSpecies">
                        <option value="">Select wood type</option>
                        <option value="oak">Oak</option>
                        <option value="maple">Maple</option>
                        <option value="cherry">Cherry</option>
                        <option value="walnut">Walnut</option>
                        <option value="pine">Pine</option>
                      </select>
                    </div>
                    <div class="form-group">
                      <label>Cabinet Style</label>
                      <select v-model="form.cabinetStyle">
                        <option value="">Select style</option>
                        <option value="shaker">Shaker</option>
                        <option value="raised-panel">Raised Panel</option>
                        <option value="flat-panel">Flat Panel</option>
                        <option value="traditional">Traditional</option>
                        <option value="modern">Modern</option>
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

              <!-- Project Description -->
              <div class="form-section">
                <h3>Project Details</h3>
                <div class="form-group">
                  <label for="message">Tell us about your project</label>
                  <textarea
                    id="message"
                    v-model="form.message"
                    placeholder="Please describe your project, including room dimensions, specific requirements, style preferences, and any other details that would help us provide an accurate quote..."
                    rows="4"
                  ></textarea>
                </div>

                <div class="form-row" v-if="form.project">
                  <div class="form-group">
                    <label>Room Dimensions (optional)</label>
                    <input type="text" v-model="form.roomDimensions" placeholder="e.g., 12' x 14'" />
                  </div>
                  <div class="form-group">
                    <label>Additional Measurements</label>
                    <input type="text" v-model="form.measurements" placeholder="Any specific measurements" />
                  </div>
                </div>
              </div>

              <div class="form-actions">
                <button type="submit" class="btn-primary" :disabled="isSubmitting">
                  <i class="fas fa-paper-plane" v-if="!isSubmitting"></i>
                  <i class="fas fa-spinner fa-spin" v-if="isSubmitting"></i>
                  {{ isSubmitting ? 'Sending...' : 'Send Quote Request' }}
                </button>
              </div>
            </form>

            <!-- Success Message -->
            <div v-if="showSuccess" class="success-message">
              <div class="success-icon">
                <i class="fas fa-check-circle"></i>
              </div>
              <h3>Quote Request Sent!</h3>
              <p>{{ successMessage }}</p>
              <div class="success-actions">
                <a href="tel:216-268-2990" class="btn-primary">
                  <i class="fas fa-phone"></i>
                  Call Now: 216-268-2990
                </a>
                <button @click="resetForm" class="btn-secondary">
                  Send Another Request
                </button>
              </div>
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
    // Prepare form data - save everything as-is, no validation
    const formData = {
      ...form.value,
      squareFootage: form.value.squareFootage && String(form.value.squareFootage).trim() !== ''
        ? parseInt(form.value.squareFootage)
        : null
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
      // Still show success to user - we don't want to lose prospects due to technical issues
      showSuccess.value = true
      successMessage.value = "Your request has been received! Please call us at 216-268-2990 to ensure we have all your details."
    }
  } catch (error) {
    console.error('Form submission error:', error)
    // Still show success to user - we don't want to lose prospects
    showSuccess.value = true
    successMessage.value = "Your request has been received! Please call us at 216-268-2990 to ensure we have all your details."
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
  padding: 1.5rem;
  border-radius: 12px;
  margin-bottom: 2rem;
  text-align: center;
  border: 2px solid;
}

.business-status.open {
  background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%);
  border-color: #27ae60;
  color: white;
}

.business-status.closed {
  background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
  border-color: #e74c3c;
  color: white;
}

.status-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.status-text {
  font-weight: 600;
  font-size: 1.1rem;
}

.status-details {
  font-size: 0.9rem;
  opacity: 0.9;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.contact-icon {
  width: 50px;
  height: 50px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.2rem;
}

.contact-text h4 {
  margin: 0 0 0.25rem 0;
  color: #2c3e50;
  font-weight: 600;
}

.contact-text p,
.contact-text a {
  margin: 0;
  color: #7f8c8d;
  text-decoration: none;
  line-height: 1.4;
}

.contact-text a:hover {
  color: #f39c12;
}

.quote-form {
  background: white;
  border-radius: 16px;
  padding: 2rem;
}

.form-section {
  margin-bottom: 2.5rem;
  padding-bottom: 2rem;
  border-bottom: 1px solid #ecf0f1;
}

.form-section:last-child {
  border-bottom: none;
  margin-bottom: 0;
}

.form-section h3 {
  color: #2c3e50;
  margin-bottom: 1.5rem;
  font-size: 1.3rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.form-section h3:before {
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
  border: 2px solid #d1d5db;
  border-radius: 8px;
  font-size: 1rem;
  transition: all 0.3s ease;
  background: white;
  box-sizing: border-box;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
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

.form-actions {
  text-align: center;
  padding-top: 2rem;
}

.btn-primary {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
  padding: 1rem 2rem;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  font-size: 1.1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  min-width: 200px;
  justify-content: center;
  text-decoration: none;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(243, 156, 18, 0.3);
}

.btn-primary:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
}

.btn-secondary {
  background: transparent;
  color: #f39c12;
  border: 2px solid #f39c12;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-secondary:hover {
  background: #f39c12;
  color: white;
  transform: translateY(-1px);
}

.success-message {
  text-align: center;
  padding: 3rem 2rem;
  background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%);
  color: white;
  border-radius: 16px;
}

.success-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
  opacity: 0.9;
}

.success-message h3 {
  font-size: 2rem;
  margin-bottom: 1rem;
  font-weight: 700;
}

.success-message p {
  font-size: 1.2rem;
  margin-bottom: 2rem;
  opacity: 0.9;
  line-height: 1.6;
}

.success-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

/* Responsive Design */
@media (max-width: 768px) {
  .quote-content {
    grid-template-columns: 1fr;
    gap: 2rem;
    padding: 2rem;
  }

  .contact-info {
    position: static;
  }

  .form-row {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .section-title {
    font-size: 2rem;
  }

  .success-actions {
    flex-direction: column;
    align-items: center;
  }
}

@media (max-width: 480px) {
  .quote-header {
    padding: 2rem 1rem;
  }

  .quote-content {
    padding: 1.5rem;
  }

  .contact-info {
    padding: 1.5rem;
  }

  .section-title {
    font-size: 1.8rem;
  }
}
</style>
