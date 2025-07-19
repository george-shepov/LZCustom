<template>
  <!-- Floating Chat Widget -->
  <div class="chat-widget" :class="{ 'open': chatOpen }">
    <button 
      class="chat-toggle" 
      @click="toggleChat"
      :aria-label="chatOpen ? 'Close chat' : 'Open chat'"
    >
      <i :class="chatOpen ? 'fas fa-times' : 'fas fa-comments'"></i>
      <span class="chat-badge" v-if="!chatOpen && hasNewTips">{{ unreadTips }}</span>
    </button>

    <div class="chat-window" v-if="chatOpen">
      <div class="chat-header">
        <div class="chat-avatar">
          <i class="fas fa-user-tie"></i>
        </div>
        <div class="chat-info">
          <h4>LZ Custom Assistant</h4>
          <p class="status">Online • Ready to help</p>
        </div>
      </div>

      <div class="chat-messages" ref="chatMessages">
        <div 
          class="message assistant" 
          v-for="message in messages" 
          :key="message.id"
          :class="{ 'new': message.isNew }"
        >
          <div class="message-content">
            <p>{{ message.text }}</p>
            <span class="message-time">{{ message.time }}</span>
          </div>
        </div>
      </div>

      <div class="chat-input">
        <div class="input-container">
          <input
            v-model="currentMessage"
            @keydown.enter="sendMessage"
            placeholder="Ask about our services..."
            :disabled="isTyping"
          />
          <button
            @click="sendMessage"
            :disabled="!currentMessage.trim() || isTyping"
            class="send-btn"
          >
            <i class="fas fa-paper-plane" v-if="!isTyping"></i>
            <i class="fas fa-spinner fa-spin" v-else></i>
          </button>
        </div>
      </div>

      <div class="chat-actions">
        <button @click="requestQuote" class="action-btn primary">
          <i class="fas fa-calculator"></i>
          Get Quote
        </button>
        <button @click="callNow" class="action-btn secondary">
          <i class="fas fa-phone"></i>
          Call Now
        </button>
      </div>
    </div>
  </div>

  <!-- Running Tips Banner -->
  <div class="tips-banner" v-if="showTipsBanner">
    <div class="tips-content">
      <i class="fas fa-lightbulb"></i>
      <div class="tips-text">
        <span class="tip-label">Pro Tip:</span>
        <span class="tip-content">{{ currentTip.text }}</span>
      </div>
      <button @click="closeTipsBanner" class="tips-close">
        <i class="fas fa-times"></i>
      </button>
    </div>
  </div>

  <!-- Contextual Help Bubbles -->
  <teleport to="body">
    <div 
      v-for="bubble in activeBubbles" 
      :key="bubble.id"
      class="help-bubble"
      :style="bubble.position"
      @click="showBubbleHelp(bubble)"
    >
      <i class="fas fa-question-circle"></i>
      <div class="bubble-tooltip">{{ bubble.text }}</div>
    </div>
  </teleport>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'

const chatOpen = ref(false)
const hasNewTips = ref(true)
const unreadTips = ref(3)
const showTipsBanner = ref(true)
const chatMessages = ref(null)
const activeBubbles = ref([])
const currentMessage = ref('')
const isTyping = ref(false)

const messages = ref([
  {
    id: 1,
    text: "Hi! I'm here to help with your custom fabrication project. What can I assist you with today?",
    time: "Just now",
    isNew: false
  }
])

const tips = ref([
  {
    id: 1,
    text: "Granite countertops typically require 2-3 weeks from template to installation",
    category: "timeline"
  },
  {
    id: 2,
    text: "Bring photos of your space for more accurate project estimates",
    category: "preparation"
  },
  {
    id: 3,
    text: "Custom cabinets can increase your home value by 15-20%",
    category: "value"
  },
  {
    id: 4,
    text: "We offer free in-home consultations within 30 miles of Cleveland",
    category: "service"
  },
  {
    id: 5,
    text: "Quartz surfaces are non-porous and don't require sealing like natural stone",
    category: "materials"
  }
])

const currentTipIndex = ref(0)
const currentTip = ref(tips.value[0])

const toggleChat = () => {
  chatOpen.value = !chatOpen.value
  if (chatOpen.value) {
    hasNewTips.value = false
    unreadTips.value = 0
    addWelcomeMessages()
  }
}

