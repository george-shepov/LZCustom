#!/bin/bash

# LZ Custom Website - Development Setup Script
# Quick setup for development environment

set -e

echo "🚀 LZ Custom Website - Development Setup"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "package.json" ] && [ ! -d "frontend" ]; then
    print_warning "Please run this script from the LZCustom project root directory"
    exit 1
fi

# Install frontend dependencies
if [ -d "frontend" ]; then
    print_status "Installing frontend dependencies..."
    cd frontend
    npm install
    print_success "Frontend dependencies installed"
    cd ..
fi

# Setup backend virtual environment
if [ -d "backend" ]; then
    print_status "Setting up backend environment..."
    cd backend
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        print_success "Virtual environment created"
    fi
    
    # Activate and install dependencies
    source venv/bin/activate
    pip install fastapi uvicorn aiohttp pydantic
    print_success "Backend dependencies installed"
    cd ..
fi

# Check if Ollama is running
print_status "Checking Ollama status..."
if ! pgrep -x "ollama" > /dev/null; then
    print_warning "Ollama is not running. Please install and start Ollama:"
    echo "  curl -fsSL https://ollama.ai/install.sh | sh"
    echo "  ollama serve"
    echo ""
    echo "Then download the required models:"
    echo "  ollama pull qwen2.5:7b-instruct-q4_k_m"
    echo "  ollama pull gemma3:4b"
    echo "  ollama pull llama3.2:3b"
else
    print_success "Ollama is running"
fi

# Create development start script
print_status "Creating development scripts..."

cat > start-dev.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting LZ Custom Development Environment..."

# Function to run command in new terminal (works with gnome-terminal)
run_in_terminal() {
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal --tab --title="$1" -- bash -c "$2; exec bash"
    else
        echo "Starting $1..."
        $2 &
    fi
}

# Start backend
echo "🔧 Starting backend server..."
cd backend
source venv/bin/activate
python main.py &
BACKEND_PID=$!
cd ..

# Wait a moment for backend to start
sleep 3

# Start frontend
echo "🎨 Starting frontend server..."
cd frontend
npm run dev &
FRONTEND_PID=$!
cd ..

echo ""
echo "✅ Development servers started!"
echo ""
echo "🌐 Access your website at:"
echo "   • Frontend: http://localhost:5173"
echo "   • Backend API: http://localhost:8000"
echo ""
echo "📊 Management URLs:"
echo "   • Analytics: http://localhost:8000/api/analytics/dashboard"
echo "   • Chat Logs: http://localhost:8000/api/chat/conversations"
echo ""
echo "Press Ctrl+C to stop all servers"

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping servers..."
    kill $BACKEND_PID 2>/dev/null || true
    kill $FRONTEND_PID 2>/dev/null || true
    echo "✅ Servers stopped"
    exit 0
}

# Set trap to cleanup on script exit
trap cleanup SIGINT SIGTERM

# Wait for user to stop
wait
EOF

chmod +x start-dev.sh

# Create test script
cat > test-system.sh << 'EOF'
#!/bin/bash

echo "🧪 Testing LZ Custom System..."
echo ""

# Test backend
echo "🔧 Testing backend..."
if curl -s http://localhost:8000/api/analytics/dashboard > /dev/null; then
    echo "✅ Backend API: Working"
else
    echo "❌ Backend API: Not responding"
fi

# Test AI chat
echo "🤖 Testing AI chat..."
RESPONSE=$(curl -s -X POST http://localhost:8000/api/chat \
    -H "Content-Type: application/json" \
    -d '{"message": "What is 2+2?"}')

if echo "$RESPONSE" | grep -q "success.*true"; then
    echo "✅ AI Chat: Working"
    echo "   Response: $(echo "$RESPONSE" | grep -o '"response":"[^"]*"' | cut -d'"' -f4 | head -c 50)..."
else
    echo "❌ AI Chat: Not working"
fi

# Test frontend
echo "🎨 Testing frontend..."
if curl -s http://localhost:5173 > /dev/null; then
    echo "✅ Frontend: Working"
else
    echo "❌ Frontend: Not responding"
fi

# Test database
echo "🗄️  Testing database..."
if [ -f "backend/lz_custom.db" ]; then
    echo "✅ Database: File exists"
else
    echo "❌ Database: File not found"
fi

echo ""
echo "🎯 Test complete!"
EOF

chmod +x test-system.sh

print_success "Development environment setup complete!"
echo ""
echo "🚀 Quick Start Commands:"
echo "   • Start development: ./start-dev.sh"
echo "   • Test system: ./test-system.sh"
echo ""
echo "📁 Project Structure:"
echo "   • Frontend: ./frontend/ (Vue.js + Vite)"
echo "   • Backend: ./backend/ (FastAPI + SQLite)"
echo "   • Gallery: ./frontend/public/assets/gallery/"
echo ""
echo "🔧 Manual Start (if needed):"
echo "   • Backend: cd backend && source venv/bin/activate && python main.py"
echo "   • Frontend: cd frontend && npm run dev"
echo ""
print_warning "Make sure Ollama is running with the required models!"
echo "Happy coding! 💻"
