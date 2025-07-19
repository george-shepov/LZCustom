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
                <p>Northeast Ohio<br>& Surrounding Areas</p>
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
                
                <!-- Project Type Selection Cards -->
                <div class="project-selection">
                  <label class="section-label">Project Type *</label>
                  <div class="project-cards-grid">
                    <div
                      v-for="projectType in projectTypes"
                      :key="projectType.value"
                      class="project-card"
                      :class="{ 'selected': form.project === projectType.value }"
                      @click="selectProject(projectType.value)"
                      @mouseenter="showProjectHelp(projectType.value)"
                      @mouseleave="hideProjectHelp"
                    >
                      <div class="project-preview">
                        <img :src="projectType.images[0]" :alt="projectType.label" />
                      </div>
                      <div class="project-content">
                        <div class="project-icon">
                          <i :class="getProjectIcon(projectType.value)"></i>
                        </div>
                        <div class="project-info">
                          <h4>{{ projectType.label }}</h4>
                          <p>{{ projectType.description }}</p>
                        </div>
                      </div>
                      <div class="selection-indicator">
                        <i class="fas fa-check"></i>
                      </div>
                      <div class="project-help-tooltip" v-if="activeProjectHelp === projectType.value">
                        <div class="tooltip-content">
                          <h5>{{ getProjectHelpTitle(projectType.value) }}</h5>
                          <p>{{ getProjectHelpText(projectType.value) }}</p>
                          <div class="help-stats">
                            <span><i class="fas fa-clock"></i> {{ getProjectTimeline(projectType.value) }}</span>
                            <span><i class="fas fa-dollar-sign"></i> {{ getProjectBudgetRange(projectType.value) }}</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
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
                    <option value="planning">Just planning</option>
                  </select>
                </div>
              </div>

              <!-- Project-Specific Fields -->
              <div class="form-section" v-if="form.project">
                <h3>{{ getProjectTitle() }} Details</h3>
                
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

                <!-- Measurements Section -->
                <div class="measurements-section">
                  <h4>Measurements & Specifications</h4>
                  <div class="form-group">
                    <label>Room Dimensions</label>
                    <input v-model="form.roomDimensions" placeholder="e.g., 12' x 10' x 8' ceiling" />
                  </div>
                  <div class="form-group">
                    <label>Specific Measurements</label>
                    <textarea v-model="form.measurements" rows="3" 
                      placeholder="Please provide any specific measurements, dimensions, or technical requirements..."></textarea>
                  </div>
                </div>
              </div>

              <!-- Project Description -->
              <div class="form-section">
                <h3>Project Description</h3>
                <div class="form-group">
                  <label for="message">Tell us about your project *</label>
                  <div class="input-with-help">
                    <textarea
                      id="message"
                      v-model="form.message"
                      rows="5"
                      required
                      @focus="showDescriptionHelp = true"
                      @blur="showDescriptionHelp = false"
                      placeholder="Describe your vision, style preferences, any challenges, and what you hope to achieve..."
                    ></textarea>
                    <div class="help-bubble-inline" v-if="showDescriptionHelp">
                      <div class="help-content">
                        <h4><i class="fas fa-lightbulb"></i> Pro Tips for Better Estimates:</h4>
                        <ul>
                          <li>Include room dimensions if known</li>
                          <li>Mention your style preferences (modern, traditional, etc.)</li>
                          <li>Share your timeline and budget range</li>
                          <li>Note any special requirements or challenges</li>
                        </ul>
                      </div>
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
const activeProjectHelp = ref(null)

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