const addWelcomeMessages = async () => {
  await nextTick()
  
  setTimeout(() => {
    addMessage("I see you're interested in our services! Here are some quick options:")
  }, 1000)
  
  setTimeout(() => {
    addMessage("💡 Need a quote? Click 'Get Quote' below or scroll to our form")
  }, 2000)
  
  setTimeout(() => {
    addMessage("📞 Prefer to talk? Call us at 216-268-2990 - we're here Mon-Fri 8AM-5PM")
  }, 3000)
}

const addMessage = (text) => {
  const newMessage = {
    id: Date.now(),
    text,
    time: "Just now",
    isNew: true
  }
  messages.value.push(newMessage)
  
  nextTick(() => {
    if (chatMessages.value) {
      chatMessages.value.scrollTop = chatMessages.value.scrollHeight
    }
  })
  
  setTimeout(() => {
    newMessage.isNew = false
  }, 1000)
}

const requestQuote = () => {
  const quoteForm = document.querySelector('#quote-form')
  if (quoteForm) {
    quoteForm.scrollIntoView({ behavior: 'smooth' })
    chatOpen.value = false
  }
}

const callNow = () => {
  window.location.href = 'tel:216-268-2990'
}

const sendMessage = async () => {
  if (!currentMessage.value.trim() || isTyping.value) return

  const userMsg = currentMessage.value.trim()
  currentMessage.value = ''

  // Add user message
  addUserMessage(userMsg)

  // Show typing indicator
  isTyping.value = true

  // Send to AI
  await sendMessageToAI(userMsg)

  isTyping.value = false
}

const addUserMessage = (text) => {
  const newMessage = {
    id: Date.now(),
    text,
    time: "Just now",
    isNew: true,
    isUser: true
  }
  messages.value.push(newMessage)

  nextTick(() => {
    if (chatMessages.value) {
      chatMessages.value.scrollTop = chatMessages.value.scrollHeight
    }
  })
}

const closeTipsBanner = () => {
  showTipsBanner.value = false
}

const rotateTips = () => {
  currentTipIndex.value = (currentTipIndex.value + 1) % tips.value.length
  currentTip.value = tips.value[currentTipIndex.value]
}

const showBubbleHelp = (bubble) => {
  addMessage(bubble.helpText)
  if (!chatOpen.value) {
    chatOpen.value = true
  }
}

const sendMessageToAI = async (userMessage) => {
  try {
    const response = await fetch('/api/chat', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: userMessage,
        context: 'customer_service'
      })
    })

    const data = await response.json()

    if (data.success) {
      // Add model info for transparency
      const modelInfo = data.response_time < 2 ? '⚡' : data.response_time < 5 ? '🤖' : '🧠'
      addMessage(`${modelInfo} ${data.response}`)

      // Add performance info in development
      if (window.location.hostname === 'localhost') {
        addMessage(`💡 Answered by ${data.model_used} in ${data.response_time}s`)
      }
    } else {
      addMessage(data.response)
    }
  } catch (error) {
    console.error('Chat error:', error)
    addMessage("I'm having trouble connecting right now. Please call us at 216-268-2990 for immediate assistance!")
  }
}

const initializeHelpBubbles = () => {
  // Add contextual help bubbles based on page sections
  const projectCards = document.querySelectorAll('.project-card')
  if (projectCards.length > 0) {
    activeBubbles.value.push({
      id: 'project-help',
      text: 'Need help choosing?',
      helpText: 'Not sure which service fits your needs? I can help you choose the right option based on your project requirements and budget.',
      position: {
        position: 'fixed',
        top: '200px',
        right: '20px',
        zIndex: 999
      }
    })
  }
}

onMounted(() => {
  // Rotate tips every 8 seconds
  setInterval(rotateTips, 8000)
  
  // Initialize help bubbles after page loads
  setTimeout(initializeHelpBubbles, 2000)
  
  // Show new tip notification periodically
  setInterval(() => {
    if (!chatOpen.value) {
      hasNewTips.value = true
      unreadTips.value = Math.min(unreadTips.value + 1, 5)
    }
  }, 30000)
})
</script>

<style scoped>
.chat-widget {
  position: fixed;
  bottom: 20px;
  right: 20px;
  z-index: 1000;
}

.chat-toggle {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border: none;
  color: white;
  font-size: 1.5rem;
  cursor: pointer;
  box-shadow: 0 4px 20px rgba(243, 156, 18, 0.4);
  transition: all 0.3s ease;
  position: relative;
}

