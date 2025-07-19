#!/bin/bash

# LZ Custom - Quick Azure Deployment Script
# One-command deployment for Azure Ubuntu VMs

set -e

echo "🚀 LZ Custom - Quick Azure Deployment"
echo "====================================="
echo ""
echo "This script will deploy the complete LZ Custom website with:"
echo "  ✅ Admin dashboard for lead management"
echo "  ✅ AI chat with multiple LLM models"
echo "  ✅ Form submission tracking (zero prospect loss)"
echo "  ✅ Professional responsive design"
echo "  ✅ Azure-optimized configuration"
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

# Check if running on Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    print_error "This script is designed for Ubuntu. Please use Ubuntu 20.04 LTS or 22.04 LTS."
    exit 1
fi

# Check for sudo privileges
if ! sudo -n true 2>/dev/null; then
    print_error "This script requires sudo privileges. Please run with a user that has sudo access."
    exit 1
fi

# System requirements check
print_status "Checking system requirements..."

# Check RAM
TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
if [ "$TOTAL_RAM" -lt 4096 ]; then
    print_warning "RAM is ${TOTAL_RAM}MB. Recommended: 8GB+ for optimal AI performance."
    echo "Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    print_success "RAM: ${TOTAL_RAM}MB (sufficient)"
fi

# Check disk space
AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')
REQUIRED_SPACE=20000000  # 20GB in KB
if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    print_error "Insufficient disk space. Available: $(($AVAILABLE_SPACE/1024/1024))GB, Required: 20GB+"
    exit 1
else
    print_success "Disk space: $(($AVAILABLE_SPACE/1024/1024))GB (sufficient)"
fi

# Check internet connectivity
print_status "Checking internet connectivity..."
if ! curl -s --connect-timeout 5 https://github.com > /dev/null; then
    print_error "No internet connection. Please check your network settings."
    exit 1
fi
print_success "Internet connectivity: OK"

# Confirm deployment
echo ""
print_warning "⚠️  DEPLOYMENT CONFIRMATION"
echo "This will install and configure:"
echo "  • Node.js, Python, and system dependencies"
echo "  • Ollama AI platform with 3 language models (~10GB download)"
echo "  • LZ Custom website with admin dashboard"
echo "  • Nginx reverse proxy and security configurations"
echo ""
echo "Estimated time: 15-30 minutes (depending on internet speed)"
echo "Estimated download: ~12GB (AI models + dependencies)"
echo ""
echo "Continue with deployment? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Start deployment
echo ""
print_status "🚀 Starting deployment..."

# Download and execute the main provisioning script
print_status "Downloading Azure provisioning script..."
curl -fsSL https://raw.githubusercontent.com/george-shepov/LZCustom/main/scripts/azure-provision.sh -o /tmp/azure-provision.sh

if [ ! -f /tmp/azure-provision.sh ]; then
    print_error "Failed to download provisioning script"
    exit 1
fi

chmod +x /tmp/azure-provision.sh

print_status "Executing Azure provisioning script..."
/tmp/azure-provision.sh

# Cleanup
rm -f /tmp/azure-provision.sh

# Final verification
print_status "Performing final verification..."
sleep 5

# Check if services are running
SERVICES=("ollama" "lzcustom-backend" "lzcustom-frontend" "nginx")
ALL_RUNNING=true

for service in "${SERVICES[@]}"; do
    if sudo systemctl is-active --quiet "$service"; then
        print_success "$service: Running"
    else
        print_error "$service: Not running"
        ALL_RUNNING=false
    fi
done

if [ "$ALL_RUNNING" = true ]; then
    echo ""
    print_success "🎉 DEPLOYMENT SUCCESSFUL!"
    echo ""
    
    # Get public IP
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "localhost")
    
    echo "🌐 Your LZ Custom website is now live!"
    echo ""
    echo "📱 Access URLs:"
    if [ "$PUBLIC_IP" != "localhost" ]; then
        echo "   • Main Website: http://$PUBLIC_IP"
        echo "   • Admin Dashboard: http://$PUBLIC_IP/admin.html"
        echo "   • API Documentation: http://$PUBLIC_IP:8000/docs"
    else
        echo "   • Main Website: http://localhost"
        echo "   • Admin Dashboard: http://localhost/admin.html"
        echo "   • API Documentation: http://localhost:8000/docs"
    fi
    echo ""
    echo "🔧 Management Commands:"
    echo "   • Start services: ~/start-lzcustom.sh"
    echo "   • Stop services: ~/stop-lzcustom.sh"
    echo "   • Monitor system: ~/monitor-lzcustom.sh"
    echo "   • Update application: ~/update-lzcustom.sh"
    echo ""
    echo "📊 Admin Dashboard Features:"
    echo "   • Lead management with search and filtering"
    echo "   • AI model configuration and usage statistics"
    echo "   • Real-time analytics and chat monitoring"
    echo "   • Prospect tracking with notes and status updates"
    echo ""
    echo "🤖 AI Models Available:"
    echo "   • Fast Response (llama3.2:3b) - Simple questions"
    echo "   • Balanced (gemma3:4b) - Moderate complexity"
    echo "   • Technical Expert (qwen2.5:7b) - Technical questions"
    echo ""
    echo "💡 Next Steps:"
    echo "   1. Access the admin dashboard to configure AI models"
    echo "   2. Test the contact form to see lead tracking"
    echo "   3. Try the AI chat to verify model functionality"
    echo "   4. Configure SSL certificate for production use"
    echo ""
    print_success "Deployment completed successfully! 🏗️"
    
else
    echo ""
    print_error "❌ DEPLOYMENT ISSUES DETECTED"
    echo ""
    echo "Some services are not running properly. Please check:"
    echo "   • Service logs: sudo journalctl -u SERVICE_NAME -f"
    echo "   • System resources: htop"
    echo "   • Disk space: df -h"
    echo ""
    echo "For support, please check:"
    echo "   • GitHub Issues: https://github.com/george-shepov/LZCustom/issues"
    echo "   • Deployment logs above for specific errors"
    exit 1
fi
