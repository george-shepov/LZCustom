<template>
  <div class="admin-dashboard">
    <div class="container">
      <div class="dashboard-header">
        <h1>LZ Custom - Lead Management</h1>
        <div class="stats-grid">
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
        </div>
      </div>

      <div class="prospects-table">
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
            <tr v-for="prospect in prospects" :key="prospect.id" 
                :class="{ 'high-priority': prospect.priority === 'high' }">
              <td>
                <span class="priority-badge" :class="prospect.priority">
                  {{ prospect.priority }}
                </span>
              </td>
              <td class="name-cell">
                <strong>{{ prospect.name }}</strong>
              </td>
              <td>{{ formatProjectType(prospect.project_type) }}</td>
              <td>{{ formatBudget(prospect.budget_range) }}</td>
              <td>{{ formatTimeline(prospect.timeline) }}</td>
              <td>
                <div class="contact-info">
                  <a :href="`tel:${prospect.phone}`">{{ prospect.phone }}</a>
                  <a :href="`mailto:${prospect.email}`">{{ prospect.email }}</a>
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
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const prospects = ref([])

const highPriorityCount = computed(() => 
  prospects.value.filter(p => p.priority === 'high').length
)

const newLeadsCount = computed(() => {
  const today = new Date().toDateString()
  return prospects.value.filter(p => 
    new Date(p.created_at).toDateString() === today
  ).length
})

const fetchProspects = async () => {
  try {
    const response = await fetch('/api/prospects')
    prospects.value = await response.json()
  } catch (error) {
    console.error('Error fetching prospects:', error)
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

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString()
}

const viewDetails = (prospect) => {
  // Open detailed view modal or navigate to detail page
  console.log('View details for:', prospect)
}

onMounted(() => {
  fetchProspects()
  // Refresh every 30 seconds
  setInterval(fetchProspects, 30000)
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

.prospects-table {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
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
</style>