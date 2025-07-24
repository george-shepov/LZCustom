# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LZ Custom Fabrication is a Vue.js 3 + FastAPI web application for a custom fabrication company. The application features:
- Professional company website with services, gallery, and quote forms
- AI-powered customer service chat using local LLaMA models with intelligent model routing
- Database logging for chat conversations and quote submissions
- Multi-domain Nginx reverse proxy configuration supporting multiple websites
- Production deployment with Docker Compose and automated Ubuntu provisioning scripts

## Development Commands

### Quick Start
```bash
./scripts/dev-setup.sh    # Complete development environment setup
./start-dev.sh           # Start both frontend and backend servers
./test-system.sh         # Test all system components
```

### Frontend (Vue.js 3 + Vite)
```bash
cd frontend
npm install          # Install dependencies
npm run dev          # Start dev server (http://localhost:5173)
npm run build        # Build for production
npm run serve        # Preview production build
```

### Backend (FastAPI + Python)
```bash
cd backend
python3 -m venv venv               # Create virtual environment
source venv/bin/activate           # Activate virtual environment
pip install -r requirements.txt    # Install dependencies
python main.py                     # Start backend server (http://localhost:8000)
```

### AI Models (Ollama)
```bash
ollama serve                             # Start Ollama server
ollama pull qwen2.5:7b-instruct-q4_k_m  # Primary model for complex questions
ollama pull gemma3:4b                    # Medium complexity questions
ollama pull llama3.2:3b                  # Fast responses, simple questions
```

### Production Deployment
```bash
./scripts/provision-ubuntu.sh   # Full production Ubuntu deployment
docker-compose up --build       # Docker container deployment
```

## Architecture

### Frontend Architecture
- **Vue.js 3** with Composition API and TypeScript support
- **Vite** build tool with HMR and proxy configuration
- **Component hierarchy**: 
  - `App.vue` - Main application shell
  - `Navigation.vue` - Site navigation and branding
  - `HeroSection.vue` - Dynamic hero with background images
  - `ServicesGrid.vue` - Service offerings display
  - `GalleryPreview.vue` - Project showcase
  - `QuoteForm.vue` - Lead generation form
  - `CustomerServiceChat.vue` - AI-powered chat interface
  - `AdminDashboard.vue` - Analytics and management interface
- **Routing**: Vue Router for SPA navigation
- **API proxy**: Development server proxies `/api/*` to backend

### Backend Architecture  
- **FastAPI** application with automatic OpenAPI documentation
- **SQLite database** with raw SQL for performance
- **LLaMA service** (`llama_service.py`) with intelligent model routing:
  - Question complexity analysis
  - Automatic model tier selection (FAST/MEDIUM/ADVANCED/EXPERT)
  - Async HTTP communication with Ollama
- **CORS middleware** for frontend integration
- **Database models**: Prospects, chat conversations, user sessions

### Multi-Domain Nginx Configuration
- **Reverse proxy** supporting multiple websites on single server
- **SSL termination** with Let's Encrypt integration
- **Load balancing** between frontend/backend containers
- **Static asset serving** with caching headers
- **Log aggregation** in `nginx/logs/`

### Database Schema
```sql
prospects: id, name, email, phone, project, message, budget, timeline, timestamp
chat_conversations: id, session_id, message, response, model_used, timestamp
sessions: id, session_id, user_ip, created_at, last_activity
```

## API Endpoints

### Core Application APIs
- `POST /api/prospects` - Quote form submissions
- `POST /api/chat` - AI chat interactions with model routing
- `GET /api/analytics/dashboard` - Business metrics and KPIs
- `GET /api/chat/conversations` - Chat history with filtering
- `GET /api/chat/sessions` - Active user sessions

### Development URLs
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000  
- API Documentation: http://localhost:8000/docs
- Ollama API: http://localhost:11434

### Production URLs (Docker)
- Frontend: http://localhost:3000
- Backend API: http://localhost:8001
- Ollama: http://localhost:11435

## Testing and Debugging

### System Testing
```bash
./test-system.sh  # Automated system health checks
```

### Manual API Testing
```bash
# Test AI chat with complexity routing
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What stone materials do you work with for countertops?"}'

# Test quote submission
curl -X POST http://localhost:8000/api/prospects \
  -H "Content-Type: application/json" \
  -d '{"name": "Test User", "email": "test@example.com", "phone": "216-555-0123", "project": "kitchen countertops", "message": "Looking for granite installation"}'

# Test analytics dashboard
curl http://localhost:8000/api/analytics/dashboard
```

### Debugging Chat Issues
- Check Ollama status: `ollama list` and `ollama ps`
- Verify model downloads: Models are ~4-7GB each
- Monitor backend logs for model routing decisions
- Use `/docs` endpoint for interactive API testing

## Deployment

### Docker Compose (Recommended)
```bash
docker-compose up --build    # Full stack with Ollama, Nginx
```

The Docker setup includes:
- **Frontend container**: Vue.js app served by Vite
- **Backend container**: FastAPI with Python dependencies
- **Ollama container**: AI model serving
- **Nginx container**: Reverse proxy and SSL termination
- **Persistent volumes**: Database and model storage

### Production Ubuntu Deployment
The `scripts/provision-ubuntu.sh` provides complete automation:
- System package installation (Node.js 20, Python 3.11, Docker)
- Ollama installation and model downloads (~10GB)
- Nginx configuration with SSL
- Systemd service configuration
- UFW firewall setup
- Automatic service startup

## Key Dependencies

### Frontend Dependencies
- **Vue.js 3.4.15** - Progressive framework
- **Vite 5.2.10** - Build tool and dev server
- **Vue Router 4.5.1** - Client-side routing
- **TypeScript** support via vue-tsc

### Backend Dependencies  
- **FastAPI 0.104.1** - Modern Python web framework
- **Uvicorn 0.24.0** - ASGI server
- **Pydantic 2.5.0** - Data validation
- **aiohttp 3.9.1** - Async HTTP client for Ollama
- **SQLAlchemy 2.0.23** - Database toolkit
- **python-multipart** - File upload support

### AI/ML Dependencies
- **Ollama 0.1.7** - Local LLaMA model serving
- **Model files**: qwen2.5:7b, gemma3:4b, llama3.2:3b

## Development Workflow

### Making Changes
1. **Frontend changes**: Hot reload at http://localhost:5173
2. **Backend changes**: Restart `python main.py` to pick up changes
3. **Database changes**: Modify schema in `main.py`, restart backend
4. **AI model changes**: Update `llama_service.py` model routing logic

### Adding New Features
1. **UI components**: Add to `frontend/src/components/`
2. **API endpoints**: Add to `backend/main.py` with proper Pydantic models
3. **Database tables**: Define schema in `main.py` database initialization
4. **Chat capabilities**: Extend `llama_service.py` model selection logic

### Gallery Management
- **Image location**: `frontend/public/assets/gallery/`
- **Organization**: Categorized by service type (kitchens, bathrooms, commercial, etc.)
- **Optimization**: Use `scripts/optimize-gallery-images.sh` for web optimization
- **Format support**: JPG, PNG with automatic WebP conversion