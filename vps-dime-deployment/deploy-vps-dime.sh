#!/bin/bash

# LZ Custom - VPS Dime Deployment Script
# Complete deployment with AI capabilities

set -e

echo "🚀 LZ Custom - VPS Dime Deployment with AI"
echo "=========================================="
echo ""
echo "This deployment includes:"
echo "  ✅ Complete professional website"
echo "  ✅ Full admin dashboard with analytics"
echo "  ✅ Configurable AI chat (OpenAI, Claude, Ollama, or Simple)"
echo "  ✅ Advanced lead management system"
echo "  ✅ Production-ready with Nginx + Gunicorn"
echo "  ✅ SSL certificate setup"
echo "  ✅ Monitoring and logging"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
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

print_ai() {
    echo -e "${PURPLE}[AI]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

# System requirements check
print_status "Checking system requirements..."

TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')

print_status "System specs:"
echo "  • RAM: ${TOTAL_RAM}MB"
echo "  • Available disk: $(($AVAILABLE_SPACE/1024/1024))GB"
echo "  • OS: $(lsb_release -d | cut -f2)"

if [ "$TOTAL_RAM" -lt 1024 ]; then
    print_warning "RAM is ${TOTAL_RAM}MB. Recommended: 2GB+ for AI features, 1GB+ for simple mode."
fi

if [ "$AVAILABLE_SPACE" -lt 5000000 ]; then  # 5GB in KB
    print_error "Insufficient disk space. Available: $(($AVAILABLE_SPACE/1024/1024))GB, Required: 5GB+"
    exit 1
fi

# Check internet connectivity
print_status "Checking internet connectivity..."
if ! curl -s --connect-timeout 5 https://github.com > /dev/null; then
    print_error "No internet connection. Please check your network settings."
    exit 1
fi

# AI Configuration
echo ""
print_ai "🤖 AI Configuration"
echo "Choose your AI setup:"
echo "  1) Simple responses only (no external AI) - Recommended for testing"
echo "  2) OpenAI GPT integration (requires API key)"
echo "  3) Local Ollama AI (install Ollama locally)"
echo "  4) Claude AI integration (requires API key)"
echo "  5) Configure later (starts with simple responses)"
echo ""
read -p "Enter your choice (1-5): " ai_choice

case $ai_choice in
    1)
        AI_ENABLED="false"
        AI_MODEL="simple"
        print_ai "Simple responses selected - no external dependencies"
        ;;
    2)
        AI_ENABLED="true"
        AI_MODEL="openai"
        echo ""
        read -p "Enter your OpenAI API key: " OPENAI_API_KEY
        read -p "Enter OpenAI model (default: gpt-3.5-turbo): " OPENAI_MODEL
        OPENAI_MODEL=${OPENAI_MODEL:-gpt-3.5-turbo}
        print_ai "OpenAI integration configured"
        ;;
    3)
        AI_ENABLED="true"
        AI_MODEL="ollama"
        print_ai "Ollama integration selected - will install Ollama"
        INSTALL_OLLAMA=true
        ;;
    4)
        AI_ENABLED="true"
        AI_MODEL="claude"
        echo ""
        read -p "Enter your Claude API key: " CLAUDE_API_KEY
        print_ai "Claude integration configured"
        ;;
    *)
        AI_ENABLED="false"
        AI_MODEL="simple"
        print_ai "Simple responses selected (can be changed later)"
        ;;
esac

# Business Configuration
echo ""
print_status "📋 Business Information"
read -p "Business name (default: LZ Custom): " BUSINESS_NAME
BUSINESS_NAME=${BUSINESS_NAME:-"LZ Custom"}

read -p "Business phone (default: 216-268-2990): " BUSINESS_PHONE
BUSINESS_PHONE=${BUSINESS_PHONE:-"216-268-2990"}

read -p "Service area (default: Northeast Ohio within 30 miles): " SERVICE_AREA
SERVICE_AREA=${SERVICE_AREA:-"Northeast Ohio within 30 miles"}

read -p "Business hours (default: Mon-Fri 8AM-5PM, Sat 9AM-3PM): " BUSINESS_HOURS
BUSINESS_HOURS=${BUSINESS_HOURS:-"Mon-Fri 8AM-5PM, Sat 9AM-3PM"}

# Domain Configuration
echo ""
print_status "🌐 Domain Configuration"
read -p "Enter your domain name (e.g., lzcustom.com) or press Enter for IP access: " DOMAIN_NAME

if [ -n "$DOMAIN_NAME" ]; then
    print_status "Domain: $DOMAIN_NAME"
    SETUP_SSL=true
else
    print_status "Will use IP address access"
    SETUP_SSL=false
fi

# Confirmation
echo ""
print_warning "⚠️  DEPLOYMENT CONFIRMATION"
echo "Configuration:"
echo "  • Business: $BUSINESS_NAME"
echo "  • Phone: $BUSINESS_PHONE"
echo "  • AI Mode: $AI_MODEL"
echo "  • Domain: ${DOMAIN_NAME:-"IP address"}"
echo "  • SSL: ${SETUP_SSL}"
echo ""
echo "This will install and configure:"
echo "  • Nginx web server"
echo "  • Python 3.9+ with Flask"
echo "  • SQLite database"
echo "  • Gunicorn WSGI server"
echo "  • Systemd services"
if [ "$SETUP_SSL" = true ]; then
    echo "  • Let's Encrypt SSL certificate"
fi
if [ "$INSTALL_OLLAMA" = true ]; then
    echo "  • Ollama local AI server"
fi
echo ""
echo "Estimated time: 10-15 minutes"
echo "Continue with deployment? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Start deployment
echo ""
print_status "🚀 Starting VPS Dime deployment..."

# Update system
print_status "Updating system packages..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

# Install required packages
print_status "Installing required packages..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    nginx \
    git \
    curl \
    wget \
    unzip \
    certbot \
    python3-certbot-nginx \
    htop \
    ufw

# Install Ollama if selected
if [ "$INSTALL_OLLAMA" = true ]; then
    print_ai "Installing Ollama local AI..."
    curl -fsSL https://ollama.ai/install.sh | sh
    
    # Start Ollama service
    sudo systemctl enable ollama
    sudo systemctl start ollama
    
    # Pull default model
    print_ai "Downloading Ollama model (this may take a few minutes)..."
    ollama pull llama2
    
    print_success "Ollama installed and configured"
fi

# Configure firewall
print_status "Configuring firewall..."
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Clone repository
if [ ! -d "LZCustom" ]; then
    print_status "Cloning LZ Custom repository..."
    git clone --depth 1 https://github.com/george-shepov/LZCustom.git
    cd LZCustom/vps-dime-deployment
else
    print_status "Repository already exists, updating..."
    cd LZCustom
    git pull origin main
    cd vps-dime-deployment
fi

# Setup Python environment
print_status "Setting up Python environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python packages
print_status "Installing Python dependencies..."
pip install --upgrade pip

# Install based on AI choice
if [ "$AI_MODEL" = "simple" ]; then
    # Minimal installation
    pip install Flask Flask-CORS gunicorn gevent
else
    # Full installation with AI packages
    pip install -r requirements.txt
fi

print_success "Python environment configured"
