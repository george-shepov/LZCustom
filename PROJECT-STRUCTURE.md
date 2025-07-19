# 🗂️ LZ Custom Project Structure

**ORGanized by GiORGiY.ORG - The ORGanized Giorgiy**

## 📁 Directory Structure

```
LZCustom/
├── 📄 README.md                    # Main project documentation
├── 📄 PROJECT-STRUCTURE.md         # This file - project organization
├── 📄 .gitignore                   # Git ignore rules
├── 📄 lz_custom.db                 # Main database (development)
│
├── 📂 frontend/                    # Vue.js Frontend Application
│   ├── 📄 package.json            # Frontend dependencies
│   ├── 📄 vite.config.js          # Vite configuration
│   ├── 📄 index.html              # Main HTML template
│   ├── 📂 src/                    # Source code
│   │   ├── 📄 App.vue             # Main Vue application
│   │   ├── 📄 main.js             # Application entry point
│   │   └── 📂 components/         # Vue components
│   │       ├── 📄 Navigation.vue          # Site navigation
│   │       ├── 📄 HeroSection.vue         # Hero banner with rotating images
│   │       ├── 📄 ServicesGrid.vue        # Services showcase with modals
│   │       ├── 📄 TrustBlock.vue          # Trust indicators (2x2 grid)
│   │       ├── 📄 GalleryPreview.vue      # Midjourney image gallery
│   │       ├── 📄 Testimonials.vue        # Customer testimonials
│   │       ├── 📄 QuoteForm.vue           # Comprehensive quote form ✨
│   │       ├── 📄 Footer.vue              # Site footer
│   │       ├── 📄 CustomerServiceChat.vue # AI chat widget
│   │       ├── 📄 HelpfulModal.vue        # Service detail modals
│   │       └── 📄 AdminDashboard.vue      # Lead management dashboard
│   └── 📂 public/                 # Static assets
│       └── 📂 assets/             # Images and media
│           └── 📂 gallery/        # Midjourney-generated images
│
├── 📂 backend/                     # FastAPI Backend Application
│   ├── 📄 main.py                 # Main FastAPI application
│   ├── 📄 llama_service.py        # AI chat service with local models
│   ├── 📄 requirements.txt        # Python dependencies
│   ├── 📄 lz_custom.db           # Backend database
│   └── 📂 __pycache__/           # Python cache (auto-generated)
│
├── 📂 scripts/                     # Automation & Setup Scripts
│   ├── 📄 provision-ubuntu.sh     # Complete Ubuntu server setup
│   ├── 📄 dev-setup.sh           # Development environment setup
│   ├── 📄 optimize-gallery-images.sh  # Image optimization
│   └── 📄 organize-images.sh      # Image organization
│
├── 📂 deployment/                  # Deployment Configuration
│   ├── 📄 docker-compose.yml      # Docker orchestration
│   ├── 📄 Dockerfile.frontend     # Frontend container
│   ├── 📄 Dockerfile.backend      # Backend container
│   └── 📂 nginx/                  # Nginx reverse proxy
│       └── 📄 default.conf        # Nginx configuration
│
└── 📂 docs/                        # Documentation
    ├── 📄 IMAGE-OPTIMIZATION-SUMMARY.md  # Image optimization details
    └── 📄 midjourney-prompts.md          # AI image generation prompts
```

## 🎯 Key Components

### 🎨 Frontend (Vue.js 3 + Vite)
- **Modern Architecture**: Composition API, reactive components
- **Professional Design**: Industrial typography, glassmorphism effects
- **Midjourney Gallery**: AI-generated professional images
- **Comprehensive Quote Form**: Multi-step form with project-specific fields
- **AI Chat Widget**: Real-time customer service with session tracking
- **Responsive Design**: Mobile-first approach with perfect scaling

### 🔧 Backend (FastAPI + SQLite)
- **AI Integration**: Local LLaMA models with intelligent routing
- **Database Logging**: Complete conversation and prospect tracking
- **Session Management**: UUID-based conversation continuity
- **Analytics API**: Business intelligence and reporting endpoints
- **Error Handling**: Comprehensive logging and graceful fallbacks

### 🤖 AI Models
- **FAST**: llama3.2:3b (2GB) - Simple questions, basic math
- **MEDIUM**: gemma3:4b (3.3GB) - General fabrication questions
- **ADVANCED**: qwen2.5:7b-instruct-q4_k_m (4.7GB) - Technical specs
- **Smart Routing**: Automatic model selection based on complexity

### 🗄️ Database Schema
- **prospects**: Quote form submissions with project details
- **chat_conversations**: Complete conversation logging
- **chat_sessions**: Session tracking and analytics
- **Foreign Keys**: Proper relational structure

### 📊 Analytics & Reporting
- **Dashboard**: Real-time business metrics
- **Conversation Logs**: Complete chat history
- **Lead Management**: Priority-based prospect organization
- **Performance Metrics**: Response times and success rates

## 🚀 Quick Start Commands

### Development
```bash
# Setup development environment
./scripts/dev-setup.sh

# Start development servers
cd frontend && npm run dev    # Frontend: http://localhost:5173
cd backend && python main.py  # Backend: http://localhost:8000
```

### Production Deployment
```bash
# Ubuntu server setup (automated)
./scripts/provision-ubuntu.sh

# Docker deployment
cd deployment && docker-compose up -d
```

### Image Management
```bash
# Optimize gallery images
./scripts/optimize-gallery-images.sh

# Organize image structure
./scripts/organize-images.sh
```

## 🔧 Configuration Files

- **Frontend**: `frontend/vite.config.js` - Vite build configuration
- **Backend**: `backend/requirements.txt` - Python dependencies
- **Docker**: `deployment/docker-compose.yml` - Container orchestration
- **Nginx**: `deployment/nginx/default.conf` - Reverse proxy setup
- **Git**: `.gitignore` - Version control exclusions

## 📈 Business Features

### Quote Form Enhancements ✨
- **Enhanced Borders**: 2px solid #d1d5db with box-shadow for visibility
- **Project-Specific Fields**: Dynamic form fields based on project type
- **Budget & Timeline**: Investment ranges and project timelines
- **Business Status**: Real-time open/closed status with hours
- **Success Handling**: Professional confirmation with next steps

### AI Chat Features
- **Session Tracking**: Persistent conversation history
- **Professional Personality**: LZ Custom brand voice and expertise
- **Math Capabilities**: Handles calculations while maintaining personality
- **Error Recovery**: Graceful fallbacks with helpful responses

### Analytics Dashboard
- **Prospect Statistics**: Total, weekly, priority-based metrics
- **Chat Analytics**: Conversation counts, session tracking
- **Model Performance**: Usage statistics and response times
- **Recent Activity**: Combined timeline of all interactions

## 🎨 Design System

- **Typography**: Oswald, Roboto Condensed, Playfair Display
- **Colors**: Orange brand (#f39c12), Professional grays
- **Effects**: Glassmorphism, subtle shadows, smooth transitions
- **Layout**: CSS Grid, Flexbox, mobile-first responsive design

---

**Made with ❤️ by GiORGiY.ORG - The ORGanized Giorgiy**  
*Professional project structure for enterprise-ready applications*
