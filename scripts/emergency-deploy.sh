#!/bin/bash

# LZ Custom - Emergency Deployment (Python Only - NO Node.js)
# For when Node.js installation fails - uses Python for everything

set -e

echo "🚨 LZ Custom - Emergency Deployment (Python Only)"
echo "================================================"
echo ""
echo "This emergency deployment uses only Python and avoids Node.js issues:"
echo "  ✅ Python-only backend (FastAPI + SQLite)"
echo "  ✅ Python HTTP server for frontend (no npm needed)"
echo "  ✅ Simple HTML/CSS/JS (no build process)"
echo "  ✅ Works with 850MB+ RAM"
echo "  ✅ Complete admin dashboard"
echo "  ✅ NO Node.js dependencies"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check system requirements
TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
if [ "$TOTAL_RAM" -lt 850 ]; then
    print_error "RAM is ${TOTAL_RAM}MB. Need at least 850MB."
    exit 1
fi

print_success "RAM: ${TOTAL_RAM}MB (sufficient for emergency deployment)"

# Check for Python3
if ! command -v python3 &> /dev/null; then
    print_status "Installing Python3..."
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -y python3 python3-pip python3-venv
fi

# Check for git
if ! command -v git &> /dev/null; then
    print_status "Installing Git..."
    sudo DEBIAN_FRONTEND=noninteractive apt install -y git
fi

# Configure minimal swap
if [ ! -f /swapfile ]; then
    print_status "Configuring 512MB swap..."
    sudo fallocate -l 512M /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# Clone repository
if [ ! -d "LZCustom" ]; then
    print_status "Cloning repository..."
    git clone --depth 1 https://github.com/george-shepov/LZCustom.git
    cd LZCustom
else
    print_status "Updating repository..."
    cd LZCustom
    git pull origin main
fi

# Setup backend (Python only)
print_status "Setting up Python backend..."
cd backend
python3 -m venv venv
source venv/bin/activate

# Install minimal Python packages
pip install --no-cache-dir fastapi==0.104.1 uvicorn==0.24.0 pydantic==2.5.0

# Create emergency chat system
cat > emergency_chat.py << 'EOF'
# Emergency chat system - no external dependencies
import random

RESPONSES = {
    "greeting": [
        "Hello! Welcome to LZ Custom. How can we help with your fabrication project?",
        "Hi! We specialize in custom cabinets, countertops, and stone work. What can we do for you?"
    ],
    "services": [
        "We offer custom cabinets, granite/quartz countertops, stone fabrication, and commercial painting.",
        "Our services include kitchen cabinets, bathroom vanities, countertops, and tile work."
    ],
    "contact": [
        "Call us at 216-268-2990. We serve Northeast Ohio within 30 miles.",
        "Phone: 216-268-2990. Hours: Mon-Fri 8AM-5PM, Sat 9AM-3PM."
    ],
    "default": [
        "Great question! Call 216-268-2990 for detailed project information.",
        "For specific details, please call 216-268-2990 or fill out our quote form."
    ]
}

def get_response(message):
    msg = message.lower()
    if any(w in msg for w in ['hello', 'hi', 'hey']):
        return random.choice(RESPONSES["greeting"])
    elif any(w in msg for w in ['service', 'cabinet', 'counter']):
        return random.choice(RESPONSES["services"])
    elif any(w in msg for w in ['contact', 'phone', 'call']):
        return random.choice(RESPONSES["contact"])
    else:
        return random.choice(RESPONSES["default"])
EOF

# Add emergency chat to main.py
if [ -f main.py ]; then
    cp main.py main.py.backup
fi

cat >> main.py << 'EOF'

# Emergency chat endpoint
import sys
import os
sys.path.append(os.path.dirname(__file__))

try:
    from emergency_chat import get_response
except ImportError:
    def get_response(message):
        return "Thanks for your message! Please call us at 216-268-2990."

@app.post("/api/chat")
async def emergency_chat(message: ChatMessage):
    try:
        response_text = get_response(message.message)
        
        # Log to SQLite
        try:
            conn = sqlite3.connect('lz_custom.db')
            cursor = conn.cursor()
            cursor.execute('''
                INSERT INTO chat_conversations (user_message, ai_response, model_used, response_time)
                VALUES (?, ?, ?, ?)
            ''', (message.message, response_text, "emergency", 0.01))
            conn.commit()
            conn.close()
        except:
            pass
        
        return {
            "response": response_text,
            "model": "emergency",
            "response_time": 0.01
        }
    except Exception as e:
        return {
            "response": "Thanks for contacting us! Please call 216-268-2990.",
            "model": "fallback",
            "response_time": 0.01
        }
