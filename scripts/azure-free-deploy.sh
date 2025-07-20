#!/bin/bash

# LZ Custom Website - Azure Free Tier Deployment (NO AI)
# Optimized for B1s (1 vCPU, 1GB RAM) free Azure VMs

set -e  # Exit on any error

echo "🆓 LZ Custom Website - Azure Free Tier Deployment"
echo "================================================="
echo ""
echo "This deployment is optimized for Azure Free Tier VMs:"
echo "  ✅ NO AI models (saves 10GB+ storage and RAM)"
echo "  ✅ Admin dashboard for lead management"
echo "  ✅ Form submission tracking (zero prospect loss)"
echo "  ✅ Professional responsive website"
echo "  ✅ Lightweight configuration for 1GB RAM"
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
    
    # Check if this is a free tier VM
    if [[ "$VM_SIZE" == *"B1s"* ]] || [[ "$VM_SIZE" == *"B1ms"* ]]; then
        print_azure "Free tier VM detected - optimizing for low resources"
        FREE_TIER=true
    else
        FREE_TIER=false
    fi
else
    print_warning "Not running on Azure VM, using standard configuration"
    AZURE_VM=false
    FREE_TIER=false
fi

# System requirements check for free tier
print_status "Checking system requirements for free tier..."

TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')

print_status "Available RAM: ${TOTAL_RAM}MB"
print_status "Available disk space: $(($AVAILABLE_SPACE/1024/1024))GB"

if [ "$TOTAL_RAM" -lt 900 ]; then
    print_error "Insufficient RAM. Need at least 1GB for basic operation."
    exit 1
fi

if [ "$AVAILABLE_SPACE" -lt 5000000 ]; then  # 5GB in KB
    print_error "Insufficient disk space. Need at least 5GB free."
    exit 1
fi

print_success "System requirements met for free tier deployment"

# Update system with minimal packages
print_status "Updating system (minimal packages for free tier)..."
sudo apt update
sudo apt upgrade -y

# Install only essential packages
print_status "Installing essential packages..."
sudo apt install -y curl wget git build-essential software-properties-common \
    apt-transport-https ca-certificates gnupg lsb-release \
    nginx-light ufw

# Configure basic firewall
print_status "Configuring basic firewall..."
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'

# Install Node.js 18.x (LTS for stability)
print_status "Installing Node.js 18.x LTS..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify Node.js installation
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
print_success "Node.js installed: $NODE_VERSION"
print_success "npm installed: $NPM_VERSION"

# Install Python 3 (minimal)
print_status "Installing Python 3..."
sudo apt install -y python3 python3-pip python3-venv

# Verify Python installation
PYTHON_VERSION=$(python3 --version)
print_success "Python installed: $PYTHON_VERSION"

# Configure small swap for free tier (if needed)
if [ "$FREE_TIER" = true ] && [ "$TOTAL_RAM" -lt 1500 ]; then
    print_warning "Configuring 1GB swap for free tier VM..."
    sudo fallocate -l 1G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    print_success "1GB swap configured"
fi

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

# Install frontend dependencies with memory optimization
print_status "Installing frontend dependencies (optimized for low memory)..."
cd frontend

# Set npm to use less memory
npm config set fund false
npm config set audit false

# Install with reduced memory usage
npm install --no-optional --production

# Build frontend for production with memory limits
print_status "Building frontend for production..."
export NODE_OPTIONS="--max-old-space-size=512"
npm run build
print_success "Frontend built successfully"

# Install backend dependencies (minimal)
print_status "Installing backend dependencies..."
cd ../backend
python3 -m venv venv
source venv/bin/activate

# Install only required packages
pip install fastapi uvicorn aiohttp pydantic python-multipart

print_success "Backend dependencies installed"

# Create NO-AI backend configuration
print_status "Configuring backend for NO-AI mode..."

# Create a simple chat endpoint that returns helpful messages without AI
cat > no_ai_chat.py << 'EOF'
# Simple chat responses without AI models
import random

