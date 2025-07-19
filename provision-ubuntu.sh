#!/bin/bash

# LZ Custom Website - Ubuntu Provisioning Script
# This script sets up everything needed to run the LZ Custom website on Ubuntu

set -e  # Exit on any error

echo "🏗️  LZ Custom Website - Ubuntu Provisioning Script"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential packages
print_status "Installing essential packages..."
sudo apt install -y curl wget git build-essential software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Install Node.js 18.x
print_status "Installing Node.js 18.x..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify Node.js installation
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
print_success "Node.js installed: $NODE_VERSION"
print_success "npm installed: $NPM_VERSION"

# Install Python 3.8+ and pip
print_status "Installing Python and pip..."
sudo apt install -y python3 python3-pip python3-venv python3-dev

# Verify Python installation
PYTHON_VERSION=$(python3 --version)
print_success "Python installed: $PYTHON_VERSION"

# Install Ollama for local AI models
print_status "Installing Ollama for local AI models..."
curl -fsSL https://ollama.ai/install.sh | sh

# Start Ollama service
print_status "Starting Ollama service..."
sudo systemctl enable ollama
sudo systemctl start ollama

# Wait for Ollama to be ready
print_status "Waiting for Ollama to be ready..."
sleep 5

# Download AI models
print_status "Downloading AI models (this may take several minutes)..."
print_warning "Downloading qwen2.5:7b-instruct-q4_k_m (4.7GB) - Primary model"
ollama pull qwen2.5:7b-instruct-q4_k_m

print_warning "Downloading gemma3:4b (3.3GB) - Medium complexity model"
ollama pull gemma3:4b

print_warning "Downloading llama3.2:3b (2GB) - Fast response model"
ollama pull llama3.2:3b

print_success "AI models downloaded successfully"

# Install PM2 for process management
print_status "Installing PM2 for process management..."
sudo npm install -g pm2

# Clone the repository (if not already present)
if [ ! -d "LZCustom" ]; then
    print_status "Cloning LZ Custom repository..."
    git clone https://github.com/george-shepov/LZCustom.git
    cd LZCustom
else
    print_status "Repository already exists, updating..."
    cd LZCustom
    git pull origin main
fi

# Install frontend dependencies
print_status "Installing frontend dependencies..."
cd frontend
npm install
print_success "Frontend dependencies installed"

# Build frontend for production
print_status "Building frontend for production..."
npm run build
print_success "Frontend built successfully"

# Install backend dependencies
print_status "Installing backend dependencies..."
cd ../backend
python3 -m venv venv
source venv/bin/activate
pip install fastapi uvicorn aiohttp sqlite3 pydantic

print_success "Backend dependencies installed"

# Create systemd service files
print_status "Creating systemd service files..."

# Backend service
sudo tee /etc/systemd/system/lzcustom-backend.service > /dev/null <<EOF
[Unit]
Description=LZ Custom Backend API
After=network.target ollama.service
Requires=ollama.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$(pwd)
Environment=PATH=$(pwd)/venv/bin
ExecStart=$(pwd)/venv/bin/python main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Frontend service (using a simple HTTP server)
sudo tee /etc/systemd/system/lzcustom-frontend.service > /dev/null <<EOF
[Unit]
Description=LZ Custom Frontend
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$(pwd)/../frontend
ExecStart=/usr/bin/npx serve -s dist -l 5173
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable services
print_status "Enabling and starting services..."
sudo systemctl daemon-reload
sudo systemctl enable lzcustom-backend
sudo systemctl enable lzcustom-frontend
sudo systemctl start lzcustom-backend
sudo systemctl start lzcustom-frontend

# Install nginx for reverse proxy (optional)
print_status "Installing and configuring nginx..."
sudo apt install -y nginx

