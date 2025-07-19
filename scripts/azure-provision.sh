#!/bin/bash

# LZ Custom Website - Azure Ubuntu Provisioning Script
# Optimized for Azure VM deployment with enhanced security and performance

set -e  # Exit on any error

echo "🌐 LZ Custom Website - Azure Ubuntu Deployment"
echo "=============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

print_azure() {
    echo -e "${PURPLE}[AZURE]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

# Detect Azure environment
print_azure "Detecting Azure environment..."
if curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2021-02-01" > /dev/null 2>&1; then
    print_success "Running on Azure VM"
    AZURE_VM=true
    
    # Get Azure VM metadata
    VM_SIZE=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute/vmSize?api-version=2021-02-01&format=text")
    VM_LOCATION=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute/location?api-version=2021-02-01&format=text")
    print_azure "VM Size: $VM_SIZE"
    print_azure "Location: $VM_LOCATION"
else
    print_warning "Not running on Azure VM, using standard configuration"
    AZURE_VM=false
fi

# System optimization for Azure
print_status "Optimizing system for Azure..."
sudo apt update && sudo apt upgrade -y

# Install Azure CLI (if on Azure)
if [ "$AZURE_VM" = true ]; then
    print_azure "Installing Azure CLI..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

# Install essential packages
print_status "Installing essential packages..."
sudo apt install -y curl wget git build-essential software-properties-common \
    apt-transport-https ca-certificates gnupg lsb-release htop unzip \
    fail2ban ufw nginx-extras

# Configure fail2ban for SSH protection
print_status "Configuring fail2ban for SSH protection..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

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

# Configure swap for AI workloads (if not enough RAM)
TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
if [ "$TOTAL_RAM" -lt 8192 ]; then
    print_warning "RAM is ${TOTAL_RAM}MB, configuring swap for AI workloads..."
    sudo fallocate -l 4G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    print_success "4GB swap configured"
fi

# Install Ollama for local AI models
print_status "Installing Ollama for local AI models..."
curl -fsSL https://ollama.ai/install.sh | sh

# Configure Ollama service
print_status "Configuring Ollama service..."
sudo systemctl enable ollama
sudo systemctl start ollama

# Wait for Ollama to be ready
print_status "Waiting for Ollama to be ready..."
sleep 10

# Download AI models (optimized for Azure)
print_status "Downloading AI models (optimized for Azure bandwidth)..."

# Check available disk space
AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')
REQUIRED_SPACE=15000000  # 15GB in KB

if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    print_error "Insufficient disk space. Need at least 15GB free for AI models."
    print_error "Available: $(($AVAILABLE_SPACE/1024/1024))GB, Required: 15GB"
    exit 1
fi

# Download models with progress indication
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

# Clone the repository
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

# Build frontend for production
print_status "Building frontend for production..."
npm run build
print_success "Frontend built successfully"

# Install backend dependencies
print_status "Installing backend dependencies..."
cd ../backend
python3 -m venv venv
source venv/bin/activate
pip install fastapi uvicorn aiohttp pydantic python-multipart

print_success "Backend dependencies installed"

# Create optimized systemd service files
print_status "Creating systemd service files..."

# Backend service with Azure optimizations
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
Environment=PYTHONPATH=$(pwd)
ExecStart=$(pwd)/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000 --workers 2
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Frontend service using serve
print_status "Installing serve for frontend hosting..."
sudo npm install -g serve

sudo tee /etc/systemd/system/lzcustom-frontend.service > /dev/null <<EOF
[Unit]
Description=LZ Custom Frontend
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$(pwd)/../frontend
ExecStart=/usr/bin/serve -s dist -l 5173 --no-clipboard
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

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

# Configure nginx with Azure optimizations
print_status "Configuring nginx with Azure optimizations..."

sudo tee /etc/nginx/sites-available/lzcustom > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
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
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
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
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
    
    # Admin dashboard
    location /admin.html {
        proxy_pass http://localhost:5173/admin.html;
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
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx

# Configure UFW firewall for Azure
print_status "Configuring firewall for Azure..."
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw allow 8000/tcp  # Backend API
sudo ufw allow 5173/tcp  # Frontend
sudo ufw allow 11434/tcp # Ollama API

print_success "Firewall configured for Azure"

# Create Azure-optimized management scripts
print_status "Creating Azure management scripts..."

# Enhanced startup script with Azure monitoring
cat > ~/start-lzcustom.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting LZ Custom Website on Azure..."

# Check Azure VM metadata
if curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2021-02-01" > /dev/null 2>&1; then
    VM_SIZE=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute/vmSize?api-version=2021-02-01&format=text")
    echo "🌐 Azure VM Size: $VM_SIZE"
fi

# Start services
sudo systemctl start ollama
sudo systemctl start lzcustom-backend
sudo systemctl start lzcustom-frontend
sudo systemctl start nginx

# Wait for services to start
sleep 5

# Check status with enhanced monitoring
echo "📊 Service Status:"
sudo systemctl is-active ollama && echo "✅ Ollama: Running" || echo "❌ Ollama: Stopped"
sudo systemctl is-active lzcustom-backend && echo "✅ Backend: Running" || echo "❌ Backend: Stopped"
sudo systemctl is-active lzcustom-frontend && echo "✅ Frontend: Running" || echo "❌ Frontend: Stopped"
sudo systemctl is-active nginx && echo "✅ Nginx: Running" || echo "❌ Nginx: Stopped"

# System resource check
echo ""
echo "💻 System Resources:"
echo "   Memory: $(free -h | awk 'NR==2{printf "%.1f/%.1fGB (%.0f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')"
echo "   Disk: $(df -h / | awk 'NR==2{printf "%s/%s (%s used)", $3, $2, $5}')"
echo "   Load: $(uptime | awk -F'load average:' '{print $2}')"

# Get public IP
if command -v az &> /dev/null; then
    PUBLIC_IP=$(curl -s ifconfig.me)
    echo ""
    echo "🌐 Access URLs:"
    echo "   Website: http://$PUBLIC_IP"
    echo "   Admin Dashboard: http://$PUBLIC_IP/admin.html"
    echo "   API Docs: http://$PUBLIC_IP:8000/docs"
else
    echo ""
    echo "🌐 Website available at:"
    echo "   Local: http://localhost"
    echo "   Admin: http://localhost/admin.html"
fi

echo ""
echo "📊 Quick Commands:"
echo "   View logs: sudo journalctl -u lzcustom-backend -f"
echo "   Stop services: ~/stop-lzcustom.sh"
echo "   System status: htop"
EOF

chmod +x ~/start-lzcustom.sh

# Enhanced stop script
cat > ~/stop-lzcustom.sh << 'EOF'
#!/bin/bash
echo "🛑 Stopping LZ Custom Website..."

sudo systemctl stop lzcustom-frontend
sudo systemctl stop lzcustom-backend
sudo systemctl stop nginx

echo "✅ All services stopped"
echo "💡 Ollama left running for faster startup"
echo "   To stop Ollama: sudo systemctl stop ollama"
EOF

chmod +x ~/stop-lzcustom.sh

# Create update script
cat > ~/update-lzcustom.sh << 'EOF'
#!/bin/bash
echo "🔄 Updating LZ Custom Website..."

cd ~/LZCustom
git pull origin main

echo "📦 Updating frontend..."
cd frontend
npm install
npm run build

echo "🔧 Updating backend..."
cd ../backend
source venv/bin/activate
pip install --upgrade -r requirements.txt 2>/dev/null || echo "No requirements.txt found"

echo "🔄 Restarting services..."
sudo systemctl restart lzcustom-backend
sudo systemctl restart lzcustom-frontend

echo "✅ Update complete!"
EOF

chmod +x ~/update-lzcustom.sh

# Create monitoring script
cat > ~/monitor-lzcustom.sh << 'EOF'
#!/bin/bash
echo "📊 LZ Custom Website Monitoring"
echo "==============================="

# Service status
echo "🔧 Services:"
services=("ollama" "lzcustom-backend" "lzcustom-frontend" "nginx")
for service in "${services[@]}"; do
    if sudo systemctl is-active --quiet $service; then
        echo "  ✅ $service: Running"
    else
        echo "  ❌ $service: Stopped"
    fi
done

# System resources
echo ""
echo "💻 System Resources:"
echo "  Memory: $(free -h | awk 'NR==2{printf "%.1f/%.1fGB (%.0f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')"
echo "  Disk: $(df -h / | awk 'NR==2{printf "%s/%s (%s used)", $3, $2, $5}')"
echo "  CPU Load: $(uptime | awk -F'load average:' '{print $2}')"

# Network connections
echo ""
echo "🌐 Network:"
echo "  Active connections: $(ss -tuln | wc -l)"
echo "  Listening ports: $(ss -tuln | grep LISTEN | awk '{print $5}' | cut -d: -f2 | sort -n | uniq | tr '\n' ' ')"

# Recent logs
echo ""
echo "📝 Recent Backend Logs (last 5 lines):"
sudo journalctl -u lzcustom-backend --no-pager -n 5 --output=short

echo ""
echo "🔍 For detailed monitoring:"
echo "  Backend logs: sudo journalctl -u lzcustom-backend -f"
echo "  Frontend logs: sudo journalctl -u lzcustom-frontend -f"
echo "  System monitor: htop"
EOF

chmod +x ~/monitor-lzcustom.sh

# Final status check
print_status "Performing final status check..."
sleep 10

echo ""
echo "📊 Final Service Status:"
sudo systemctl is-active ollama && print_success "Ollama: Running" || print_error "Ollama: Stopped"
sudo systemctl is-active lzcustom-backend && print_success "Backend: Running" || print_error "Backend: Stopped"
sudo systemctl is-active lzcustom-frontend && print_success "Frontend: Running" || print_error "Frontend: Stopped"
sudo systemctl is-active nginx && print_success "Nginx: Running" || print_error "Nginx: Stopped"

# Get public IP for Azure
if [ "$AZURE_VM" = true ]; then
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unable to detect")
    print_azure "Public IP: $PUBLIC_IP"
fi

echo ""
print_success "🎉 LZ Custom Website Successfully Deployed on Azure!"
echo ""
if [ "$AZURE_VM" = true ] && [ "$PUBLIC_IP" != "Unable to detect" ]; then
    echo "🌐 Access your website at:"
    echo "   • Website: http://$PUBLIC_IP"
    echo "   • Admin Dashboard: http://$PUBLIC_IP/admin.html"
    echo "   • API Documentation: http://$PUBLIC_IP:8000/docs"
else
    echo "🌐 Access your website at:"
    echo "   • Website: http://localhost"
    echo "   • Admin Dashboard: http://localhost/admin.html"
    echo "   • API Documentation: http://localhost:8000/docs"
fi
echo ""
echo "🔧 Management Commands:"
echo "   • Start services: ~/start-lzcustom.sh"
echo "   • Stop services: ~/stop-lzcustom.sh"
echo "   • Update application: ~/update-lzcustom.sh"
echo "   • Monitor system: ~/monitor-lzcustom.sh"
echo ""
echo "📊 Azure-Specific Features:"
echo "   • Optimized for Azure VM performance"
echo "   • Enhanced security with fail2ban"
echo "   • Automatic swap configuration for AI workloads"
echo "   • Azure CLI integration (if available)"
echo ""
print_warning "🔐 Security Recommendations:"
print_warning "   • Change default SSH keys if using password auth"
print_warning "   • Configure SSL certificate for production use"
print_warning "   • Set up Azure backup for data protection"
print_warning "   • Monitor Azure costs and resource usage"
echo ""
print_success "Happy fabricating on Azure! 🏗️☁️"
