<template>
  <div v-if="showModal" class="upgrade-modal-overlay" @click="closeModal">
    <div class="upgrade-modal" @click.stop>
      <div class="modal-header">
        <h3>🚀 Unlock Better Performance!</h3>
        <button class="close-btn" @click="closeModal">&times;</button>
      </div>
      
      <div class="modal-content">
        <div class="current-tier">
          <h4>Your Current Plan</h4>
          <div class="tier-card current">
            <div class="tier-name">{{ currentTier.name }}</div>
            <div class="tier-price">{{ currentTier.price }}</div>
            <ul class="tier-features">
              <li v-for="feature in currentTier.features" :key="feature">
                ✓ {{ feature }}
              </li>
            </ul>
          </div>
        </div>
        
        <div class="upgrade-arrow">
          <div class="arrow">→</div>
          <div class="upgrade-text">UPGRADE TO</div>
        </div>
        
        <div class="upgrade-tier">
          <h4>Recommended Upgrade</h4>
          <div class="tier-card upgrade">
            <div class="tier-name">{{ upgradeTier.name }}</div>
            <div class="tier-price">{{ upgradeTier.price }}</div>
            <div class="tier-badge">{{ upgradeBadge }}</div>
            <ul class="tier-features">
              <li v-for="feature in upgradeTier.new_features" :key="feature" class="new-feature">
                ✨ {{ feature }}
              </li>
              <li v-for="feature in currentTier.features" :key="feature" class="existing-feature">
                ✓ {{ feature }}
              </li>
            </ul>
          </div>
        </div>
      </div>
      
      <div class="modal-benefits">
        <h4>{{ upgradeMessage }}</h4>
        <div class="benefit-comparison">
          <div class="benefit-item">
            <div class="benefit-label">Response Time</div>
            <div class="benefit-current">{{ currentPerformance.responseTime }}</div>
            <div class="benefit-upgrade">{{ upgradePerformance.responseTime }}</div>
          </div>
          <div class="benefit-item">
            <div class="benefit-label">AI Intelligence</div>
            <div class="benefit-current">{{ currentPerformance.aiLevel }}</div>
            <div class="benefit-upgrade">{{ upgradePerformance.aiLevel }}</div>
          </div>
          <div class="benefit-item" v-if="upgradePerformance.storage">
            <div class="benefit-label">Storage</div>
            <div class="benefit-current">{{ currentPerformance.storage }}</div>
            <div class="benefit-upgrade">{{ upgradePerformance.storage }}</div>
          </div>
        </div>
      </div>
      
      <div class="modal-actions">
        <div class="trial-offer">
          <h4>🎉 VPS Dime 3-Day FREE Trial</h4>
          <p>Try the upgrade risk-free for 3 days!</p>
        </div>
        
        <div class="action-buttons">
          <button class="btn-upgrade" @click="startFreeTrial">
            Start 3-Day FREE Trial
          </button>
          <button class="btn-secondary" @click="learnMore">
            Learn More
          </button>
          <button class="btn-later" @click="remindLater">
            Maybe Later
          </button>
        </div>
      </div>
      
      <div class="modal-footer">
        <p class="guarantee">30-day money-back guarantee • Cancel anytime</p>
        <p class="referral">Powered by VPS Dime • Referred by LZ Custom</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const props = defineProps({
  trigger: String,
  currentTierData: Object,
  upgradeTierData: Object
})

const emit = defineEmits(['close', 'upgrade-started'])

const showModal = ref(false)
const referralCode = 'lzcustom'

const currentTier = computed(() => props.currentTierData || {
  name: 'Basic',
  price: '$5/month',
  features: ['Basic Website', 'Contact Forms', 'Limited AI']
})

const upgradeTier = computed(() => props.upgradeTierData || {
  name: 'Standard',
  price: '$10/month',
  new_features: ['Local AI Chat', 'Redis Caching', 'Session Management']
})

const upgradeBadge = computed(() => {
  switch(props.trigger) {
    case 'performance': return 'FASTER'
    case 'ai_limit': return 'UNLIMITED'
    case 'features': return 'ENHANCED'
    default: return 'RECOMMENDED'
  }
})

const upgradeMessage = computed(() => {
  switch(props.trigger) {
    case 'performance': return 'Get 3x faster responses with local AI!'
    case 'ai_limit': return 'Unlimited AI chat with no daily limits!'
    case 'ai_complexity': return 'Unlock smarter AI for technical questions!'
    case 'dual_ai': return 'Intelligent AI routing for best responses!'
    default: return 'Unlock premium features and better performance!'
  }
})

