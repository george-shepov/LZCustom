<template>
  <div class="admin-dashboard">
    <div class="container">
      <div class="dashboard-header">
        <h1>LZ Custom - Admin Dashboard</h1>

        <!-- Navigation Tabs -->
        <div class="nav-tabs">
          <button
            @click="activeTab = 'leads'"
            :class="{ active: activeTab === 'leads' }"
            class="nav-tab"
          >
            <i class="fas fa-users"></i>
            Lead Management
          </button>
          <button
            @click="activeTab = 'llm'"
            :class="{ active: activeTab === 'llm' }"
            class="nav-tab"
          >
            <i class="fas fa-robot"></i>
            AI Configuration
          </button>
          <button
            @click="activeTab = 'analytics'"
            :class="{ active: activeTab === 'analytics' }"
            class="nav-tab"
          >
            <i class="fas fa-chart-bar"></i>
            Analytics
          </button>
        </div>

        <!-- Stats Grid (shown on leads tab) -->
        <div v-if="activeTab === 'leads'" class="stats-grid">
          <div class="stat-card">
            <div class="stat-number">{{ prospects.length }}</div>
            <div class="stat-label">Total Leads</div>
          </div>
          <div class="stat-card high-priority">
            <div class="stat-number">{{ highPriorityCount }}</div>
            <div class="stat-label">High Priority</div>
          </div>
          <div class="stat-card">
            <div class="stat-number">{{ newLeadsCount }}</div>
            <div class="stat-label">New Today</div>
          </div>
          <div class="stat-card">
            <div class="stat-number">{{ chatStats.total || 0 }}</div>
            <div class="stat-label">Chat Conversations</div>
          </div>
        </div>
      </div>

      <!-- Leads Management Tab -->
      <div v-if="activeTab === 'leads'" class="prospects-table">
        <div class="table-header">
          <h2>Lead Inquiries</h2>
          <div class="table-controls">
            <input
              v-model="searchQuery"
              placeholder="Search leads..."
              class="search-input"
            />
            <select v-model="statusFilter" class="filter-select">
              <option value="">All Status</option>
              <option value="new">New</option>
              <option value="contacted">Contacted</option>
              <option value="quoted">Quoted</option>
              <option value="won">Won</option>
              <option value="lost">Lost</option>
            </select>
          </div>
        </div>

        <table>
          <thead>
            <tr>
              <th>Priority</th>
              <th>Name</th>
              <th>Project</th>
              <th>Budget</th>
              <th>Timeline</th>
              <th>Contact</th>
              <th>Date</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="prospect in filteredProspects" :key="prospect.id"
                :class="{ 'high-priority': prospect.priority === 'high' }">
              <td>
                <span class="priority-badge" :class="prospect.priority">
                  {{ prospect.priority }}
                </span>
              </td>
              <td class="name-cell">
                <strong>{{ prospect.name || 'No name provided' }}</strong>
              </td>
              <td>{{ formatProjectType(prospect.project_type) }}</td>
              <td>{{ formatBudget(prospect.budget_range) }}</td>
              <td>{{ formatTimeline(prospect.timeline) }}</td>
              <td>
                <div class="contact-info">
                  <a v-if="prospect.phone" :href="`tel:${prospect.phone}`">{{ prospect.phone }}</a>
                  <a v-if="prospect.email" :href="`mailto:${prospect.email}`">{{ prospect.email }}</a>
                  <span v-if="!prospect.phone && !prospect.email" class="no-contact">No contact info</span>
                </div>
              </td>
              <td>{{ formatDate(prospect.created_at) }}</td>
              <td>
                <select v-model="prospect.status" @change="updateStatus(prospect)">
                  <option value="new">New</option>
                  <option value="contacted">Contacted</option>
                  <option value="quoted">Quoted</option>
                  <option value="won">Won</option>
                  <option value="lost">Lost</option>
                </select>
              </td>
              <td>
                <button @click="viewDetails(prospect)" class="btn-view">View</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- LLM Configuration Tab -->
      <div v-if="activeTab === 'llm'" class="llm-config">
        <div class="config-section">
          <h2>AI Chat Configuration</h2>
          <p class="section-description">Configure which AI models are available for customer chat support.</p>

          <div class="llm-models">
            <div class="model-card" v-for="model in availableModels" :key="model.tier">
              <div class="model-header">
                <h3>{{ model.name }}</h3>
                <div class="model-toggle">
                  <label class="switch">
                    <input
                      type="checkbox"
                      v-model="model.enabled"
                      @change="updateModelConfig"
                    />
                    <span class="slider"></span>
                  </label>
                </div>
              </div>
              <div class="model-details">
                <p><strong>Model:</strong> {{ model.model }}</p>
                <p><strong>Use Case:</strong> {{ model.description }}</p>
                <p><strong>Response Time:</strong> {{ model.responseTime }}</p>
                <div class="model-stats" v-if="model.stats">
                  <span class="stat">{{ model.stats.usage || 0 }} uses</span>
                  <span class="stat">{{ model.stats.avgTime || 0 }}ms avg</span>
                </div>
              </div>
            </div>
          </div>

          <div class="chat-settings">
            <h3>Chat Settings</h3>
            <div class="setting-group">
              <label>Default Model Tier:</label>
              <select v-model="defaultTier" @change="updateChatSettings">
                <option value="FAST">Fast (Quick responses)</option>
                <option value="MEDIUM">Medium (Balanced)</option>
                <option value="ADVANCED">Advanced (Technical questions)</option>
                <option value="EXPERT">Expert (Complex queries)</option>
              </select>
            </div>
            <div class="setting-group">
              <label>
                <input
                  type="checkbox"
                  v-model="enableAutoRouting"
                  @change="updateChatSettings"
                />
                Enable automatic model routing based on question complexity
              </label>
            </div>
          </div>
        </div>
      </div>

      <!-- Analytics Tab -->
      <div v-if="activeTab === 'analytics'" class="analytics-section">
        <h2>Analytics Dashboard</h2>
        <div class="analytics-grid">
          <div class="analytics-card">
            <h3>Chat Statistics</h3>
            <div class="stat-row">
              <span>Total Conversations:</span>
              <span>{{ chatStats.total || 0 }}</span>
            </div>
            <div class="stat-row">
              <span>This Week:</span>
              <span>{{ chatStats.thisWeek || 0 }}</span>
            </div>
            <div class="stat-row">
              <span>Unique Sessions:</span>
              <span>{{ chatStats.uniqueSessions || 0 }}</span>
            </div>
          </div>

          <div class="analytics-card">
            <h3>Model Usage</h3>
            <div v-for="usage in modelUsage" :key="usage.model" class="stat-row">
              <span>{{ usage.model }}:</span>
              <span>{{ usage.count }} uses</span>
            </div>
          </div>

          <div class="analytics-card">
            <h3>Lead Sources</h3>
            <div class="stat-row">
              <span>Form Submissions:</span>
              <span>{{ prospects.length }}</span>
            </div>
            <div class="stat-row">
              <span>High Priority:</span>
              <span>{{ highPriorityCount }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Detailed Prospect View Modal -->
      <div v-if="selectedProspect" class="modal-overlay" @click="closeModal">
        <div class="modal-content" @click.stop>
          <div class="modal-header">
            <h2>Lead Details</h2>
            <button @click="closeModal" class="close-btn">
              <i class="fas fa-times"></i>
            </button>
          </div>

          <div class="modal-body">
            <div class="prospect-details">
              <div class="detail-section">
                <h3>Contact Information</h3>
                <div class="detail-grid">
                  <div class="detail-item">
                    <label>Name:</label>
                    <span>{{ selectedProspect.name || 'Not provided' }}</span>
                  </div>
                  <div class="detail-item">
                    <label>Email:</label>
                    <span>{{ selectedProspect.email || 'Not provided' }}</span>
                  </div>
                  <div class="detail-item">
                    <label>Phone:</label>
                    <span>{{ selectedProspect.phone || 'Not provided' }}</span>
                  </div>
                </div>
              </div>

              <div class="detail-section">
                <h3>Project Information</h3>
                <div class="detail-grid">
                  <div class="detail-item">
                    <label>Project Type:</label>
                    <span>{{ formatProjectType(selectedProspect.project_type) }}</span>
                  </div>
                  <div class="detail-item">
                    <label>Budget Range:</label>
                    <span>{{ formatBudget(selectedProspect.budget_range) }}</span>
                  </div>
                  <div class="detail-item">
                    <label>Timeline:</label>
                    <span>{{ formatTimeline(selectedProspect.timeline) }}</span>
                  </div>
                  <div class="detail-item">
                    <label>Priority:</label>
                    <span class="priority-badge" :class="selectedProspect.priority">
                      {{ selectedProspect.priority }}
                    </span>
                  </div>
                </div>
              </div>

              <div class="detail-section" v-if="selectedProspectDetails">
                <h3>Additional Details</h3>
                <div class="detail-grid">
                  <div class="detail-item" v-if="selectedProspectDetails.wood_species">
                    <label>Wood Species:</label>
                    <span>{{ selectedProspectDetails.wood_species }}</span>
                  </div>
                  <div class="detail-item" v-if="selectedProspectDetails.cabinet_style">
                    <label>Cabinet Style:</label>
                    <span>{{ selectedProspectDetails.cabinet_style }}</span>
                  </div>
                  <div class="detail-item" v-if="selectedProspectDetails.material_type">
                    <label>Material Type:</label>
                    <span>{{ selectedProspectDetails.material_type }}</span>
                  </div>
                  <div class="detail-item" v-if="selectedProspectDetails.square_footage">
                    <label>Square Footage:</label>
                    <span>{{ selectedProspectDetails.square_footage }} sq ft</span>
                  </div>
                  <div class="detail-item" v-if="selectedProspectDetails.room_dimensions">
                    <label>Room Dimensions:</label>
                    <span>{{ selectedProspectDetails.room_dimensions }}</span>
                  </div>
                  <div class="detail-item" v-if="selectedProspectDetails.measurements">
                    <label>Measurements:</label>
                    <span>{{ selectedProspectDetails.measurements }}</span>
                  </div>
                </div>
              </div>

              <div class="detail-section" v-if="selectedProspectDetails?.message">
                <h3>Project Description</h3>
                <div class="message-content">
                  {{ selectedProspectDetails.message }}
                </div>
              </div>

              <div class="detail-section">
                <h3>Lead Management</h3>
                <div class="management-controls">
                  <div class="control-group">
                    <label>Status:</label>
                    <select v-model="selectedProspect.status" @change="updateStatus(selectedProspect)">
                      <option value="new">New</option>
                      <option value="contacted">Contacted</option>
                      <option value="quoted">Quoted</option>
                      <option value="won">Won</option>
                      <option value="lost">Lost</option>
                    </select>
                  </div>
                  <div class="control-group">
                    <label>Notes:</label>
                    <textarea
                      v-model="prospectNotes"
                      placeholder="Add notes about this lead..."
                      rows="3"
                    ></textarea>
                  </div>
                  <button @click="saveNotes" class="btn-save">Save Notes</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

// State management
const activeTab = ref('leads')
const prospects = ref([])
const selectedProspect = ref(null)
const selectedProspectDetails = ref(null)
const prospectNotes = ref('')
const searchQuery = ref('')
const statusFilter = ref('')
const chatStats = ref({})
const modelUsage = ref([])

// LLM Configuration
const availableModels = ref([
  {
    tier: 'FAST',
    name: 'Fast Response',
    model: 'llama3.2:3b',
    description: 'Simple questions, quick responses',
    responseTime: '~1-2 seconds',
    enabled: true,
    stats: { usage: 0, avgTime: 0 }
  },
  {
    tier: 'MEDIUM',
    name: 'Balanced',
    model: 'gemma3:4b',
    description: 'Moderate complexity questions',
    responseTime: '~2-4 seconds',
    enabled: true,
    stats: { usage: 0, avgTime: 0 }
  },
  {
    tier: 'ADVANCED',
    name: 'Technical Expert',
    model: 'qwen2.5:7b',
    description: 'Technical fabrication questions',
    responseTime: '~4-8 seconds',
    enabled: true,
    stats: { usage: 0, avgTime: 0 }
  },
  {
    tier: 'EXPERT',
    name: 'Design Specialist',
    model: 'llama4:16x17b',
    description: 'Complex design/engineering questions',
    responseTime: '~8-15 seconds',
    enabled: false,
    stats: { usage: 0, avgTime: 0 }
  }
])

const defaultTier = ref('MEDIUM')
const enableAutoRouting = ref(true)

// Computed properties
const highPriorityCount = computed(() =>
  prospects.value.filter(p => p.priority === 'high').length
)

const newLeadsCount = computed(() => {
  const today = new Date().toDateString()
  return prospects.value.filter(p =>
    new Date(p.created_at).toDateString() === today
  ).length
})

const filteredProspects = computed(() => {
  let filtered = prospects.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(p =>
      (p.name && p.name.toLowerCase().includes(query)) ||
      (p.email && p.email.toLowerCase().includes(query)) ||
      (p.phone && p.phone.includes(query)) ||
      (p.project_type && p.project_type.toLowerCase().includes(query))
    )
  }

  if (statusFilter.value) {
    filtered = filtered.filter(p => p.status === statusFilter.value)
  }

  return filtered
})