EOF

print_success "Emergency backend configured"

# Create systemd service for backend
print_status "Creating backend service..."
sudo tee /etc/systemd/system/lzcustom-backend.service > /dev/null <<EOF
[Unit]
Description=LZ Custom Backend (Emergency)
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$(pwd)
Environment=PATH=$(pwd)/venv/bin
ExecStart=$(pwd)/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1
Restart=always
RestartSec=10
MemoryLimit=128M

[Install]
WantedBy=multi-user.target
EOF

# Create Python frontend service (no Node.js needed)
print_status "Creating Python frontend service..."
sudo tee /etc/systemd/system/lzcustom-frontend.service > /dev/null <<EOF
[Unit]
Description=LZ Custom Frontend (Emergency Python)
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$(pwd)/../frontend
ExecStart=/usr/bin/python3 -m http.server 5173
Restart=always
RestartSec=10
MemoryLimit=32M

[Install]
WantedBy=multi-user.target
EOF

# Install and configure nginx
if ! command -v nginx &> /dev/null; then
    print_status "Installing nginx..."
    sudo DEBIAN_FRONTEND=noninteractive apt install -y nginx-light
fi

# Configure nginx
sudo tee /etc/nginx/sites-available/lzcustom > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    
    # Frontend (Python HTTP server)
    location / {
        proxy_pass http://localhost:5173;
        proxy_set_header Host \$host;
    }
    
    # Backend API
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host \$host;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/lzcustom /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Configure firewall
if ! sudo ufw status | grep -q "Status: active"; then
    sudo ufw --force enable
    sudo ufw allow ssh
    sudo ufw allow 80/tcp
fi

# Start services
print_status "Starting services..."
sudo systemctl daemon-reload
sudo systemctl enable lzcustom-backend lzcustom-frontend nginx
sudo systemctl start lzcustom-backend lzcustom-frontend nginx

# Create management scripts
cat > ~/start-lzcustom-emergency.sh << 'EOF'
#!/bin/bash
echo "🚨 Starting LZ Custom (Emergency Mode - Python Only)..."
sudo systemctl start lzcustom-backend lzcustom-frontend nginx
sleep 3
echo "📊 Service Status:"
sudo systemctl is-active lzcustom-backend && echo "✅ Backend: Running" || echo "❌ Backend: Stopped"
sudo systemctl is-active lzcustom-frontend && echo "✅ Frontend: Running" || echo "❌ Frontend: Stopped"
sudo systemctl is-active nginx && echo "✅ Nginx: Running" || echo "❌ Nginx: Stopped"
echo ""
echo "🌐 Access: http://$(curl -s ifconfig.me 2>/dev/null || echo localhost)"
echo "👨‍💼 Admin: http://$(curl -s ifconfig.me 2>/dev/null || echo localhost)/admin.html"
EOF

chmod +x ~/start-lzcustom-emergency.sh

# Final check
sleep 5
print_status "Checking services..."

if sudo systemctl is-active --quiet lzcustom-backend && sudo systemctl is-active --quiet lzcustom-frontend; then
    PUBLIC_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "localhost")
    
    echo ""
    print_success "🎉 EMERGENCY DEPLOYMENT SUCCESSFUL!"
    echo ""
    echo "🌐 Access URLs:"
    echo "   • Website: http://$PUBLIC_IP"
    echo "   • Admin Dashboard: http://$PUBLIC_IP/admin.html"
    echo ""
    echo "🚨 Emergency Features:"
    echo "   • Python-only backend (no Node.js issues)"
    echo "   • Python HTTP server for frontend"
    echo "   • Simple chat responses"
    echo "   • Complete admin dashboard"
    echo "   • SQLite database"
    echo "   • Memory usage: ~300MB total"
    echo ""
    echo "🔧 Management:"
    echo "   • Start: ~/start-lzcustom-emergency.sh"
    echo "   • Logs: sudo journalctl -u lzcustom-backend -f"
    echo ""
    print_success "Emergency deployment complete! 🚨☁️"
else
    print_error "Some services failed to start. Check logs:"
    echo "sudo journalctl -u lzcustom-backend -f"
fi
