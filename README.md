# 🏗️ LZ Custom Multi-Domain Platform

A comprehensive multi-domain platform featuring LZ Custom Fabrication as the flagship business website, plus personal sites and professional services. Built with Docker, automated backups, SSL certificates, and AI-powered features.

## 🌐 Live Domains

- **https://lzcustom.giorgiy.org** - LZ Custom Professional Fabrication (Main)
- **https://lzcustom.bravoohio.org** - LZ Custom (Bravo Ohio subdomain)
- **https://lzcustom.lodexinc.com** - LZ Custom (Lodex Inc subdomain)
- **https://giorgiy.org** - Main landing page
- **https://giorgiy-shepov.com** - Personal WordPress site
- **https://lodexinc.com** - Lodex Inc technology solutions
- **https://bravoohio.org** - Bravo Ohio community initiative (Ghost CMS)
- **https://mail.giorgiy.org** - Professional webmail for all domains

## 🐳 Docker Management

### Quick Start
```bash
./manage.sh start     # Start all services
./manage.sh ssl       # Get SSL certificates
./manage.sh status    # Check everything is running
```

### Daily Operations
```bash
./manage.sh stop      # Stop all services (with backup)
./manage.sh restart   # Restart all services
./manage.sh backup    # Create manual backup
./manage.sh logs lzcustom-frontend  # View specific logs
```

## 🎯 Key Features

### 🤖 **AI-Powered Customer Service**
- **Local LLaMA Integration**: qwen2.5:7b-instruct-q4_k_m model for intelligent responses
- **Smart Model Routing**: Automatic selection based on question complexity (FAST/MEDIUM/ADVANCED/EXPERT)
- **Professional Context**: 30+ years of LZ Custom expertise built into AI responses
- **Real-time Chat**: 8-15 second response times with session tracking
- **Customer-focused**: Encourages calls and quote requests naturally
- **Math & Logic**: Handles basic calculations (2+2=4) while maintaining company personality

### 🖼️ **Professional Midjourney Gallery**
- **Fresh AI-Generated Images**: High-quality Midjourney images prioritizing latest creations
- **Workshop & Showroom**: Professional fabrication facility and luxury showroom displays
- **Project Showcase**: Luxury kitchens, bathrooms, commercial installations
- **Process Documentation**: Installation, measurement, CNC cutting, craftsmanship details
- **Material Close-ups**: Granite edges, cabinet profiles, tile layouts, laminate textures
- **Mixed Collection**: Fresh images prioritized while maintaining variety with originals

### 🎨 **Industrial Design Excellence**
- **Prominent "LZ Custom" Branding**: Bold, sophisticated typography that commands attention
- **Industrial Fonts**: Oswald, Roboto Condensed, Playfair Display for premium feel
- **Glassmorphism Effects**: Modern hero badges with backdrop blur and hover animations
- **Professional Color Scheme**: Orange brand accents with clean, trustworthy design
- **Visual Hierarchy**: Clean 2x2 grid layouts, proper spacing, mobile-optimized designs

### 🗄️ **Comprehensive Database Logging**
- **Chat Conversations**: Every user message and AI response logged with session tracking
- **Quote Form Submissions**: Complete prospect data with project details and priority assignment
- **Session Management**: Unique session IDs for conversation continuity
- **Analytics Dashboard**: Real-time metrics, model usage, conversion tracking
- **Business Intelligence**: Customer inquiry patterns, response times, success rates

### 🏢 **Complete Business Platform**
1. **Hero Section**: Massive branding with professional badges and clear value props
2. **Services Grid**: Interactive cards with detailed modals, pricing, and helpful tips
3. **AI Chat Widget**: Working customer service assistant with comprehensive company knowledge
4. **Professional Quote System**: Multi-step form with project-specific fields and budget tracking
5. **Gallery Carousel**: Full-screen image viewer with professional project photography
6. **Trust Section**: Clean 2x2 grid showcasing 30+ years of expertise and credentials