// API Functions
const fetchProspects = async () => {
  try {
    const response = await fetch('/api/prospects')
    prospects.value = await response.json()
  } catch (error) {
    console.error('Error fetching prospects:', error)
  }
}

const fetchAnalytics = async () => {
  try {
    const response = await fetch('/api/analytics/dashboard')
    const data = await response.json()
    chatStats.value = data.chats
    modelUsage.value = data.model_usage

    // Update model stats
    availableModels.value.forEach(model => {
      const usage = data.model_usage.find(u => u.model.includes(model.model))
      if (usage) {
        model.stats = { usage: usage.count, avgTime: usage.avg_time || 0 }
      }
    })
  } catch (error) {
    console.error('Error fetching analytics:', error)
  }
}

const updateStatus = async (prospect) => {
  try {
    await fetch(`/api/prospects/${prospect.id}/status`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status: prospect.status })
    })
  } catch (error) {
    console.error('Error updating status:', error)
  }
}

const viewDetails = async (prospect) => {
  try {
    selectedProspect.value = prospect
    const response = await fetch(`/api/prospects/${prospect.id}`)
    selectedProspectDetails.value = await response.json()
    prospectNotes.value = selectedProspectDetails.value.notes || ''
  } catch (error) {
    console.error('Error fetching prospect details:', error)
  }
}

