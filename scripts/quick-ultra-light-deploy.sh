#!/bin/bash

# LZ Custom - Quick Ultra-Light Deployment (850MB+ RAM)
# One-command deployment for very low-resource VMs

set -e

echo "🪶 LZ Custom - Ultra-Light Deployment (850MB+ RAM)"
echo "================================================="
echo ""
echo "This deployment works with your 898MB RAM VM:"
echo "  ✅ Smart package detection (only installs what's needed)"
echo "  ✅ NO AI models (saves 10GB+ storage and RAM)"
echo "  ✅ SQLite database (no external database)"
echo "  ✅ NO Docker (native installation only)"
echo "  ✅ Memory limits: Backend 128MB, Frontend 64MB"
echo "  ✅ 512MB swap configured automatically"
echo "  ✅ Complete admin dashboard and lead tracking"
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

print_ultra() {
    echo -e "${PURPLE}[ULTRA-LIGHT]${NC} $1"
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

# Ultra-light system requirements check
print_status "Checking your system (898MB RAM detected)..."

# Check RAM - adjusted for your specific case
TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
if [ "$TOTAL_RAM" -lt 850 ]; then
    print_error "RAM is ${TOTAL_RAM}MB. This ultra-light deployment needs at least 850MB."
    print_error "Your VM might be too small for any web deployment."
    exit 1
else
    print_ultra "RAM: ${TOTAL_RAM}MB (perfect for ultra-light deployment!)"
fi

# Check disk space
AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')
REQUIRED_SPACE=3000000  # 3GB in KB
if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    print_error "Insufficient disk space. Available: $(($AVAILABLE_SPACE/1024/1024))GB, Required: 3GB+"
    exit 1
else
    print_ultra "Disk space: $(($AVAILABLE_SPACE/1024/1024))GB (sufficient for ultra-light)"
fi

# Check internet connectivity
print_status "Checking internet connectivity..."
if ! curl -s --connect-timeout 5 https://github.com > /dev/null; then
    print_error "No internet connection. Please check your network settings."
    exit 1
fi
print_success "Internet connectivity: OK"

# Show what packages are already installed
print_status "Detecting already installed packages to minimize installation..."

ALREADY_INSTALLED=""
NEED_TO_INSTALL=""

if command -v node &> /dev/null; then
    ALREADY_INSTALLED="$ALREADY_INSTALLED Node.js($(node --version))"
else
    NEED_TO_INSTALL="$NEED_TO_INSTALL Node.js"
fi

if command -v python3 &> /dev/null; then
    ALREADY_INSTALLED="$ALREADY_INSTALLED Python3($(python3 --version | cut -d' ' -f2))"
else
    NEED_TO_INSTALL="$NEED_TO_INSTALL Python3"
fi

if command -v nginx &> /dev/null; then
    ALREADY_INSTALLED="$ALREADY_INSTALLED Nginx"
else
    NEED_TO_INSTALL="$NEED_TO_INSTALL Nginx"
fi

if command -v git &> /dev/null; then
    ALREADY_INSTALLED="$ALREADY_INSTALLED Git"
else
    NEED_TO_INSTALL="$NEED_TO_INSTALL Git"
fi

if [ -n "$ALREADY_INSTALLED" ]; then
    print_success "Already installed:$ALREADY_INSTALLED"
fi

if [ -n "$NEED_TO_INSTALL" ]; then
    print_warning "Will install:$NEED_TO_INSTALL"
fi

# Confirm deployment
echo ""
print_warning "⚠️  ULTRA-LIGHT DEPLOYMENT CONFIRMATION"
echo "This will install and configure:"
echo "  • Only missing packages (smart detection applied)"
echo "  • LZ Custom website with admin dashboard"
echo "  • Simple chat responses (NO AI models)"
echo "  • SQLite database (no external database)"
echo "  • Memory-optimized services for ${TOTAL_RAM}MB RAM"
echo "  • 512MB swap file for stability"
echo ""
echo "Estimated time: 8-12 minutes"
echo "Estimated download: ~200-500MB (depending on what's already installed)"
echo "Memory usage after deployment: ~400-500MB (leaves ${TOTAL_RAM}MB - 500MB = $((TOTAL_RAM - 500))MB+ free)"
echo ""
echo "Continue with ULTRA-LIGHT deployment for your ${TOTAL_RAM}MB RAM VM? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Start deployment
echo ""
print_ultra "🚀 Starting ultra-light deployment for ${TOTAL_RAM}MB RAM VM..."

# Download and execute the ultra-light provisioning script
print_status "Downloading ultra-light provisioning script..."
curl -fsSL https://raw.githubusercontent.com/george-shepov/LZCustom/main/scripts/azure-ultra-light-deploy.sh -o /tmp/azure-ultra-light-deploy.sh

if [ ! -f /tmp/azure-ultra-light-deploy.sh ]; then
    print_error "Failed to download provisioning script"
    exit 1
fi

chmod +x /tmp/azure-ultra-light-deploy.sh

print_status "Executing ultra-light provisioning script..."
/tmp/azure-ultra-light-deploy.sh

# Cleanup
rm -f /tmp/azure-ultra-light-deploy.sh

# Final verification
print_status "Performing final verification..."
sleep 5

# Check if services are running
SERVICES=("lzcustom-backend" "lzcustom-frontend" "nginx")
ALL_RUNNING=true

for service in "${SERVICES[@]}"; do
    if sudo systemctl is-active --quiet "$service"; then
        print_success "$service: Running"
    else
        print_error "$service: Not running"
        ALL_RUNNING=false
    fi
done

# Final memory check
FINAL_RAM_USED=$(free -m | awk 'NR==2{printf "%.0f", $3}')
FINAL_RAM_FREE=$(free -m | awk 'NR==2{printf "%.0f", $4}')
FINAL_RAM_PERCENT=$(( FINAL_RAM_USED * 100 / TOTAL_RAM ))

if [ "$ALL_RUNNING" = true ]; then
    echo ""
    print_success "🎉 ULTRA-LIGHT DEPLOYMENT SUCCESSFUL!"
    echo ""
    
    # Get public IP
    PUBLIC_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "localhost")
    
    echo "🌐 Your LZ Custom website is now live (Ultra-Light Mode)!"
    echo ""
    echo "📱 Access URLs:"
    if [ "$PUBLIC_IP" != "localhost" ]; then
        echo "   • Main Website: http://$PUBLIC_IP"
        echo "   • Admin Dashboard: http://$PUBLIC_IP/admin.html"
    else
        echo "   • Main Website: http://localhost"
        echo "   • Admin Dashboard: http://localhost/admin.html"
    fi
    echo ""
    echo "💻 Memory Usage After Deployment:"
    echo "   • Used: ${FINAL_RAM_USED}MB / ${TOTAL_RAM}MB (${FINAL_RAM_PERCENT}%)"
    echo "   • Free: ${FINAL_RAM_FREE}MB"
    echo "   • Swap: $(free -m | awk 'NR==3{printf "%.0f", $3}')MB used"
    
    if [ "$FINAL_RAM_PERCENT" -lt 70 ]; then
        echo "   🟢 EXCELLENT: Memory usage is very healthy"
    elif [ "$FINAL_RAM_PERCENT" -lt 80 ]; then
        echo "   🟡 GOOD: Memory usage is acceptable"
    else
        echo "   🟠 CAUTION: Memory usage is high - monitor regularly"
    fi
    
    echo ""
    echo "🔧 Ultra-Light Management Commands:"
    echo "   • Start services: ~/start-lzcustom-ultra.sh"
    echo "   • Stop services: ~/stop-lzcustom-ultra.sh"
    echo "   • Monitor system: ~/monitor-lzcustom-ultra.sh"
    echo "   • Update application: ~/update-lzcustom-ultra.sh"
    echo ""
    echo "🪶 Ultra-Light Features:"
    echo "   • Complete admin dashboard with lead management"
    echo "   • Form submissions with zero prospect loss"
    echo "   • Simple chat responses (no AI processing)"
    echo "   • SQLite database (no external database needed)"
    echo "   • Memory-optimized for your ${TOTAL_RAM}MB RAM"
    echo "   • Smart package detection (minimal installation)"
    echo ""
    echo "💬 Chat Feature (NO AI):"
    echo "   • Instant responses about services and contact info"
    echo "   • Directs users to call 216-268-2990 for details"
    echo "   • All conversations logged for lead tracking"
    echo "   • Zero memory overhead for chat processing"
    echo ""
    echo "📊 Resource Optimizations Applied:"
    echo "   • Backend: 128MB memory limit, 50% CPU limit"
    echo "   • Frontend: 64MB memory limit, 30% CPU limit"
    echo "   • 512MB swap configured for stability"
    echo "   • Nginx: Ultra-light configuration"
    echo "   • Only essential packages installed"
    echo ""
    echo "💡 Next Steps:"
    echo "   1. Access the admin dashboard to manage leads"
    echo "   2. Test the contact form to see lead tracking"
    echo "   3. Try the simple chat responses"
    echo "   4. Monitor memory usage: ~/monitor-lzcustom-ultra.sh"
    echo ""
    print_success "Perfect for your ${TOTAL_RAM}MB RAM VM! 🪶☁️"
    
else
    echo ""
    print_error "❌ DEPLOYMENT ISSUES DETECTED"
    echo ""
    echo "Some services are not running properly. For your ${TOTAL_RAM}MB RAM VM:"
    echo "   • Check memory usage: free -h"
    echo "   • Check service logs: sudo journalctl -u SERVICE_NAME -f"
    echo "   • Try restarting: ~/stop-lzcustom-ultra.sh && ~/start-lzcustom-ultra.sh"
    echo ""
    echo "Your ${TOTAL_RAM}MB RAM is at the minimum for web deployment."
    echo "Consider upgrading to 1GB+ RAM if issues persist."
    exit 1
fi