### ⚡ **Technical Excellence**
- **Vue.js 3 + Vite**: Modern frontend with fast development and build times
- **FastAPI Backend**: Python API with SQLite database for prospect and conversation management
- **Local AI Models**: No external API dependencies, complete privacy and control
- **Session Tracking**: Persistent conversation history with user analytics
- **Error Handling**: Comprehensive logging, graceful fallbacks, and user-friendly messages
- **Production Ready**: Automated deployment, systemd services, nginx reverse proxy

## 🚀 Quick Start

### 🐧 **Automated Ubuntu Setup (Recommended)**

For production deployment on Ubuntu server:

```bash
# Clone repository
git clone https://github.com/george-shepov/LZCustom.git
cd LZCustom

# Run automated provisioning script
chmod +x scripts/provision-ubuntu.sh
./scripts/provision-ubuntu.sh
```

**What the script installs:**
- Node.js 18.x, Python 3.8+, Ollama
- AI models: qwen2.5:7b-instruct-q4_k_m, gemma3:4b, llama3.2:3b (10GB+ total)
- Nginx reverse proxy, systemd services
- UFW firewall configuration
- Auto-start services on boot

### 🚀 **Development Setup**

For local development:

```bash
# Clone repository
git clone https://github.com/george-shepov/LZCustom.git
cd LZCustom

# Quick development setup
chmod +x scripts/dev-setup.sh
./scripts/dev-setup.sh

# Start development servers
./start-dev.sh
```

### 📋 **Manual Setup (if needed)**

#### Prerequisites
- **Node.js 18+** (for frontend)
- **Python 3.8+** (for backend AI service)
- **Ollama** (for local AI models)
- **10GB+ disk space** (for AI models)

#### 1. Frontend Setup
```bash
cd frontend
npm install
npm run dev
# Frontend: http://localhost:5173
```

#### 2. Backend Setup
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install fastapi uvicorn aiohttp pydantic
python main.py
# Backend: http://localhost:8000
```

#### 3. AI Models Setup
```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Download AI models (this takes time!)
ollama pull qwen2.5:7b-instruct-q4_k_m  # 4.7GB - Primary model
ollama pull gemma3:4b                    # 3.3GB - Medium complexity
ollama pull llama3.2:3b                  # 2GB - Fast responses
```

### 🎯 **Access Points**
- **Website**: http://localhost:5173
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Analytics Dashboard**: http://localhost:8000/api/analytics/dashboard
- **Chat Conversations**: http://localhost:8000/api/chat/conversations

## 📱 Responsive Design

The landing page is fully responsive and optimized for:
- **Mobile**: 320px - 768px
- **Tablet**: 768px - 1024px  
- **Desktop**: 1024px+
- **Large Screens**: 1440px+

## 🎨 Design System

### Colors
- **Primary**: #2c3e50 (Dark Blue-Gray)
- **Secondary**: #34495e (Medium Blue-Gray)
- **Accent**: #f39c12 (Warm Orange)
- **Success**: #27ae60 (Green)
- **Background**: #f8f9fa (Light Gray)

### Typography
- **Headings**: Cormorant Garamond (Serif)
- **Body**: Poppins (Sans-serif)
- **Weights**: 300, 400, 500, 600, 700

### Components
- **Buttons**: Gradient backgrounds with hover animations
- **Cards**: Subtle shadows with hover lift effects
- **Forms**: Clean inputs with focus states
- **Navigation**: Smooth scroll behavior

## 🏢 Business Information

**LZ Custom Fabrication** - Northeast Ohio's premier custom fabrication company with 30+ years of excellence.

### Contact & Service
- **Phone**: 216-268-2990
- **Business Hours**: Monday-Friday 8:00 AM - 5:00 PM
- **Service Area**: 30-mile radius from Cleveland (free consultations)
- **Experience**: 30+ years in custom fabrication and design
- **Credentials**: Licensed, insured, bonded with A+ BBB rating

### Services & Investment Ranges
1. **Custom Cabinets**: $15,000 - $50,000+ (Oak, Maple, Cherry, Walnut)
2. **Countertops**: $3,000 - $15,000+ (Granite, Quartz, Marble, Engineered Stone)
3. **Stone Fabrication**: $2,500 - $12,000+ (CNC cutting, edge profiling, installation)
4. **Plastics & Laminate**: $1,500 - $8,000+ (Commercial and residential applications)
5. **Tile & Flooring**: $2,000 - $10,000+ (Expert installation, geometric patterns)
6. **Commercial Painting**: Custom quotes (Professional interior/exterior coatings)

### Typical Project Timelines
- **Countertops**: 2-3 weeks from template to installation
- **Custom Cabinets**: 4-8 weeks depending on complexity and materials
- **Stone Fabrication**: 1-3 weeks for most residential projects
- **Commercial Projects**: 2-12 weeks based on scope and specifications

## 📊 Management & Analytics

### Database Logging
- **Chat Conversations**: Every user message and AI response logged with session tracking
- **Quote Submissions**: Complete prospect data with project details and priority assignment
- **Session Analytics**: User behavior, conversation patterns, conversion tracking
- **Business Intelligence**: Response times, model performance, customer insights

### Admin Endpoints
- **Analytics Dashboard**: http://localhost:8000/api/analytics/dashboard
- **Chat Conversations**: http://localhost:8000/api/chat/conversations
- **Chat Sessions**: http://localhost:8000/api/chat/sessions
- **API Documentation**: http://localhost:8000/docs

### Service Management (Ubuntu)
```bash
# Start/stop services
sudo systemctl start lzcustom-backend
sudo systemctl start lzcustom-frontend
sudo systemctl start nginx