const closeModal = () => {
  selectedProspect.value = null
  selectedProspectDetails.value = null
  prospectNotes.value = ''
}

const saveNotes = async () => {
  try {
    await fetch(`/api/prospects/${selectedProspect.value.id}/status`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        status: selectedProspect.value.status,
        notes: prospectNotes.value
      })
    })
    alert('Notes saved successfully!')
  } catch (error) {
    console.error('Error saving notes:', error)
    alert('Error saving notes')
  }
}

// LLM Configuration Functions
const updateModelConfig = async () => {
  try {
    const config = {
      models: availableModels.value.map(m => ({
        tier: m.tier,
        enabled: m.enabled
      }))
    }

    // For now, just log the config - you can implement API endpoint later
    console.log('Model configuration updated:', config)

    // TODO: Implement API endpoint to save model configuration
    // await fetch('/api/admin/llm-config', {
    //   method: 'POST',
    //   headers: { 'Content-Type': 'application/json' },
    //   body: JSON.stringify(config)
    // })
  } catch (error) {
    console.error('Error updating model config:', error)
  }
}

const updateChatSettings = async () => {
  try {
    const settings = {
      defaultTier: defaultTier.value,
      enableAutoRouting: enableAutoRouting.value
    }

    console.log('Chat settings updated:', settings)

    // TODO: Implement API endpoint to save chat settings
    // await fetch('/api/admin/chat-settings', {
    //   method: 'POST',
    //   headers: { 'Content-Type': 'application/json' },
    //   body: JSON.stringify(settings)
    // })
  } catch (error) {
    console.error('Error updating chat settings:', error)
  }
}