// Expanded project types with high-resolution images
const projectTypes = [
  {
    value: 'cabinets',
    label: 'Custom Cabinets',
    description: 'Handcrafted woodwork for kitchens & baths',
    images: [
      '/assets/gallery/projects/custom-cabinets-hd.png',
      '/assets/gallery/u6358423361_andcrafted_oak_kitchen_cabinets_with_soft-close_h_f3935a67-2994-44ce-b732-c95ad7de892f_2.png',
      '/assets/gallery/u6358423361_andcrafted_oak_kitchen_cabinets_with_soft-close_h_f3935a67-2994-44ce-b732-c95ad7de892f_3.png'
    ]
  },
  {
    value: 'countertops',
    label: 'Countertops',
    description: 'Premium stone surfaces',
    images: [
      '/assets/gallery/projects/kitchen-granite-hd.png',
      '/assets/gallery/u6358423361_Luxury_modern_kitchen_with_beautiful_granite_coun_07a300a5-aa75-4625-8165-3dcb4fe28efa_2.png',
      '/assets/gallery/u6358423361_Luxury_modern_kitchen_with_beautiful_granite_coun_07a300a5-aa75-4625-8165-3dcb4fe28efa_3.png'
    ]
  },
  {
    value: 'stone',
    label: 'Stone Fabrication',
    description: 'Precision cutting & installation',
    images: [
      '/assets/gallery/u6358423361_Beautiful_granite_slab_edge_detail_polished_stone_9bc42d53-abae-4c53-bee6-3a1b16a30a08_0.png',
      '/assets/gallery/u6358423361_Beautiful_granite_slab_edge_detail_polished_stone_9bc42d53-abae-4c53-bee6-3a1b16a30a08_2.png',
      '/assets/gallery/u6358423361_Beautiful_granite_slab_edge_detail_polished_stone_9bc42d53-abae-4c53-bee6-3a1b16a30a08_3.png'
    ]
  },
  {
    value: 'plastics',
    label: 'Plastics & Laminate',
    description: 'Durable commercial surfaces',
    images: [
      '/assets/gallery/u6358423361_Modern_commercial_office_space_with_durable_lamin_6e25e604-46fe-49e7-816f-423717499296_0.png',
      '/assets/gallery/u6358423361_Modern_commercial_office_space_with_durable_lamin_6e25e604-46fe-49e7-816f-423717499296_1.png',
      '/assets/gallery/u6358423361_Modern_commercial_office_space_with_durable_lamin_6e25e604-46fe-49e7-816f-423717499296_2.png'
    ]
  },
  {
    value: 'tile',
    label: 'Tile & Flooring',
    description: 'Expert installation services',
    images: [
      '/assets/gallery/u6358423361_Intricate_geometric_tile_pattern_flooring_expert__bec8e5ac-8a9c-4831-8c48-d865023de519_0.png',
      '/assets/gallery/u6358423361_Intricate_geometric_tile_pattern_flooring_expert__bec8e5ac-8a9c-4831-8c48-d865023de519_1.png',
      '/assets/gallery/u6358423361_Intricate_geometric_tile_pattern_flooring_expert__bec8e5ac-8a9c-4831-8c48-d865023de519_3.png'
    ]
  },
  {
    value: 'painting',
    label: 'Commercial Painting',
    description: 'Interior & exterior services',
    images: [
      '/assets/gallery/u6358423361_Professional_commercial_interior_painting_premium_fe294b7e-0227-404b-bed4-28fc32e6bb35_0.png',
      '/assets/gallery/u6358423361_Professional_commercial_interior_painting_premium_fe294b7e-0227-404b-bed4-28fc32e6bb35_1.png',
      '/assets/gallery/u6358423361_Professional_commercial_interior_painting_premium_fe294b7e-0227-404b-bed4-28fc32e6bb35_2.png'
    ]
  },
  {
    value: 'multiple',
    label: 'Multiple Services',
    description: 'Complete renovation projects',
    images: [
      '/assets/gallery/hero/hero-main-hd.png',
      '/assets/gallery/hero/hero-showroom-hd.png',
      '/assets/gallery/hero/hero-kitchen-hd.png'
    ]
  }
]

const selectProject = (projectValue) => {
  form.value.project = projectValue
  updateProjectFields()
}

const getProjectIcon = (projectType) => {
  const icons = {
    'cabinets': 'fas fa-hammer',
    'countertops': 'fas fa-gem',
    'stone': 'fas fa-mountain',
    'plastics': 'fas fa-layer-group',
    'tile': 'fas fa-th-large',
    'painting': 'fas fa-paint-roller',
    'multiple': 'fas fa-tools'
  }
  return icons[projectType] || 'fas fa-tools'
}

