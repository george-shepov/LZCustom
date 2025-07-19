# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LZ Custom Fabrication is a Vue.js 3 + FastAPI web application for a custom fabrication company. The application features:
- Professional company website with services, gallery, and quote forms
- AI-powered customer service chat using local LLaMA models
- Database logging for chat conversations and quote submissions
- Production deployment with Docker and Ubuntu scripts

## Development Commands

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

### Development Setup Scripts
```bash
./scripts/dev-setup.sh       # Quick development environment setup
./scripts/provision-ubuntu.sh   # Production Ubuntu deployment
```

### AI Models (Ollama)
```bash
ollama pull qwen2.5:7b-instruct-q4_k_m  # Primary model for complex questions
ollama pull gemma3:4b                    # Medium complexity questions
ollama pull llama3.2:3b                  # Fast responses, simple questions
```

## Architecture

### Frontend Structure
- **Vue.js 3** with Composition API and TypeScript support
- **Vite** for fast development and building
- **Component-based architecture**: Navigation, HeroSection, ServicesGrid, TrustBlock, GalleryPreview, QuoteForm, Footer, CustomerServiceChat
- **Proxy configuration**: API calls to `/api/*` are proxied to `http://localhost:8000`

### Backend Structure
- **FastAPI** application with CORS middleware for frontend communication
- **SQLite database** (`lz_custom.db`) with tables for prospects, chat conversations, and sessions
- **LLaMA service** (`llama_service.py`) with intelligent model routing based on question complexity
- **Model tiers**: FAST (llama3.2:3b), MEDIUM (gemma3:4b), ADVANCED (qwen2.5:7b), EXPERT (llama4:16x17b)

### Key Backend Files
- `main.py`: FastAPI application with database models and API endpoints
- `llama_service.py`: AI service with question classification and model routing
- `lz_custom.db`: SQLite database for data persistence

### Database Schema
- **prospects**: Quote submissions with contact info, project details, budget, timeline
- **chat_conversations**: AI chat history with session tracking
- **sessions**: User session management for conversation continuity

## API Endpoints

### Core Endpoints
- `POST /api/prospects`: Submit quote form data
- `POST /api/chat`: Send message to AI chat service
- `GET /api/analytics/dashboard`: View analytics and metrics
- `GET /api/chat/conversations`: Retrieve chat history
- `GET /api/chat/sessions`: View user sessions

### Development URLs
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000
- API Documentation: http://localhost:8000/docs

## Testing

### Manual API Testing
```bash
# Test chat functionality
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What services do you offer?"}'

# Test quote submission
curl -X POST http://localhost:8000/api/prospects \
  -H "Content-Type: application/json" \
  -d '{"name": "Test User", "email": "test@example.com", "phone": "216-555-0123", "project": "countertops", "message": "Test quote"}'
```

## Deployment

### Docker Deployment
```bash
docker-compose up --build    # Build and run both frontend and backend
```

### Production Ubuntu Setup
The `scripts/provision-ubuntu.sh` script provides fully automated deployment including:
- System dependencies (Node.js, Python, Ollama)
- AI model downloads (10GB+ total)
- Nginx reverse proxy configuration
- Systemd services with auto-restart
- UFW firewall setup

## Key Dependencies

### Frontend
- Vue.js 3.4.15
- Vite 5.2.10
- TypeScript support via vue-tsc

### Backend
- FastAPI for REST API
- SQLite3 for database operations
- aiohttp for async HTTP requests to Ollama
- Pydantic for data validation

## Development Notes

- The frontend uses TypeScript with Vue 3 Composition API
- API calls are proxied through Vite dev server to avoid CORS issues
- AI service intelligently routes questions to appropriate models based on complexity
- Database operations use raw SQLite3 for simplicity and performance
- All chat conversations and quote submissions are logged for analytics