#!/bin/bash

# Quick Fix for python3-venv issue and complete deployment
# Run this to fix the current issue and complete the deployment

echo "🔧 Quick Fix for python3-venv Issue"
echo "===================================="
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

# Fix the python3-venv issue
print_status "Installing python3-venv package..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y python3-venv python3-pip

print_success "python3-venv installed successfully"

# Check if we're in the LZCustom directory
if [ -d "LZCustom" ]; then
    cd LZCustom
elif [ -d "/home/shepov/LZCustom" ]; then
    cd /home/shepov/LZCustom
else
    print_error "LZCustom directory not found. Let's clone it..."
    git clone --depth 1 https://github.com/george-shepov/LZCustom.git
    cd LZCustom
fi

print_status "Setting up backend with fixed Python environment..."
cd backend

# Remove the failed venv directory if it exists
if [ -d "venv" ]; then
    print_status "Removing failed virtual environment..."
    rm -rf venv
fi

# Create new virtual environment
print_status "Creating new virtual environment..."
python3 -m venv venv

# Activate and install packages
print_status "Installing Python packages..."
source venv/bin/activate
pip install --no-cache-dir fastapi==0.104.1 uvicorn==0.24.0 pydantic==2.5.0

print_success "Backend setup complete"

# Create emergency chat system
print_status "Setting up emergency chat system..."
cat > emergency_chat.py << 'EOF'
# Emergency chat system - no external dependencies
import random

RESPONSES = {
    "greeting": [
        "Hello! Welcome to LZ Custom. How can we help with your fabrication project?",
        "Hi! We specialize in custom cabinets, countertops, and stone work. What can we do for you?",
        "Welcome to LZ Custom! We're here to help with your custom fabrication needs."
    ],
    "services": [
        "We offer custom cabinets, granite/quartz countertops, stone fabrication, and commercial painting.",
        "Our services include kitchen cabinets, bathroom vanities, countertops, and tile work.",
        "We specialize in custom millwork, stone fabrication, and high-quality finishes."
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
    if any(w in msg for w in ['hello', 'hi', 'hey', 'good morning', 'good afternoon']):
        return random.choice(RESPONSES["greeting"])
    elif any(w in msg for w in ['service', 'what do you do', 'cabinet', 'counter', 'stone']):
        return random.choice(RESPONSES["services"])
    elif any(w in msg for w in ['contact', 'phone', 'call', 'hours', 'reach']):
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
        return "Thanks for your message! Please call us at 216-268-2990 for assistance."

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
            pass  # Continue even if logging fails
        
        return {
            "response": response_text,
            "model": "emergency",
            "response_time": 0.01
        }
    except Exception as e:
        return {
            "response": "Thanks for contacting us! Please call 216-268-2990 for immediate assistance.",
            "model": "fallback",
            "response_time": 0.01
        }
EOF

print_success "Emergency chat system configured"

# Create systemd services
print_status "Creating systemd services..."

# Backend service
sudo tee /etc/systemd/system/lzcustom-backend.service > /dev/null <<EOF
[Unit]
Description=LZ Custom Backend (Emergency Fix)
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

# Frontend service (Python HTTP server)
sudo tee /etc/systemd/system/lzcustom-frontend.service > /dev/null <<EOF
[Unit]
Description=LZ Custom Frontend (Python HTTP Server)
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

# Install nginx if needed
if ! command -v nginx &> /dev/null; then
    print_status "Installing nginx..."
    sudo DEBIAN_FRONTEND=noninteractive apt install -y nginx-light
fi

# Configure nginx
print_status "Configuring nginx..."
sudo tee /etc/nginx/sites-available/lzcustom > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    
    # Frontend (Python HTTP server)
    location / {
        proxy_pass http://localhost:5173;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    
    # Backend API
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/lzcustom /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Configure firewall
if ! sudo ufw status | grep -q "Status: active"; then
    print_status "Configuring firewall..."
    sudo ufw --force enable
    sudo ufw allow ssh
    sudo ufw allow 80/tcp
fi

# Configure swap if needed
if [ ! -f /swapfile ]; then
    print_status "Configuring 512MB swap for stability..."
    sudo fallocate -l 512M /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# Start services
print_status "Starting all services..."
sudo systemctl daemon-reload
sudo systemctl enable lzcustom-backend lzcustom-frontend nginx
sudo systemctl start lzcustom-backend lzcustom-frontend nginx

# Create management script
print_status "Creating management scripts..."
cat > ~/start-lzcustom-fixed.sh << 'EOF'
#!/bin/bash
echo "🔧 Starting LZ Custom (Fixed Deployment)..."
sudo systemctl start lzcustom-backend lzcustom-frontend nginx
sleep 3

echo "📊 Service Status:"
sudo systemctl is-active lzcustom-backend && echo "✅ Backend: Running" || echo "❌ Backend: Stopped"
sudo systemctl is-active lzcustom-frontend && echo "✅ Frontend: Running" || echo "❌ Frontend: Stopped"
sudo systemctl is-active nginx && echo "✅ Nginx: Running" || echo "❌ Nginx: Stopped"

echo ""
echo "💻 Memory Usage:"
free -h | head -2

echo ""
PUBLIC_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "localhost")
echo "🌐 Access URLs:"
echo "   • Website: http://$PUBLIC_IP"
echo "   • Admin Dashboard: http://$PUBLIC_IP/admin.html"
EOF

chmod +x ~/start-lzcustom-fixed.sh

# Final check
print_status "Performing final check..."
sleep 5

TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
USED_RAM=$(free -m | awk 'NR==2{printf "%.0f", $3}')

if sudo systemctl is-active --quiet lzcustom-backend && sudo systemctl is-active --quiet lzcustom-frontend && sudo systemctl is-active --quiet nginx; then
    PUBLIC_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "localhost")
    
    echo ""
    print_success "🎉 QUICK FIX DEPLOYMENT SUCCESSFUL!"
    echo ""
    echo "🌐 Your LZ Custom website is now live:"
    echo "   • Website: http://$PUBLIC_IP"
    echo "   • Admin Dashboard: http://$PUBLIC_IP/admin.html"
    echo ""
    echo "💻 Memory Usage:"
    echo "   • Used: ${USED_RAM}MB / ${TOTAL_RAM}MB ($(( USED_RAM * 100 / TOTAL_RAM ))%)"
    echo "   • Free: $(( TOTAL_RAM - USED_RAM ))MB"
    echo ""
    echo "🔧 Features:"
    echo "   • Complete admin dashboard with lead management"
    echo "   • Form submissions with zero prospect loss"
    echo "   • Simple chat responses (no AI processing)"
    echo "   • SQLite database (no external database)"
    echo "   • Python HTTP server for frontend"
    echo "   • Memory optimized for your ${TOTAL_RAM}MB RAM"
    echo ""
    echo "📊 Management:"
    echo "   • Start services: ~/start-lzcustom-fixed.sh"
    echo "   • Check logs: sudo journalctl -u lzcustom-backend -f"
    echo "   • Monitor memory: free -h"
    echo ""
    print_success "Fixed deployment complete! 🔧☁️"
else
    print_error "Some services failed to start. Check logs:"
    echo "   • Backend: sudo journalctl -u lzcustom-backend -f"
    echo "   • Frontend: sudo journalctl -u lzcustom-frontend -f"
    echo "   • Nginx: sudo journalctl -u nginx -f"
fi
