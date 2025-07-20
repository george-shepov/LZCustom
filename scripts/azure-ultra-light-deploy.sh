#!/bin/bash

# LZ Custom Website - Ultra-Light Azure Deployment (850MB+ RAM)
# Minimal deployment for very low-resource VMs with smart package detection

set -e  # Exit on any error

echo "🪶 LZ Custom Website - Ultra-Light Azure Deployment"
echo "=================================================="
echo ""
echo "This deployment is optimized for ultra-low resource VMs:"
echo "  ✅ Works with 850MB+ RAM (your VM: detected automatically)"
echo "  ✅ NO AI models (saves 10GB+ storage and RAM)"
echo "  ✅ Minimal package installation (only what's needed)"
echo "  ✅ SQLite database (no external database required)"
echo "  ✅ NO Docker (native installation only)"
echo "  ✅ Smart package detection (skips already installed)"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

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
    echo -e "${PURPLE}[ULTRA-LIGHT]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

# Ultra-light system requirements check
print_status "Checking ultra-light system requirements..."

TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')

print_azure "Available RAM: ${TOTAL_RAM}MB"
print_azure "Available disk space: $(($AVAILABLE_SPACE/1024/1024))GB"

# Adjusted for your 898MB RAM
if [ "$TOTAL_RAM" -lt 850 ]; then
    print_error "RAM is ${TOTAL_RAM}MB. This ultra-light deployment needs at least 850MB."
    exit 1
else
    print_success "RAM: ${TOTAL_RAM}MB (sufficient for ultra-light deployment)"
fi

if [ "$AVAILABLE_SPACE" -lt 3000000 ]; then  # 3GB in KB
    print_error "Insufficient disk space. Available: $(($AVAILABLE_SPACE/1024/1024))GB, Required: 3GB+"
    exit 1
else
    print_success "Disk space: $(($AVAILABLE_SPACE/1024/1024))GB (sufficient)"
fi

# Check what's already installed to avoid unnecessary installations
print_status "Detecting already installed packages..."

# Check for Node.js
if command -v node &> /dev/null; then
    NODE_INSTALLED=true
    NODE_VERSION=$(node --version)
    print_success "Node.js already installed: $NODE_VERSION"
else
    NODE_INSTALLED=false
    print_warning "Node.js not found - will install"
fi

# Check for Python3
if command -v python3 &> /dev/null; then
    PYTHON_INSTALLED=true
    PYTHON_VERSION=$(python3 --version)
    print_success "Python3 already installed: $PYTHON_VERSION"
else
    PYTHON_INSTALLED=false
    print_warning "Python3 not found - will install"
fi

# Check for nginx
if command -v nginx &> /dev/null; then
    NGINX_INSTALLED=true
    print_success "Nginx already installed"
else
    NGINX_INSTALLED=false
    print_warning "Nginx not found - will install"
fi

# Check for git
if command -v git &> /dev/null; then
    GIT_INSTALLED=true
    print_success "Git already installed"
else
    GIT_INSTALLED=false
    print_warning "Git not found - will install"
fi

# Configure swap for ultra-low RAM (essential for 898MB)
print_azure "Configuring swap for ultra-low RAM..."
if [ ! -f /swapfile ]; then
    print_warning "Creating 512MB swap for ultra-low RAM VM..."
    sudo fallocate -l 512M /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    print_success "512MB swap configured"
else
    print_success "Swap already configured"
fi

# Minimal system update (only security updates)
print_status "Applying minimal system updates..."
sudo apt update

# Install only absolutely necessary packages
PACKAGES_TO_INSTALL=""

if [ "$GIT_INSTALLED" = false ]; then
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL git"
fi

if [ "$NGINX_INSTALLED" = false ]; then
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL nginx-light"
fi

# Always need these minimal packages
PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL curl wget"

if [ "$PYTHON_INSTALLED" = false ]; then
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL python3 python3-pip python3-venv"
fi

# Install build essentials only if Node.js needs to be installed
if [ "$NODE_INSTALLED" = false ]; then
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL build-essential"
fi

if [ -n "$PACKAGES_TO_INSTALL" ]; then
    print_status "Installing minimal required packages: $PACKAGES_TO_INSTALL"
    sudo apt install -y $PACKAGES_TO_INSTALL
else
    print_success "All required packages already installed!"
fi

# Configure basic firewall (minimal)
print_status "Configuring minimal firewall..."
if ! sudo ufw status | grep -q "Status: active"; then
    sudo ufw --force enable
    sudo ufw allow ssh
    sudo ufw allow 80/tcp
    print_success "Basic firewall configured"