const formatProjectType = (type) => {
  const types = {
    cabinets: 'Custom Cabinets',
    countertops: 'Countertops',
    stone: 'Stone Fabrication',
    plastics: 'Plastics & Laminate',
    tile: 'Tile & Flooring',
    painting: 'Commercial Painting',
    multiple: 'Multiple Services'
  }
  return types[type] || type
}

const formatBudget = (budget) => {
  const budgets = {
    'under-5k': 'Under $5K',
    '5k-15k': '$5K - $15K',
    '15k-30k': '$15K - $30K',
    '30k-50k': '$30K - $50K',
    'over-50k': 'Over $50K'
  }
  return budgets[budget] || 'Not specified'
}

const formatTimeline = (timeline) => {
  const timelines = {
    asap: 'ASAP',
    '1-month': '1 Month',
    '3-months': '3 Months',
    '6-months': '6 Months',
    planning: 'Planning'
  }
  return timelines[timeline] || 'Not specified'
}

// Utility Functions
const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString()
}

// Lifecycle
onMounted(() => {
  fetchProspects()
  fetchAnalytics()

  // Refresh data every 30 seconds
  setInterval(() => {
    fetchProspects()
    fetchAnalytics()
  }, 30000)
})
</script>

<style scoped>
.admin-dashboard {
  padding: 2rem;
  background: #f8fafc;
  min-height: 100vh;
  font-family: 'Inter', sans-serif;
}