.chat-toggle:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 25px rgba(243, 156, 18, 0.5);
}

.chat-badge {
  position: absolute;
  top: -5px;
  right: -5px;
  background: #e74c3c;
  color: white;
  border-radius: 50%;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
  font-weight: bold;
}

.chat-window {
  position: absolute;
  bottom: 80px;
  right: 0;
  width: 350px;
  height: 450px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.chat-header {
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  color: white;
  padding: 1rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.chat-avatar {
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
}

.chat-info h4 {
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
}

.status {
  margin: 0;
  font-size: 0.8rem;
  opacity: 0.9;
}

.chat-messages {
  flex: 1;
  padding: 1rem;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.message {
  display: flex;
  align-items: flex-start;
}

.message.assistant .message-content {
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 12px 12px 12px 4px;
  padding: 0.75rem;
  max-width: 80%;
}

.message.user {
  justify-content: flex-end;
}

.message.user .message-content {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
  border-radius: 12px 12px 4px 12px;
  padding: 0.75rem;
  max-width: 80%;
}

.message.new .message-content {
  animation: messageSlide 0.3s ease;
}

@keyframes messageSlide {
  from {
    opacity: 0;
    transform: translateX(-10px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.message-content p {
  margin: 0 0 0.25rem 0;
  line-height: 1.4;
}

.message-time {
  font-size: 0.7rem;
  color: #6c757d;
}

.message.user .message-time {
  color: rgba(255, 255, 255, 0.8);
}

.chat-input {
  padding: 1rem;
  border-top: 1px solid #e9ecef;
}

.input-container {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.input-container input {
  flex: 1;
  padding: 0.75rem;
  border: 1px solid #e9ecef;
  border-radius: 20px;
  outline: none;
  font-size: 0.9rem;
}

.input-container input:focus {
  border-color: #f39c12;
  box-shadow: 0 0 0 2px rgba(243, 156, 18, 0.2);
}

.send-btn {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: none;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.send-btn:hover:not(:disabled) {
  transform: scale(1.05);
  box-shadow: 0 4px 15px rgba(243, 156, 18, 0.3);
}

.send-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.chat-actions {
  padding: 1rem;
  border-top: 1px solid #e9ecef;
  display: flex;
  gap: 0.5rem;
}

.action-btn {
  flex: 1;
  padding: 0.75rem;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.action-btn.primary {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
}

.action-btn.secondary {
  background: #f8f9fa;
  color: #2c3e50;
  border: 1px solid #e9ecef;
}

.action-btn:hover {
  transform: translateY(-1px);
}

.tips-banner {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%);
  color: white;
  z-index: 999;
  animation: slideDown 0.5s ease;
}

@keyframes slideDown {
  from {
    transform: translateY(-100%);
  }
  to {
    transform: translateY(0);
  }
}

.tips-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0.75rem 2rem;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.tips-text {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.tip-label {
  font-weight: 600;
}

.tips-close {
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 4px;
  transition: background 0.3s ease;
}

.tips-close:hover {
  background: rgba(255, 255, 255, 0.2);
}

.help-bubble {
  position: fixed;
  width: 40px;
  height: 40px;
  background: #f39c12;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  cursor: pointer;
  box-shadow: 0 4px 15px rgba(243, 156, 18, 0.3);
  transition: all 0.3s ease;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
}

.help-bubble:hover {
  transform: scale(1.2);
  box-shadow: 0 6px 20px rgba(243, 156, 18, 0.4);
}

.help-bubble:hover .bubble-tooltip {
  opacity: 1;
  visibility: visible;
}

.bubble-tooltip {
  position: absolute;
  bottom: 50px;
  left: 50%;
  transform: translateX(-50%);
  background: #2c3e50;
  color: white;
  padding: 0.5rem 0.75rem;
  border-radius: 8px;
  font-size: 0.8rem;
  white-space: nowrap;
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s ease;
}

.bubble-tooltip::after {
  content: '';
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  border: 5px solid transparent;
  border-top-color: #2c3e50;
}

@media (max-width: 768px) {
  .chat-window {
    width: 300px;
    height: 400px;
  }
  
  .tips-content {
    padding: 0.75rem 1rem;
  }
  
  .tips-text {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.25rem;
  }
}
</style>