const currentPerformance = computed(() => {
  const tier = props.currentTierData?.tier || 'tier1'
  const performance = {
    tier1: { responseTime: '15-30 sec', aiLevel: 'Basic', storage: '10GB' },
    tier2: { responseTime: '8-15 sec', aiLevel: 'Standard', storage: '25GB' },
    tier3: { responseTime: '5-10 sec', aiLevel: 'Smart', storage: '50GB' },
    tier4: { responseTime: '3-8 sec', aiLevel: 'Professional', storage: '100GB' }
  }
  return performance[tier] || performance.tier1
})

const upgradePerformance = computed(() => {
  const tier = props.upgradeTierData?.tier || 'tier2'
  const performance = {
    tier2: { responseTime: '8-15 sec', aiLevel: 'Standard', storage: '25GB' },
    tier3: { responseTime: '5-10 sec', aiLevel: 'Smart', storage: '50GB' },
    tier4: { responseTime: '3-8 sec', aiLevel: 'Professional', storage: '100GB' },
    tier5: { responseTime: '2-5 sec', aiLevel: 'Expert', storage: '200GB' }
  }
  return performance[tier] || performance.tier2
})

const show = () => {
  showModal.value = true
  // Track modal shown event
  trackEvent('upgrade_modal_shown', {
    trigger: props.trigger,
    current_tier: currentTier.value.tier,
    target_tier: upgradeTier.value.tier
  })
}

const closeModal = () => {
  showModal.value = false
  emit('close')
}

const startFreeTrial = () => {
  const vpsDimeUrl = `https://vpsdime.com/3-day-trial?plan=${upgradeTier.value.tier}&ref=${referralCode}&source=lzcustom`
  
  // Track conversion event
  trackEvent('upgrade_trial_started', {
    trigger: props.trigger,
    current_tier: currentTier.value.tier,
    target_tier: upgradeTier.value.tier,
    referral_code: referralCode
  })
  
  // Open in new tab
  window.open(vpsDimeUrl, '_blank')
  
  emit('upgrade-started', {
    tier: upgradeTier.value.tier,
    trial: true
  })
  
  closeModal()
}

const learnMore = () => {
  const compareUrl = `https://vpsdime.com/compare?current=${currentTier.value.tier}&upgrade=${upgradeTier.value.tier}&ref=${referralCode}`
  window.open(compareUrl, '_blank')
  
  trackEvent('upgrade_learn_more', {
    trigger: props.trigger,
    current_tier: currentTier.value.tier,
    target_tier: upgradeTier.value.tier
  })
}

const remindLater = () => {
  // Set reminder in localStorage
  const reminderTime = new Date()
  reminderTime.setHours(reminderTime.getHours() + 24) // Remind in 24 hours
  
  localStorage.setItem('upgrade_reminder', JSON.stringify({
    time: reminderTime.toISOString(),
    trigger: props.trigger,
    current_tier: currentTier.value.tier,
    target_tier: upgradeTier.value.tier
  }))
  
  trackEvent('upgrade_remind_later', {
    trigger: props.trigger,
    current_tier: currentTier.value.tier,
    target_tier: upgradeTier.value.tier
  })
  
  closeModal()
}

const trackEvent = (event, data) => {
  // Send tracking data to backend
  fetch('/api/analytics/track', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      event,
      data,
      timestamp: new Date().toISOString()
    })
  }).catch(console.error)
}

// Expose show method to parent
defineExpose({ show })

onMounted(() => {
  // Check for upgrade reminders
  const reminder = localStorage.getItem('upgrade_reminder')
  if (reminder) {
    const reminderData = JSON.parse(reminder)
    const reminderTime = new Date(reminderData.time)
    
    if (new Date() >= reminderTime) {
      localStorage.removeItem('upgrade_reminder')
      // Auto-show if reminder time has passed
      setTimeout(() => show(), 5000)
    }
  }
})
</script>

<style scoped>
.upgrade-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  padding: 20px;
}

.upgrade-modal {
  background: white;
  border-radius: 16px;
  max-width: 800px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
  animation: modalSlideUp 0.3s ease-out;
}