// Business Hours Logic
const businessStatus = computed(() => {
  const now = new Date()
  const day = now.getDay() // 0 = Sunday, 1 = Monday, etc.
  const hour = now.getHours()
  const minute = now.getMinutes()
  const currentTime = hour * 60 + minute

  // Check for major US holidays
  const isHoliday = checkHoliday(now)
  if (isHoliday) {
    return {
      class: 'closed',
      icon: 'fas fa-calendar-times',
      text: 'Closed for Holiday',
      details: `We'll reopen on our next business day`
    }
  }

  // Business hours: Mon-Fri 8AM-5PM, Sat 9AM-3PM, Sun Closed
  let isOpen = false
  let nextOpen = null
  let closingTime = null

  if (day >= 1 && day <= 5) { // Monday-Friday
    isOpen = currentTime >= 480 && currentTime < 1020 // 8AM-5PM
    closingTime = 1020
    if (!isOpen && currentTime < 480) {
      nextOpen = new Date(now)
      nextOpen.setHours(8, 0, 0, 0)
    }
  } else if (day === 6) { // Saturday
    isOpen = currentTime >= 540 && currentTime < 900 // 9AM-3PM
    closingTime = 900
    if (!isOpen && currentTime < 540) {
      nextOpen = new Date(now)
      nextOpen.setHours(9, 0, 0, 0)
    }
  }

  if (isOpen) {
    const minutesUntilClose = closingTime - currentTime
    const hoursUntilClose = Math.floor(minutesUntilClose / 60)
    const minsUntilClose = minutesUntilClose % 60
    
    return {
      class: 'open',
      icon: 'fas fa-clock',
      text: 'We\'re Open!',
      details: `Closing in ${hoursUntilClose}h ${minsUntilClose}m`
    }
  } else {
    // Calculate next opening
    if (!nextOpen) {
      nextOpen = new Date(now)
      if (day === 6) { // Saturday, next is Monday
        nextOpen.setDate(now.getDate() + 2)
        nextOpen.setHours(8, 0, 0, 0)
      } else if (day === 0) { // Sunday, next is Monday
        nextOpen.setDate(now.getDate() + 1)
        nextOpen.setHours(8, 0, 0, 0)
      } else { // Weekday after hours, next is tomorrow
        nextOpen.setDate(now.getDate() + 1)
        nextOpen.setHours(8, 0, 0, 0)
      }
    }

    const timeUntilOpen = nextOpen - now
    const hoursUntilOpen = Math.floor(timeUntilOpen / (1000 * 60 * 60))
    
    return {
      class: 'closed',
      icon: 'fas fa-moon',
      text: 'Currently Closed',
      details: `Opening in ${hoursUntilOpen} hours`
    }
  }
})

const checkHoliday = (date) => {
  const year = date.getFullYear()
  const month = date.getMonth()
  const day = date.getDate()
  
  // Major US holidays when businesses are typically closed
  const holidays = [
    new Date(year, 0, 1),   // New Year's Day
    new Date(year, 6, 4),   // Independence Day
    new Date(year, 11, 25), // Christmas Day
  ]
  
  return holidays.some(holiday => 
    holiday.getMonth() === month && holiday.getDate() === day
  )
}

const updateProjectFields = () => {
  // Reset project-specific fields when project type changes
  form.value.woodSpecies = ''
  form.value.cabinetStyle = ''
  form.value.materialType = ''
  form.value.squareFootage = ''
}

const getProjectTitle = () => {
  const titles = {
    cabinets: 'Custom Cabinets',
    countertops: 'Countertops',
    stone: 'Stone Fabrication',
    plastics: 'Plastics & Laminate',
    tile: 'Tile & Flooring',
    painting: 'Commercial Painting',
    multiple: 'Multiple Services'
  }
  return titles[form.value.project] || 'Project'
}