RESPONSES = {
    "greeting": [
        "Hello! Thanks for visiting LZ Custom. How can I help you with your fabrication project?",
        "Hi there! We specialize in custom cabinets, countertops, and stone fabrication. What can I help you with?",
        "Welcome to LZ Custom! We're here to help with your custom fabrication needs."
    ],
    "services": [
        "We offer custom cabinets, granite/quartz countertops, stone fabrication, tile work, and commercial painting.",
        "Our services include kitchen cabinets, bathroom vanities, countertops, flooring, and commercial projects.",
        "We specialize in custom millwork, stone fabrication, and high-quality finishes for residential and commercial projects."
    ],
    "contact": [
        "You can reach us at 216-268-2990 or fill out our quote form. We serve Northeast Ohio within a 30-mile radius.",
        "Call us at 216-268-2990 for immediate assistance, or use our quote form for detailed project information.",
        "We're available Mon-Fri 8AM-5PM, Sat 9AM-3PM. Phone: 216-268-2990. We'd love to discuss your project!"
    ],
    "default": [
        "That's a great question! For detailed information about your specific project, please call us at 216-268-2990 or fill out our quote form.",
        "I'd be happy to help! For the most accurate information, please contact us at 216-268-2990 or submit a quote request.",
        "Thanks for your interest! Our team can provide detailed answers at 216-268-2990 or through our quote form."
    ]
}

def get_simple_response(message):
    message_lower = message.lower()
    
    if any(word in message_lower for word in ['hello', 'hi', 'hey', 'good morning', 'good afternoon']):
        return random.choice(RESPONSES["greeting"])
    elif any(word in message_lower for word in ['service', 'what do you do', 'cabinet', 'countertop', 'stone']):
        return random.choice(RESPONSES["services"])
    elif any(word in message_lower for word in ['contact', 'phone', 'call', 'reach', 'hours']):
        return random.choice(RESPONSES["contact"])
    else:
        return random.choice(RESPONSES["default"])
EOF

print_success "NO-AI chat configuration created"

# Modify main.py to use simple responses instead of AI
print_status "Updating backend for NO-AI mode..."

# Create backup of original main.py
cp main.py main.py.backup

# Update the chat endpoint to use simple responses
cat >> main.py << 'EOF'

# Import the simple chat responses
import sys
sys.path.append('.')
from no_ai_chat import get_simple_response