@keyframes modalSlideUp {
  from {
    opacity: 0;
    transform: translateY(50px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 32px;
  border-bottom: 1px solid #e5e7eb;
  background: linear-gradient(135deg, #f39c12, #e67e22);
  color: white;
  border-radius: 16px 16px 0 0;
}

.modal-header h3 {
  margin: 0;
  font-size: 24px;
  font-weight: 700;
}

.close-btn {
  background: none;
  border: none;
  color: white;
  font-size: 28px;
  cursor: pointer;
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: background-color 0.2s;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

.modal-content {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  gap: 24px;
  padding: 32px;
  align-items: start;
}

.tier-card {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 24px;
  text-align: center;
  border: 2px solid #e5e7eb;
}

.tier-card.current {
  border-color: #6b7280;
}

.tier-card.upgrade {
  border-color: #f39c12;
  background: linear-gradient(135deg, #fff7ed, #fef3c7);
  position: relative;
}

.tier-name {
  font-size: 20px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 8px;
}

.tier-price {
  font-size: 24px;
  font-weight: 800;
  color: #f39c12;
  margin-bottom: 16px;
}

.tier-badge {
  background: #f39c12;
  color: white;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 700;
  margin-bottom: 16px;
  display: inline-block;
}

.tier-features {
  list-style: none;
  padding: 0;
  margin: 0;
  text-align: left;
}

.tier-features li {
  padding: 6px 0;
  font-size: 14px;
  color: #4b5563;
}

.new-feature {
  color: #f39c12 !important;
  font-weight: 600;
}

.existing-feature {
  opacity: 0.7;
}

.upgrade-arrow {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.arrow {
  font-size: 32px;
  color: #f39c12;
  font-weight: bold;
}

.upgrade-text {
  font-size: 12px;
  font-weight: 700;
  color: #6b7280;
  margin-top: 8px;
}

.modal-benefits {
  padding: 0 32px 24px;
  border-bottom: 1px solid #e5e7eb;
}

.modal-benefits h4 {
  text-align: center;
  margin-bottom: 24px;
  font-size: 18px;
  color: #1f2937;
}

.benefit-comparison {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.benefit-item {
  text-align: center;
}

.benefit-label {
  font-size: 14px;
  color: #6b7280;
  margin-bottom: 8px;
}

.benefit-current, .benefit-upgrade {
  padding: 8px 12px;
  border-radius: 8px;
  font-weight: 600;
  margin: 4px 0;
}

.benefit-current {
  background: #f3f4f6;
  color: #6b7280;
}

.benefit-upgrade {
  background: #fef3c7;
  color: #d97706;
}

.modal-actions {
  padding: 24px 32px;
}

.trial-offer {
  text-align: center;
  margin-bottom: 24px;
}

.trial-offer h4 {
  margin: 0 0 8px 0;
  color: #059669;
  font-size: 18px;
}

.trial-offer p {
  margin: 0;
  color: #6b7280;
  font-size: 14px;
}

.action-buttons {
  display: flex;
  gap: 12px;
  justify-content: center;
  flex-wrap: wrap;
}

.btn-upgrade {
  background: linear-gradient(135deg, #059669, #047857);
  color: white;
  border: none;
  padding: 14px 28px;
  border-radius: 8px;
  font-weight: 700;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.2s;
  min-width: 200px;
}

.btn-upgrade:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(5, 150, 105, 0.3);
}

.btn-secondary {
  background: #f39c12;
  color: white;
  border: none;
  padding: 14px 28px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-secondary:hover {
  background: #e67e22;
}

.btn-later {
  background: none;
  color: #6b7280;
  border: 1px solid #d1d5db;
  padding: 14px 28px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-later:hover {
  background: #f3f4f6;
}

.modal-footer {
  text-align: center;
  padding: 16px 32px 24px;
  background: #f9fafb;
  border-radius: 0 0 16px 16px;
}

.modal-footer p {
  margin: 4px 0;
  font-size: 12px;
  color: #6b7280;
}

.guarantee {
  font-weight: 600;
  color: #059669;
}

@media (max-width: 768px) {
  .modal-content {
    grid-template-columns: 1fr;
    text-align: center;
  }
  
  .upgrade-arrow .arrow {
    transform: rotate(90deg);
  }
  
  .action-buttons {
    flex-direction: column;
    align-items: center;
  }
  
  .btn-upgrade, .btn-secondary, .btn-later {
    width: 100%;
    max-width: 280px;
  }
}
</style>