# Create nginx configuration
sudo tee /etc/nginx/sites-available/lzcustom > /dev/null <<EOF
server {
    listen 80;
    server_name localhost;

    # Frontend
    location / {
        proxy_pass http://localhost:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Enable nginx site
sudo ln -sf /etc/nginx/sites-available/lzcustom /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx

# Install UFW firewall and configure
print_status "Configuring firewall..."
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw allow 8000  # Backend API
sudo ufw allow 5173  # Frontend dev server
sudo ufw allow 11434 # Ollama API

print_success "Firewall configured"

# Create startup script
print_status "Creating startup script..."
cat > ~/start-lzcustom.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting LZ Custom Website..."

# Start services
sudo systemctl start ollama
sudo systemctl start lzcustom-backend
sudo systemctl start lzcustom-frontend
sudo systemctl start nginx

# Check status
echo "📊 Service Status:"
sudo systemctl is-active ollama && echo "✅ Ollama: Running" || echo "❌ Ollama: Stopped"
sudo systemctl is-active lzcustom-backend && echo "✅ Backend: Running" || echo "❌ Backend: Stopped"
sudo systemctl is-active lzcustom-frontend && echo "✅ Frontend: Running" || echo "❌ Frontend: Stopped"
sudo systemctl is-active nginx && echo "✅ Nginx: Running" || echo "❌ Nginx: Stopped"

echo ""
echo "🌐 Website available at:"
echo "   Frontend: http://localhost:5173"
echo "   Backend API: http://localhost:8000"
echo "   Nginx Proxy: http://localhost"
echo ""
echo "📊 Analytics Dashboard: http://localhost:8000/api/analytics/dashboard"
echo "💬 Chat Conversations: http://localhost:8000/api/chat/conversations"
EOF

chmod +x ~/start-lzcustom.sh

# Create stop script
cat > ~/stop-lzcustom.sh << 'EOF'
#!/bin/bash
echo "🛑 Stopping LZ Custom Website..."

sudo systemctl stop lzcustom-frontend
sudo systemctl stop lzcustom-backend
sudo systemctl stop nginx

echo "✅ All services stopped"
EOF

chmod +x ~/stop-lzcustom.sh

# Final status check
print_status "Checking service status..."
sleep 5

echo ""
echo "📊 Service Status:"
sudo systemctl is-active ollama && print_success "Ollama: Running" || print_error "Ollama: Stopped"
sudo systemctl is-active lzcustom-backend && print_success "Backend: Running" || print_error "Backend: Stopped"
sudo systemctl is-active lzcustom-frontend && print_success "Frontend: Running" || print_error "Frontend: Stopped"
sudo systemctl is-active nginx && print_success "Nginx: Running" || print_error "Nginx: Stopped"

echo ""
print_success "🎉 LZ Custom Website Provisioning Complete!"
echo ""
echo "🌐 Access your website at:"
echo "   • Frontend: http://localhost:5173"
echo "   • Backend API: http://localhost:8000"
echo "   • Nginx Proxy: http://localhost"
echo ""
echo "📊 Management URLs:"
echo "   • Analytics Dashboard: http://localhost:8000/api/analytics/dashboard"
echo "   • Chat Conversations: http://localhost:8000/api/chat/conversations"
echo ""
echo "🔧 Management Scripts:"
echo "   • Start services: ~/start-lzcustom.sh"
echo "   • Stop services: ~/stop-lzcustom.sh"
echo ""
echo "📝 Service Management:"
echo "   • View backend logs: sudo journalctl -u lzcustom-backend -f"
echo "   • View frontend logs: sudo journalctl -u lzcustom-frontend -f"
echo "   • Restart backend: sudo systemctl restart lzcustom-backend"
echo "   • Restart frontend: sudo systemctl restart lzcustom-frontend"
echo ""
print_warning "Note: AI models are large (10GB+ total). Ensure adequate disk space."
print_warning "First AI responses may be slower as models load into memory."
echo ""
print_success "Happy fabricating! 🏗️"