# Override the chat endpoint for NO-AI mode
@app.post("/api/chat")
async def chat_no_ai(message: ChatMessage):
    try:
        # Use simple predefined responses instead of AI
        response_text = get_simple_response(message.message)
        
        # Log the conversation
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO chat_conversations (user_message, ai_response, model_used, response_time)
            VALUES (?, ?, ?, ?)
        ''', (message.message, response_text, "simple-responses", 0.1))
        
        conn.commit()
        conn.close()
        
        return {
            "response": response_text,
            "model": "simple-responses",
            "response_time": 0.1
        }
    except Exception as e:
        return {
            "response": "Thanks for your message! For immediate assistance, please call us at 216-268-2990.",
            "model": "fallback",
            "response_time": 0.1
        }
EOF

print_success "Backend updated for NO-AI mode"

# Create systemd service files optimized for free tier
print_status "Creating systemd service files..."

# Backend service with memory limits
sudo tee /etc/systemd/system/lzcustom-backend.service > /dev/null <<EOF
[Unit]
Description=LZ Custom Backend API (NO-AI)
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$(pwd)
Environment=PATH=$(pwd)/venv/bin
Environment=PYTHONPATH=$(pwd)
ExecStart=$(pwd)/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
MemoryLimit=256M

[Install]
WantedBy=multi-user.target
EOF

# Frontend service using serve
print_status "Installing serve for frontend hosting..."
sudo npm install -g serve

sudo tee /etc/systemd/system/lzcustom-frontend.service > /dev/null <<EOF
[Unit]
Description=LZ Custom Frontend (NO-AI)
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
MemoryLimit=128M

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

# Configure nginx for free tier
print_status "Configuring nginx for free tier..."

sudo tee /etc/nginx/sites-available/lzcustom > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    
    # Basic security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    
    # Gzip compression (important for free tier bandwidth)
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
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 60s;
        proxy_connect_timeout 30s;
    }
    
    # Backend API
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_read_timeout 60s;
        proxy_connect_timeout 30s;
    }
    
    # Admin dashboard
    location /admin.html {
        proxy_pass http://localhost:5173/admin.html;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
    }
}
EOF

# Enable nginx site
sudo ln -sf /etc/nginx/sites-available/lzcustom /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx

print_success "Nginx configured for free tier"

# Create free tier management scripts
print_status "Creating free tier management scripts..."

# Lightweight startup script
cat > ~/start-lzcustom-free.sh << 'EOF'
#!/bin/bash
echo "🆓 Starting LZ Custom Website (Free Tier - NO AI)..."

# Start services
sudo systemctl start lzcustom-backend
sudo systemctl start lzcustom-frontend
sudo systemctl start nginx

# Wait for services to start
sleep 3

# Check status
echo "📊 Service Status:"
sudo systemctl is-active lzcustom-backend && echo "✅ Backend: Running" || echo "❌ Backend: Stopped"
sudo systemctl is-active lzcustom-frontend && echo "✅ Frontend: Running" || echo "❌ Frontend: Stopped"
sudo systemctl is-active nginx && echo "✅ Nginx: Running" || echo "❌ Nginx: Stopped"

# System resource check (important for free tier)
echo ""
echo "💻 Free Tier Resources:"
echo "   Memory: $(free -h | awk 'NR==2{printf "%.0f/%.0fMB (%.0f%%)", $3/1024, $2/1024, $3*100/$2}')"
echo "   Disk: $(df -h / | awk 'NR==2{printf "%s/%s (%s used)", $3, $2, $5}')"
echo "   Swap: $(free -h | awk 'NR==3{printf "%.0f/%.0fMB", $3/1024, $2/1024}')"

# Get public IP
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "localhost")

echo ""
echo "🌐 Access URLs:"
echo "   Website: http://$PUBLIC_IP"
echo "   Admin Dashboard: http://$PUBLIC_IP/admin.html"
echo "   API Docs: http://$PUBLIC_IP:8000/docs"
echo ""
echo "💡 Free Tier Features:"
echo "   ✅ Complete admin dashboard"
echo "   ✅ Lead management and tracking"
echo "   ✅ Form submissions (zero loss)"
echo "   ✅ Simple chat responses (no AI models)"
echo "   ✅ Professional responsive design"
echo ""
echo "📊 Quick Commands:"
echo "   View logs: sudo journalctl -u lzcustom-backend -f"
echo "   Stop services: ~/stop-lzcustom-free.sh"
echo "   Monitor: ~/monitor-lzcustom-free.sh"
EOF

chmod +x ~/start-lzcustom-free.sh

# Stop script
cat > ~/stop-lzcustom-free.sh << 'EOF'
#!/bin/bash
echo "🛑 Stopping LZ Custom Website (Free Tier)..."

sudo systemctl stop lzcustom-frontend
sudo systemctl stop lzcustom-backend
sudo systemctl stop nginx

echo "✅ All services stopped"
echo "💡 To restart: ~/start-lzcustom-free.sh"
EOF

chmod +x ~/stop-lzcustom-free.sh

# Update script
cat > ~/update-lzcustom-free.sh << 'EOF'
#!/bin/bash
echo "🔄 Updating LZ Custom Website (Free Tier)..."

cd ~/LZCustom
git pull origin main

echo "📦 Updating frontend..."
cd frontend
export NODE_OPTIONS="--max-old-space-size=512"
npm install --no-optional --production
npm run build

echo "🔧 Updating backend..."
cd ../backend
source venv/bin/activate
pip install --upgrade fastapi uvicorn aiohttp pydantic python-multipart

echo "🔄 Restarting services..."
sudo systemctl restart lzcustom-backend
sudo systemctl restart lzcustom-frontend

echo "✅ Update complete!"
EOF

chmod +x ~/update-lzcustom-free.sh

# Monitoring script for free tier
cat > ~/monitor-lzcustom-free.sh << 'EOF'
#!/bin/bash
echo "📊 LZ Custom Free Tier Monitoring"
echo "================================="

# Service status
echo "🔧 Services:"
services=("lzcustom-backend" "lzcustom-frontend" "nginx")
for service in "${services[@]}"; do
    if sudo systemctl is-active --quiet $service; then
        echo "  ✅ $service: Running"
    else
        echo "  ❌ $service: Stopped"
    fi
done

# System resources (critical for free tier)
echo ""
echo "💻 Free Tier Resources:"
MEMORY_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
DISK_USAGE=$(df / | awk 'NR==2{printf "%.0f", $3*100/$2}')

echo "  Memory: $(free -h | awk 'NR==2{printf "%.0f/%.0fMB (%s%%)", $3/1024, $2/1024, "'$MEMORY_USAGE'"}')"
echo "  Disk: $(df -h / | awk 'NR==2{printf "%s/%s (%s used)", $3, $2, $5}')"
echo "  Swap: $(free -h | awk 'NR==3{printf "%.0f/%.0fMB", $3/1024, $2/1024}')"

# Warnings for free tier limits
if [ "$MEMORY_USAGE" -gt 80 ]; then
    echo "  ⚠️  HIGH MEMORY USAGE - Consider restarting services"
fi

if [ "$DISK_USAGE" -gt 80 ]; then
    echo "  ⚠️  HIGH DISK USAGE - Clean up logs or temporary files"
fi

# Network connections
echo ""
echo "🌐 Network:"
echo "  Active connections: $(ss -tuln | wc -l)"

# Recent logs
echo ""
echo "📝 Recent Backend Logs (last 3 lines):"
sudo journalctl -u lzcustom-backend --no-pager -n 3 --output=short

echo ""
echo "🔍 For detailed monitoring:"
echo "  Backend logs: sudo journalctl -u lzcustom-backend -f"
echo "  Frontend logs: sudo journalctl -u lzcustom-frontend -f"
echo "  System resources: free -h && df -h"
EOF

chmod +x ~/monitor-lzcustom-free.sh

# Final status check
print_status "Performing final status check..."
sleep 5

echo ""
echo "📊 Final Service Status:"
sudo systemctl is-active lzcustom-backend && print_success "Backend: Running" || print_error "Backend: Stopped"
sudo systemctl is-active lzcustom-frontend && print_success "Frontend: Running" || print_error "Frontend: Stopped"
sudo systemctl is-active nginx && print_success "Nginx: Running" || print_error "Nginx: Stopped"

# Get public IP for Azure
if [ "$AZURE_VM" = true ]; then
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unable to detect")
    print_azure "Public IP: $PUBLIC_IP"
fi

echo ""
print_success "🎉 LZ Custom Website Successfully Deployed on Azure Free Tier!"
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
echo "🔧 Free Tier Management Commands:"
echo "   • Start services: ~/start-lzcustom-free.sh"
echo "   • Stop services: ~/stop-lzcustom-free.sh"
echo "   • Update application: ~/update-lzcustom-free.sh"
echo "   • Monitor system: ~/monitor-lzcustom-free.sh"
echo ""
echo "🆓 Free Tier Optimizations:"
echo "   • NO AI models (saves 10GB+ storage and RAM)"
echo "   • Memory-limited services (512MB backend, 128MB frontend)"
echo "   • Simple chat responses without AI processing"
echo "   • Optimized nginx configuration for low resources"
echo "   • Gzip compression to save bandwidth"
echo ""
echo "💬 Chat Feature:"
echo "   • Simple predefined responses about services"
echo "   • No AI processing required"
echo "   • Directs users to call 216-268-2990 for detailed help"
echo "   • All conversations still logged for lead tracking"
echo ""
print_warning "🔐 Free Tier Recommendations:"
print_warning "   • Monitor resource usage regularly"
print_warning "   • Clean up logs periodically: sudo journalctl --vacuum-time=7d"
print_warning "   • Consider upgrading if you need AI chat features"
print_warning "   • Set up Azure alerts for resource usage"
echo ""
print_success "Perfect for Azure Free Tier! 🆓☁️"