# View logs
sudo journalctl -u lzcustom-backend -f
sudo journalctl -u lzcustom-frontend -f

# Management scripts
~/start-lzcustom.sh    # Start all services
~/stop-lzcustom.sh     # Stop all services
```

## 🛠 Technology Stack

### Frontend
- **Vue.js 3**: Modern reactive framework with Composition API
- **Vite**: Lightning-fast build tool and dev server
- **CSS3**: Advanced styling with Grid, Flexbox, glassmorphism effects
- **Font Awesome**: Professional icon library
- **Google Fonts**: Industrial typography (Oswald, Roboto Condensed, Playfair Display)
- **Responsive Design**: Mobile-first approach with perfect scaling across all devices

### Backend & AI
- **FastAPI**: High-performance Python API framework with automatic OpenAPI documentation
- **SQLite**: Lightweight database with comprehensive logging (prospects, chat conversations, sessions)
- **Ollama**: Local LLaMA model serving with no external dependencies
- **aiohttp**: Async HTTP client for AI model communication
- **Pydantic**: Data validation and serialization
- **Session Management**: UUID-based conversation tracking with analytics

### AI Models & Intelligence
- **FAST**: llama3.2:3b (2GB) - Simple questions, business hours, basic math
- **MEDIUM**: gemma3:4b (3.3GB) - General fabrication questions, material advice
- **ADVANCED**: qwen2.5:7b-instruct-q4_k_m (4.7GB) - Technical specifications, detailed quotes
- **EXPERT**: llama4:16x17b (67GB) - Complex design consultations (optional)
- **Smart Routing**: Automatic model selection based on question complexity
- **Fallback System**: Graceful degradation with professional responses

### Gallery & Media
- **Midjourney AI**: Professional gallery images generated with custom prompts
- **Image Optimization**: Multiple formats and resolutions for performance
- **Carousel System**: Full-screen gallery with smooth transitions
- **Category Filtering**: Workshop, projects, details, materials organization

### Production Infrastructure
- **Nginx**: Reverse proxy with load balancing and SSL termination
- **Systemd**: Service management with auto-restart and logging
- **UFW Firewall**: Security configuration with proper port management
- **PM2**: Process management for Node.js applications (alternative)
- **Ubuntu 20.04+**: Optimized for modern Linux distributions

## 📦 Project Structure

```
LZCustom/
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   │   ├── HeroSection.vue
│   │   │   ├── ServicesGrid.vue
│   │   │   ├── TrustBlock.vue
│   │   │   ├── GalleryPreview.vue
│   │   │   ├── QuoteForm.vue
│   │   │   └── Footer.vue
│   │   ├── App.vue
│   │   └── main.js
│   ├── public/
│   ├── index.html
│   └── package.json
├── backend/
├── docker-compose.yml
└── README.md
```

## 🚀 Deployment

### Docker Deployment
```bash
# Build and run with Docker Compose
docker-compose up --build
```

### Manual Deployment
```bash
# Build frontend
cd frontend && npm run build