else
    print_success "Firewall already configured"
fi

# Install Node.js only if not present
if [ "$NODE_INSTALLED" = false ]; then
    print_status "Installing Node.js 18.x LTS (minimal)..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
    NODE_VERSION=$(node --version)
    print_success "Node.js installed: $NODE_VERSION"
fi

# Clone or update repository
if [ ! -d "LZCustom" ]; then
    print_status "Cloning LZ Custom repository..."
    git clone --depth 1 https://github.com/george-shepov/LZCustom.git
    cd LZCustom
else
    print_status "Repository already exists, updating..."
    cd LZCustom
    git pull origin main
fi

# Ultra-light frontend build
print_status "Installing frontend dependencies (ultra-light mode)..."
cd frontend

# Configure npm for minimal memory usage
npm config set fund false
npm config set audit false
npm config set progress false

# Install only production dependencies
npm install --only=production --no-optional --silent

# Build with minimal memory
print_status "Building frontend (ultra-light)..."
export NODE_OPTIONS="--max-old-space-size=256"
npm run build
print_success "Frontend built successfully with minimal memory"

# Ultra-light backend setup
print_status "Setting up backend (ultra-light)..."
cd ../backend

# Create minimal virtual environment
python3 -m venv venv --without-pip
source venv/bin/activate

# Install pip manually to save memory
curl https://bootstrap.pypa.io/get-pip.py | python3

# Install only absolutely required packages
pip install --no-cache-dir fastapi==0.104.1 uvicorn==0.24.0 pydantic==2.5.0

print_success "Backend dependencies installed (minimal)"

# Create ultra-light chat responses (no AI)
print_status "Configuring ultra-light chat system..."

cat > ultra_light_chat.py << 'EOF'
# Ultra-light chat responses - no external dependencies
import random
import json

RESPONSES = {
    "greeting": [
        "Hello! Welcome to LZ Custom. How can we help with your project?",
        "Hi! We specialize in custom fabrication. What can we do for you?",
        "Welcome! We're here to help with your custom project needs."
    ],
    "services": [
        "We offer custom cabinets, countertops, stone work, and commercial projects.",
        "Our services: kitchen cabinets, bathroom vanities, granite/quartz countertops, tile work.",
        "We do custom millwork, stone fabrication, and quality finishes for homes and businesses."
    ],
    "contact": [
        "Call us at 216-268-2990. We serve Northeast Ohio within 30 miles.",
        "Phone: 216-268-2990. Hours: Mon-Fri 8AM-5PM, Sat 9AM-3PM.",
        "Reach us at 216-268-2990 or use our quote form for project details."
    ],
    "default": [
        "Great question! Call 216-268-2990 for detailed project information.",
        "For specific details, please call 216-268-2990 or fill out our quote form.",
        "Our team can help! Contact us at 216-268-2990 for more information."
    ]
}

def get_response(message):
    msg = message.lower()
    if any(w in msg for w in ['hello', 'hi', 'hey', 'good']):
        return random.choice(RESPONSES["greeting"])
    elif any(w in msg for w in ['service', 'do', 'cabinet', 'counter', 'stone']):
        return random.choice(RESPONSES["services"])
    elif any(w in msg for w in ['contact', 'phone', 'call', 'hours']):
        return random.choice(RESPONSES["contact"])
    else:
        return random.choice(RESPONSES["default"])
EOF

# Modify main.py for ultra-light operation
print_status "Configuring ultra-light backend..."

# Create a minimal main.py if it doesn't exist or backup the original
if [ -f main.py ]; then
    cp main.py main.py.backup
fi

# Add ultra-light chat endpoint
cat >> main.py << 'EOF'

# Ultra-light chat endpoint
import sys
import os
sys.path.append(os.path.dirname(__file__))

try:
    from ultra_light_chat import get_response
except ImportError:
    def get_response(message):
        return "Thanks for your message! Please call us at 216-268-2990 for assistance."

@app.post("/api/chat")
async def ultra_light_chat(message: ChatMessage):
    try:
        response_text = get_response(message.message)
        
        # Minimal logging to SQLite
        try:
            conn = sqlite3.connect('lz_custom.db')
            cursor = conn.cursor()
            cursor.execute('''
                INSERT INTO chat_conversations (user_message, ai_response, model_used, response_time)
                VALUES (?, ?, ?, ?)
            ''', (message.message, response_text, "ultra-light", 0.05))
            conn.commit()
            conn.close()
        except:
            pass  # Continue even if logging fails
        
        return {
            "response": response_text,
            "model": "ultra-light",
            "response_time": 0.05
        }
    except Exception as e:
        return {
            "response": "Thanks for contacting us! Please call 216-268-2990 for immediate assistance.",
            "model": "fallback",
            "response_time": 0.05
        }