.dashboard-header h1 {
  font-family: 'Playfair Display', serif;
  color: #1e293b;
  margin-bottom: 2rem;
}

/* Navigation Tabs */
.nav-tabs {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  border-bottom: 2px solid #e5e7eb;
}

.nav-tab {
  background: none;
  border: none;
  padding: 1rem 1.5rem;
  cursor: pointer;
  font-weight: 500;
  color: #6b7280;
  border-bottom: 2px solid transparent;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.nav-tab:hover {
  color: #3b82f6;
}

.nav-tab.active {
  color: #3b82f6;
  border-bottom-color: #3b82f6;
}

.nav-tab i {
  font-size: 1.1rem;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.stat-card {
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  text-align: center;
}

.stat-card.high-priority {
  border-left: 4px solid #ef4444;
}

.stat-number {
  font-size: 2.5rem;
  font-weight: 700;
  color: #1e293b;
}

.stat-label {
  color: #64748b;
  font-size: 0.9rem;
  margin-top: 0.5rem;
}

/* Table Controls */
.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  background: white;
  border-bottom: 1px solid #e5e7eb;
}

.table-header h2 {
  margin: 0;
  color: #1e293b;
}

.table-controls {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.search-input {
  padding: 0.5rem 1rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.9rem;
  min-width: 200px;
}

.filter-select {
  padding: 0.5rem 1rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.9rem;
  background: white;
}

.prospects-table {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.no-contact {
  color: #9ca3af;
  font-style: italic;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th {
  background: #f1f5f9;
  padding: 1rem;
  text-align: left;
  font-weight: 600;
  color: #374151;
  border-bottom: 1px solid #e5e7eb;
}

td {
  padding: 1rem;
  border-bottom: 1px solid #f3f4f6;
}

.high-priority {
  background: #fef2f2;
}

.priority-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  text-transform: uppercase;
}

.priority-badge.high {
  background: #fee2e2;
  color: #dc2626;
}

.priority-badge.normal {
  background: #e0f2fe;
  color: #0369a1;
}

.priority-badge.low {
  background: #f3f4f6;
  color: #6b7280;
}

.contact-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.contact-info a {
  color: #3b82f6;
  text-decoration: none;
  font-size: 0.9rem;
}

.btn-view {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
}

/* LLM Configuration Styles */
.llm-config {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.config-section h2 {
  color: #1e293b;
  margin-bottom: 0.5rem;
}

.section-description {
  color: #6b7280;
  margin-bottom: 2rem;
}

.llm-models {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.model-card {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 1.5rem;
  background: #f9fafb;
}

.model-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.model-header h3 {
  margin: 0;
  color: #1e293b;
}

.model-toggle .switch {
  position: relative;
  display: inline-block;
  width: 50px;
  height: 24px;
}

.model-toggle .switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  transition: .4s;
  border-radius: 24px;
}

.slider:before {
  position: absolute;
  content: "";
  height: 18px;
  width: 18px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  transition: .4s;
  border-radius: 50%;
}

input:checked + .slider {
  background-color: #3b82f6;
}

input:checked + .slider:before {
  transform: translateX(26px);
}

.model-details p {
  margin: 0.5rem 0;
  color: #4b5563;
  font-size: 0.9rem;
}

.model-stats {
  display: flex;
  gap: 1rem;
  margin-top: 1rem;
}

.stat {
  background: #e5e7eb;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  color: #374151;
}

.chat-settings {
  border-top: 1px solid #e5e7eb;
  padding-top: 2rem;
}

.chat-settings h3 {
  color: #1e293b;
  margin-bottom: 1rem;
}

.setting-group {
  margin-bottom: 1rem;
}

.setting-group label {
  display: block;
  margin-bottom: 0.5rem;
  color: #374151;
  font-weight: 500;
}

.setting-group select {
  padding: 0.5rem 1rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  background: white;
  font-size: 0.9rem;
}

.setting-group input[type="checkbox"] {
  margin-right: 0.5rem;
}

/* Analytics Styles */
.analytics-section {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.analytics-section h2 {
  color: #1e293b;
  margin-bottom: 2rem;
}

.analytics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

.analytics-card {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 1.5rem;
  background: #f9fafb;
}

.analytics-card h3 {
  margin: 0 0 1rem 0;
  color: #1e293b;
}

.stat-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0;
  border-bottom: 1px solid #e5e7eb;
}

.stat-row:last-child {
  border-bottom: none;
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 2rem;
}

.modal-content {
  background: white;
  border-radius: 12px;
  max-width: 800px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid #e5e7eb;
}

.modal-header h2 {
  margin: 0;
  color: #1e293b;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #6b7280;
  padding: 0.5rem;
  border-radius: 4px;
}

.close-btn:hover {
  background: #f3f4f6;
}

.modal-body {
  padding: 2rem;
}

.detail-section {
  margin-bottom: 2rem;
}

.detail-section h3 {
  color: #1e293b;
  margin-bottom: 1rem;
  border-bottom: 2px solid #e5e7eb;
  padding-bottom: 0.5rem;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.detail-item label {
  font-weight: 600;
  color: #374151;
  font-size: 0.9rem;
}

.detail-item span {
  color: #6b7280;
}

.message-content {
  background: #f9fafb;
  padding: 1rem;
  border-radius: 6px;
  border-left: 4px solid #3b82f6;
  line-height: 1.6;
  color: #374151;
}

.management-controls {
  background: #f9fafb;
  padding: 1.5rem;
  border-radius: 8px;
}

.control-group {
  margin-bottom: 1rem;
}

.control-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #374151;
}

.control-group select,
.control-group textarea {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.9rem;
}

.btn-save {
  background: #10b981;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
}

.btn-save:hover {
  background: #059669;
}

/* Responsive Design */
@media (max-width: 768px) {
  .nav-tabs {
    flex-wrap: wrap;
  }

  .table-controls {
    flex-direction: column;
    align-items: stretch;
    gap: 0.5rem;
  }

  .search-input {
    min-width: auto;
  }

  .modal-overlay {
    padding: 1rem;
  }

  .modal-body {
    padding: 1rem;
  }

  .detail-grid {
    grid-template-columns: 1fr;
  }
}
</style>