const submitForm = async () => {
  isSubmitting.value = true

  try {
    // Prepare form data with proper type conversion
    const formData = {
      ...form.value,
      squareFootage: form.value.squareFootage && form.value.squareFootage.trim() !== ''
        ? parseInt(form.value.squareFootage)
        : null
    }

    // Validate squareFootage if provided
    if (form.value.squareFootage && form.value.squareFootage.trim() !== '' && isNaN(parseInt(form.value.squareFootage))) {
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

const showProjectHelp = (projectValue) => {
  activeProjectHelp.value = projectValue
}

const hideProjectHelp = () => {
  activeProjectHelp.value = null
}

const getProjectHelpTitle = (projectValue) => {
  const titles = {
    'custom-cabinets': 'Custom Cabinet Installation',
    'countertops': 'Countertop Fabrication & Install',
    'stone-fabrication': 'Stone Fabrication Services',
    'plastics-laminate': 'Commercial Surface Solutions',
    'tile-flooring': 'Tile & Flooring Installation',
    'commercial-painting': 'Commercial Painting Services'
  }
  return titles[projectValue] || 'Project Information'
}

const getProjectHelpText = (projectValue) => {
  const descriptions = {
    'custom-cabinets': 'Full-service cabinet design, fabrication, and installation using premium hardwoods. Includes soft-close hardware and custom storage solutions.',
    'countertops': 'Professional templating, precision cutting, and expert installation of natural stone surfaces with lifetime craftsmanship warranty.',
    'stone-fabrication': 'Complete stone fabrication services including cutting, polishing, and edge profiling for residential and commercial projects.',
    'plastics-laminate': 'Durable, chemical-resistant surfaces perfect for high-traffic commercial environments with easy maintenance requirements.',
    'tile-flooring': 'Expert tile installation with waterproof systems, precision layout, and professional grouting for lasting results.',
    'commercial-painting': 'Industrial-grade coatings and finishes designed for commercial environments with superior durability and protection.'
  }
  return descriptions[projectValue] || 'Professional installation and fabrication services.'
}

const getProjectTimeline = (projectValue) => {
  const timelines = {
    'custom-cabinets': '4-6 weeks',
    'countertops': '2-3 weeks',
    'stone-fabrication': '2-4 weeks',
    'plastics-laminate': '1-2 weeks',
    'tile-flooring': '1-3 weeks',
    'commercial-painting': '1-2 weeks'
  }
  return timelines[projectValue] || '2-4 weeks'
}

const getProjectBudgetRange = (projectValue) => {
  const budgets = {
    'custom-cabinets': '$15k-50k+',
    'countertops': '$3k-15k',
    'stone-fabrication': '$2k-20k',
    'plastics-laminate': '$1k-10k',
    'tile-flooring': '$2k-12k',
    'commercial-painting': '$1k-8k'
  }
  return budgets[projectValue] || 'Varies'
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Playfair+Display:wght@400;500;600;700&display=swap');

.quote-section {
  background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
  font-family: 'Inter', sans-serif;
  font-size: 16px;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
}

.section-padding {
  padding: 5rem 0;
}

.quote-container {
  display: flex;
  flex-direction: column;
}

.quote-header {
  text-align: center;
  margin-bottom: 3rem;
}

.section-title {
  font-family: 'Playfair Display', serif;
  font-size: clamp(2.5rem, 5vw, 3.5rem);
  color: #1e293b;
  font-weight: 600;
  margin-bottom: 1rem;
}

.section-subtitle {
  font-size: 1.4rem;
  color: #64748b;
  max-width: 600px;
  margin: 0 auto;
}

.quote-content {
  display: grid;
  grid-template-columns: 2fr 3fr;
  gap: 3rem;
  align-items: start;
}

.contact-info {
  background: white;
  padding: 2rem;
  border-radius: 16px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
  height: fit-content;
  position: sticky;
  top: 2rem;
}

.business-status {
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  margin-bottom: 2rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  border-left: 4px solid;
}

.business-status.open {
  border-left-color: #10b981;
  background: linear-gradient(135deg, #ecfdf5 0%, #f0fdf4 100%);
}

.business-status.closed {
  border-left-color: #f59e0b;
  background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%);
}

.status-indicator {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.5rem;
}

.status-text {
  font-weight: 600;
  font-size: 1.1rem;
}

.status-details {
  font-size: 0.9rem;
  opacity: 0.8;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.contact-icon {
  width: 50px;
  height: 50px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.2rem;
}

.contact-text h4 {
  color: #1e293b;
  margin-bottom: 0.25rem;
  font-weight: 600;
}

.contact-text a {
  color: #3b82f6;
  text-decoration: none;
  font-weight: 500;
}

.contact-text a:hover {
  text-decoration: underline;
}

.quote-form {
  background: white;
  padding: 3rem;
  border-radius: 16px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
  max-width: none;
}

.form-section {
  margin-bottom: 2.5rem;
  padding-bottom: 2rem;
  border-bottom: 1px solid #e2e8f0;
}

.form-section:last-child {
  border-bottom: none;
}

.form-section h3 {
  font-family: 'Playfair Display', serif;
  color: #1e293b;
  margin-bottom: 1.5rem;
  font-size: 1.4rem;
  font-weight: 600;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-bottom: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  font-weight: 600;
  color: #374151;
  font-size: 1rem;
  margin-bottom: 0.5rem;
}

.form-group input,
.form-group select,
.form-group textarea {
  border: 2px solid #cbd5e1;
  border-radius: 8px;
  padding: 1rem 1.25rem;
  font-size: 1.1rem;
  transition: all 0.2s ease;
  background: white;
  font-family: 'Inter', sans-serif;
  width: 100%;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #f39c12;
  box-shadow: 0 0 0 3px rgba(243, 156, 18, 0.15), 0 2px 8px rgba(0, 0, 0, 0.1);
}

.input-with-help {
  position: relative;
}

.help-bubble-inline {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  z-index: 10;
  margin-top: 0.5rem;
  animation: slideDown 0.3s ease;
}

.help-content {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
  padding: 1rem;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(243, 156, 18, 0.3);
  position: relative;
}

.help-content::before {
  content: '';
  position: absolute;
  top: -8px;
  left: 20px;
  border: 8px solid transparent;
  border-bottom-color: #f39c12;
}

.help-content h4 {
  margin: 0 0 0.75rem 0;
  font-size: 1rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.help-content ul {
  margin: 0;
  padding-left: 1.2rem;
  list-style: none;
}

.help-content li {
  margin-bottom: 0.5rem;
  position: relative;
  line-height: 1.4;
}

.help-content li::before {
  content: '✓';
  position: absolute;
  left: -1.2rem;
  color: rgba(255, 255, 255, 0.9);
  font-weight: bold;
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

/* Project Selection Styles */
.project-selection {
  margin-bottom: 2rem;
}

.section-label {
  display: block;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 1rem;
  font-size: 1.1rem;
}

.project-cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.project-card {
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  padding: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
  height: 140px;
  display: flex;
  align-items: center;
}

.project-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #f39c12, #e67e22);
  transform: scaleX(0);
  transition: transform 0.3s ease;
}

.project-card {
  position: relative;
}

.project-card:hover {
  border-color: #f39c12;
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(243, 156, 18, 0.15);
}

.project-help-tooltip {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  z-index: 20;
  margin-top: 0.5rem;
  animation: fadeInUp 0.3s ease;
}

.tooltip-content {
  background: white;
  border: 2px solid #f39c12;
  border-radius: 12px;
  padding: 1rem;
  box-shadow: 0 8px 25px rgba(243, 156, 18, 0.2);
  position: relative;
}

.tooltip-content::before {
  content: '';
  position: absolute;
  top: -8px;
  left: 20px;
  border: 8px solid transparent;
  border-bottom-color: #f39c12;
}

.tooltip-content h5 {
  margin: 0 0 0.5rem 0;
  color: #2c3e50;
  font-size: 1rem;
  font-weight: 600;
}

.tooltip-content p {
  margin: 0 0 0.75rem 0;
  color: #64748b;
  font-size: 0.9rem;
  line-height: 1.4;
}

.help-stats {
  display: flex;
  gap: 1rem;
  font-size: 0.8rem;
  color: #f39c12;
  font-weight: 500;
}

.help-stats span {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.project-card.selected {
  border-color: #f39c12;
  background: linear-gradient(135deg, #fff9f0 0%, #fef7ed 100%);
  box-shadow: 0 8px 25px rgba(243, 156, 18, 0.2);
}

.project-card.selected::before {
  transform: scaleX(1);
}

.project-preview {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  overflow: hidden;
  margin-right: 1rem;
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.project-preview img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.project-content {
  display: flex;
  align-items: center;
  flex: 1;
}

.project-icon {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.2rem;
  margin-right: 1rem;
  flex-shrink: 0;
}

.project-info {
  flex: 1;
}

.project-info h4 {
  font-family: 'Playfair Display', serif;
  font-size: 1.1rem;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.25rem;
}

.project-info p {
  color: #64748b;
  font-size: 0.85rem;
  line-height: 1.3;
}

.selection-indicator {
  position: absolute;
  top: 1rem;
  right: 1rem;
  width: 24px;
  height: 24px;
  background: #f39c12;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transform: scale(0.8);
  transition: all 0.3s ease;
}

.project-card.selected .selection-indicator {
  opacity: 1;
  transform: scale(1);
}

.selection-indicator i {
  color: white;
  font-size: 0.8rem;
}

.measurements-section {
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid #f1f5f9;
}

.measurements-section h4 {
  color: #475569;
  margin-bottom: 1rem;
  font-size: 1.1rem;
  font-weight: 500;
}

.submit-btn {
  background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 8px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  font-family: 'Inter', sans-serif;
  width: 100%;
}

.submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 25px rgba(30, 41, 59, 0.3);
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
  font-size: 4rem;
  color: #10b981;
  margin-bottom: 1.5rem;
}

.success-message h3 {
  font-family: 'Playfair Display', serif;
  color: #1e293b;
  margin-bottom: 1rem;
  font-size: 2rem;
}

.btn-secondary {
  background: transparent;
  color: #3b82f6;
  border: 2px solid #3b82f6;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-top: 1rem;
}

.btn-secondary:hover {
  background: #3b82f6;
  color: white;
}

/* Mobile Responsiveness */
@media (max-width: 1024px) {
  .quote-content {
    grid-template-columns: 1fr;
    gap: 2rem;
  }
  
  .contact-info {
    position: static;
  }
  
  .quote-form {
    padding: 2.5rem;
  }
}

@media (max-width: 768px) {
  .quote-form {
    padding: 1.5rem;
  }
  
  .container {
    padding: 0 1rem;
  }
}

@media (max-width: 480px) {
  .project-cards-grid {
    grid-template-columns: 1fr;
  }
  
  .section-padding {
    padding: 3rem 0;
  }
}
</style>