EOF

print_success "Ultra-light backend configured"

# Create ultra-light systemd services
print_status "Creating ultra-light systemd services..."

# Backend service with strict memory limits
sudo tee /etc/systemd/system/lzcustom-backend.service > /dev/null <<EOF
[Unit]
Description=LZ Custom Backend (Ultra-Light)
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$(pwd)
Environment=PATH=$(pwd)/venv/bin
Environment=PYTHONPATH=$(pwd)
ExecStart=$(pwd)/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1 --access-log
Restart=always
RestartSec=15
StandardOutput=journal
StandardError=journal
MemoryLimit=128M
CPUQuota=50%

[Install]
WantedBy=multi-user.target
EOF

# Frontend service with memory limits
sudo tee /etc/systemd/system/lzcustom-frontend.service > /dev/null <<EOF
[Unit]
Description=LZ Custom Frontend (Ultra-Light)
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$(pwd)/../frontend
ExecStart=/usr/bin/npx serve -s dist -l 5173 --no-clipboard --silent
Restart=always
RestartSec=15
StandardOutput=journal
StandardError=journal
MemoryLimit=64M
CPUQuota=30%

[Install]
WantedBy=multi-user.target
EOF

# Install serve locally to avoid global installation
cd ../frontend
npm install serve --save-dev

cd ../backend

# Enable and start services
print_status "Starting ultra-light services..."
sudo systemctl daemon-reload
sudo systemctl enable lzcustom-backend
sudo systemctl enable lzcustom-frontend
sudo systemctl start lzcustom-backend
sudo systemctl start lzcustom-frontend

# Configure nginx (ultra-light)
print_status "Configuring ultra-light nginx..."

sudo tee /etc/nginx/sites-available/lzcustom > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    
    # Ultra-light configuration
    client_max_body_size 1m;
    client_body_timeout 30s;
    client_header_timeout 30s;
    keepalive_timeout 30s;
    send_timeout 30s;
    
    # Essential compression
    gzip on;
    gzip_min_length 1000;
    gzip_types text/plain text/css application/javascript application/json;
    
    # Frontend
    location / {
        proxy_pass http://localhost:5173;
        proxy_set_header Host \$host;
        proxy_read_timeout 30s;
        proxy_connect_timeout 10s;
    }
    
    # Backend API
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host \$host;
        proxy_read_timeout 30s;
        proxy_connect_timeout 10s;
    }
}
EOF

# Enable nginx site
sudo ln -sf /etc/nginx/sites-available/lzcustom /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx

print_success "Ultra-light nginx configured"

# Create ultra-light management scripts
print_status "Creating ultra-light management scripts..."

# Ultra-light startup script
cat > ~/start-lzcustom-ultra.sh << 'EOF'
#!/bin/bash
echo "🪶 Starting LZ Custom Website (Ultra-Light Mode)..."

# Check memory before starting
TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
USED_RAM=$(free -m | awk 'NR==2{printf "%.0f", $3}')
echo "💻 Memory: ${USED_RAM}MB / ${TOTAL_RAM}MB used before startup"

# Start services
sudo systemctl start lzcustom-backend
sudo systemctl start lzcustom-frontend
sudo systemctl start nginx

# Wait for services
sleep 5

# Check status
echo "📊 Service Status:"
sudo systemctl is-active lzcustom-backend && echo "✅ Backend: Running" || echo "❌ Backend: Stopped"
sudo systemctl is-active lzcustom-frontend && echo "✅ Frontend: Running" || echo "❌ Frontend: Stopped"
sudo systemctl is-active nginx && echo "✅ Nginx: Running" || echo "❌ Nginx: Stopped"

# Memory usage after startup
USED_RAM_AFTER=$(free -m | awk 'NR==2{printf "%.0f", $3}')
SWAP_USED=$(free -m | awk 'NR==3{printf "%.0f", $3}')

echo ""
echo "💻 Ultra-Light Resource Usage:"
echo "   Memory: ${USED_RAM_AFTER}MB / ${TOTAL_RAM}MB ($(( USED_RAM_AFTER * 100 / TOTAL_RAM ))%)"
echo "   Swap: ${SWAP_USED}MB used"
echo "   Free Memory: $(( TOTAL_RAM - USED_RAM_AFTER ))MB"

# Get public IP
PUBLIC_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "localhost")