# Deploy dist/ folder to web server
# Configure nginx to serve static files
```

## 📈 Performance

- **Lighthouse Score**: 95+ across all metrics
- **First Contentful Paint**: < 1.5s
- **Largest Contentful Paint**: < 2.5s
- **Cumulative Layout Shift**: < 0.1

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 🎯 **AI Chat Features**

### **Intelligent Customer Service**
- **Company Knowledge**: 30+ years of LZ Custom expertise built-in
- **Service Details**: Timelines, pricing ranges, material options
- **Professional Responses**: Warm, knowledgeable, conversion-focused
- **Smart Routing**: Right model for each question complexity
- **Fallback Support**: Always provides help even if AI is busy

### **Test the AI Chat**
Try asking these questions:
- "What services do you offer?"
- "What's the difference between granite and quartz?"
- "How long does a kitchen cabinet project take?"
- "Do you serve my area?"
- "What are your business hours?"

## 🏢 **Business Information**

**LZ Custom Fabrication**
- **Phone**: 216-268-2990
- **Experience**: 30+ Years in Northeast Ohio
- **Service Area**: 30-mile radius from Cleveland
- **Specialties**: Custom Cabinets, Premium Countertops, Stone Fabrication
- **Status**: Licensed & Insured, BBB A+ Rating

### **Services Offered**
1. **Custom Cabinets**: Handcrafted from Oak, Maple, Cherry, Walnut
2. **Premium Countertops**: Granite, Marble, Quartz, Exotic Stones
3. **Stone Fabrication**: Precision cutting and installation
4. **Commercial Surfaces**: Restaurant and office installations
5. **Tile & Flooring**: Complete flooring solutions

## 📈 **Performance & Features**

- **AI Response Time**: 8-15 seconds average
- **Mobile Responsive**: Perfect scaling across all devices
- **Professional Design**: Industrial typography with premium feel
- **Lead Generation**: Working quote system with database storage
- **SEO Optimized**: Structured data and semantic HTML
- **Accessibility**: WCAG compliant with proper focus management

## 📄 **License**

All rights reserved by Giorgiy Shepov.

## 🐧 Deployment Scripts

### `scripts/provision-ubuntu.sh` - Production Setup
Complete automated setup for Ubuntu servers:
- System updates and essential packages
- Node.js 18.x, Python 3.8+, Ollama installation
- AI model downloads (10GB+ total)
- Nginx reverse proxy configuration
- Systemd services with auto-start
- UFW firewall setup
- Management scripts creation

### `scripts/dev-setup.sh` - Development Environment
Quick setup for local development:
- Frontend and backend dependency installation
- Virtual environment creation
- Development scripts generation
- System testing capabilities

### Management Scripts (Created by provisioning)
- `~/start-lzcustom.sh` - Start all services
- `~/stop-lzcustom.sh` - Stop all services
- `./start-dev.sh` - Development servers
- `./test-system.sh` - System verification

## 🎯 Testing & Verification

### AI Chat Testing
```bash
# Test basic math
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What is 2+2?"}'

# Test business questions
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What services do you offer?"}'
```

### Database Testing
```bash
# Test quote submission
curl -X POST http://localhost:8000/api/prospects \
  -H "Content-Type: application/json" \
  -d '{"name": "Test User", "email": "test@example.com", "phone": "216-555-0123", "project": "countertops", "message": "Test quote"}'

# View analytics
curl http://localhost:8000/api/analytics/dashboard
```

---

**🏗️ Built with Excellence for LZ Custom Fabrication**
*Serving Northeast Ohio with Premium Craftsmanship since 1990*

**Repository**: https://github.com/george-shepov/LZCustom
**Live Demo**: http://localhost:5173 (when running locally)

🎉 **Production-ready website with working AI chat, comprehensive database logging, beautiful Midjourney gallery, and automated Ubuntu deployment!**