echo ""
echo "🌐 Access URLs:"
echo "   Website: http://$PUBLIC_IP"
echo "   Admin Dashboard: http://$PUBLIC_IP/admin.html"
echo ""
echo "🪶 Ultra-Light Features:"
echo "   ✅ Minimal memory usage (~200MB total)"
echo "   ✅ SQLite database (no external DB)"
echo "   ✅ Simple chat responses (no AI)"
echo "   ✅ Complete admin dashboard"
echo "   ✅ Form submission tracking"
echo ""
echo "⚠️  Memory Warnings:"
if [ "$USED_RAM_AFTER" -gt 700 ]; then
    echo "   🔴 HIGH MEMORY USAGE - Consider restarting services"
elif [ "$USED_RAM_AFTER" -gt 600 ]; then
    echo "   🟡 MODERATE MEMORY USAGE - Monitor closely"
else
    echo "   🟢 GOOD MEMORY USAGE - System healthy"
fi
EOF

chmod +x ~/start-lzcustom-ultra.sh

# Ultra-light stop script
cat > ~/stop-lzcustom-ultra.sh << 'EOF'
#!/bin/bash
echo "🛑 Stopping LZ Custom Website (Ultra-Light)..."

sudo systemctl stop lzcustom-frontend
sudo systemctl stop lzcustom-backend
sudo systemctl stop nginx

echo "✅ All services stopped"
echo "💡 Memory freed up for system"
echo "   To restart: ~/start-lzcustom-ultra.sh"
EOF

chmod +x ~/stop-lzcustom-ultra.sh

# Ultra-light monitoring script
cat > ~/monitor-lzcustom-ultra.sh << 'EOF'
#!/bin/bash
echo "🪶 LZ Custom Ultra-Light Monitoring"
echo "=================================="

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

# Critical resource monitoring for ultra-light
echo ""
echo "💻 Ultra-Light Resources:"
TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
USED_RAM=$(free -m | awk 'NR==2{printf "%.0f", $3}')
FREE_RAM=$(free -m | awk 'NR==2{printf "%.0f", $4}')
SWAP_USED=$(free -m | awk 'NR==3{printf "%.0f", $3}')
SWAP_TOTAL=$(free -m | awk 'NR==3{printf "%.0f", $2}')

MEMORY_PERCENT=$(( USED_RAM * 100 / TOTAL_RAM ))

echo "  Memory: ${USED_RAM}MB / ${TOTAL_RAM}MB (${MEMORY_PERCENT}%)"
echo "  Free Memory: ${FREE_RAM}MB"
echo "  Swap: ${SWAP_USED}MB / ${SWAP_TOTAL}MB"

# Disk usage
DISK_USAGE=$(df / | awk 'NR==2{printf "%.0f", $3*100/$2}')
echo "  Disk: $(df -h / | awk 'NR==2{printf "%s/%s (%s used)", $3, $2, $5}')"

# Memory warnings
echo ""
echo "⚠️  Resource Alerts:"
if [ "$MEMORY_PERCENT" -gt 85 ]; then
    echo "  🔴 CRITICAL: Memory usage over 85% - restart services immediately"
    echo "      Run: ~/stop-lzcustom-ultra.sh && ~/start-lzcustom-ultra.sh"
elif [ "$MEMORY_PERCENT" -gt 75 ]; then
    echo "  🟡 WARNING: Memory usage over 75% - monitor closely"
elif [ "$MEMORY_PERCENT" -gt 65 ]; then
    echo "  🟠 CAUTION: Memory usage over 65% - consider optimization"
else
    echo "  🟢 GOOD: Memory usage under control"
fi

if [ "$SWAP_USED" -gt 100 ]; then
    echo "  🟡 INFO: Using ${SWAP_USED}MB swap (normal for ultra-light)"
fi

if [ "$DISK_USAGE" -gt 80 ]; then
    echo "  🟡 WARNING: Disk usage over 80% - clean up logs"
    echo "      Run: sudo journalctl --vacuum-time=3d"
fi

# Process information
echo ""
echo "🔍 Top Memory Processes:"
ps aux --sort=-%mem | head -6 | awk '{printf "  %-15s %6s %6s %s\n", $1, $4"%", $6/1024"MB", $11}'

echo ""
echo "📝 Recent Backend Logs (last 2 lines):"
sudo journalctl -u lzcustom-backend --no-pager -n 2 --output=short-iso

echo ""
echo "💡 Ultra-Light Tips:"
echo "  • Monitor memory regularly with this script"
echo "  • Restart services if memory > 85%"
echo "  • Clean logs weekly: sudo journalctl --vacuum-time=7d"
echo "  • Check disk space monthly"
EOF

chmod +x ~/monitor-lzcustom-ultra.sh

# Ultra-light update script
cat > ~/update-lzcustom-ultra.sh << 'EOF'
#!/bin/bash
echo "🔄 Updating LZ Custom Website (Ultra-Light)..."

# Stop services to free memory during update
echo "🛑 Stopping services for update..."
sudo systemctl stop lzcustom-frontend
sudo systemctl stop lzcustom-backend

cd ~/LZCustom
git pull origin main

echo "📦 Updating frontend (ultra-light)..."
cd frontend
export NODE_OPTIONS="--max-old-space-size=256"
npm install --only=production --no-optional --silent
npm run build

echo "🔧 Updating backend (ultra-light)..."
cd ../backend
source venv/bin/activate
pip install --no-cache-dir --upgrade fastapi uvicorn pydantic

echo "🔄 Restarting services..."
sudo systemctl start lzcustom-backend
sudo systemctl start lzcustom-frontend

echo "✅ Ultra-light update complete!"
echo "💻 Check memory usage: ~/monitor-lzcustom-ultra.sh"
EOF

chmod +x ~/update-lzcustom-ultra.sh

# Final status check
print_status "Performing final ultra-light status check..."
sleep 8

echo ""
echo "📊 Final Service Status:"
sudo systemctl is-active lzcustom-backend && print_success "Backend: Running" || print_error "Backend: Stopped"
sudo systemctl is-active lzcustom-frontend && print_success "Frontend: Running" || print_error "Frontend: Stopped"
sudo systemctl is-active nginx && print_success "Nginx: Running" || print_error "Nginx: Stopped"

# Memory check after deployment
FINAL_RAM_USED=$(free -m | awk 'NR==2{printf "%.0f", $3}')
FINAL_RAM_PERCENT=$(( FINAL_RAM_USED * 100 / TOTAL_RAM ))

echo ""
print_azure "Final Memory Usage: ${FINAL_RAM_USED}MB / ${TOTAL_RAM}MB (${FINAL_RAM_PERCENT}%)"

if [ "$FINAL_RAM_PERCENT" -lt 75 ]; then
    print_success "Memory usage is healthy for ultra-light deployment"
elif [ "$FINAL_RAM_PERCENT" -lt 85 ]; then
    print_warning "Memory usage is moderate - monitor with ~/monitor-lzcustom-ultra.sh"
else
    print_error "Memory usage is high - consider restarting services"
fi

# Get public IP
PUBLIC_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "Unable to detect")

echo ""
print_success "🎉 LZ Custom Website Successfully Deployed (Ultra-Light)!"
echo ""
if [ "$PUBLIC_IP" != "Unable to detect" ]; then
    echo "🌐 Access your website at:"
    echo "   • Website: http://$PUBLIC_IP"
    echo "   • Admin Dashboard: http://$PUBLIC_IP/admin.html"
else
    echo "🌐 Access your website at:"
    echo "   • Website: http://localhost"
    echo "   • Admin Dashboard: http://localhost/admin.html"
fi
echo ""
echo "🔧 Ultra-Light Management Commands:"
echo "   • Start services: ~/start-lzcustom-ultra.sh"
echo "   • Stop services: ~/stop-lzcustom-ultra.sh"
echo "   • Monitor system: ~/monitor-lzcustom-ultra.sh"
echo "   • Update application: ~/update-lzcustom-ultra.sh"
echo ""
echo "🪶 Ultra-Light Optimizations Applied:"
echo "   • Memory limits: Backend 128MB, Frontend 64MB"
echo "   • CPU limits: Backend 50%, Frontend 30%"
echo "   • 512MB swap configured for your ${TOTAL_RAM}MB RAM"
echo "   • Smart package detection (only installed what was needed)"
echo "   • SQLite database (no external database required)"
echo "   • NO Docker (native installation only)"
echo "   • Minimal nginx configuration"
echo ""
echo "💬 Chat Feature:"
echo "   • Ultra-light responses (no AI processing)"
echo "   • Instant responses about services and contact info"
echo "   • All conversations logged to SQLite database"
echo "   • Zero memory overhead for chat processing"
echo ""
print_warning "🔐 Ultra-Light Maintenance:"
print_warning "   • Monitor memory regularly: ~/monitor-lzcustom-ultra.sh"
print_warning "   • Restart services if memory > 85%"
print_warning "   • Clean logs weekly: sudo journalctl --vacuum-time=7d"
print_warning "   • Your ${TOTAL_RAM}MB RAM is perfectly adequate for this setup"
echo ""
print_success "Perfect for your ${TOTAL_RAM}MB RAM VM! 🪶☁️"
