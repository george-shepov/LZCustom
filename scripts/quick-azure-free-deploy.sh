#!/bin/bash

# LZ Custom - Quick Azure Free Tier Deployment (NO AI)
# One-command deployment for Azure Free Tier VMs (B1s - 1GB RAM)

set -e

echo "🆓 LZ Custom - Azure Free Tier Deployment (NO AI)"
echo "=================================================="
echo ""
echo "This deployment is optimized for Azure Free Tier VMs:"
echo "  ✅ NO AI models (saves 10GB+ storage and RAM)"
echo "  ✅ Admin dashboard for complete lead management"
echo "  ✅ Form submission tracking (zero prospect loss)"
echo "  ✅ Simple chat responses (no AI processing)"
echo "  ✅ Professional responsive website"
echo "  ✅ Memory-optimized for 1GB RAM VMs"
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

print_azure() {
    echo -e "${PURPLE}[AZURE FREE]${NC} $1"
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

# Free tier system requirements check
print_status "Checking Azure Free Tier requirements..."

# Check RAM (should be around 1GB for B1s)
TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
if [ "$TOTAL_RAM" -lt 900 ]; then
    print_error "RAM is ${TOTAL_RAM}MB. This deployment needs at least 1GB (Azure B1s or better)."
    exit 1
else
    print_azure "RAM: ${TOTAL_RAM}MB (suitable for free tier)"
fi

# Check disk space (should have at least 5GB free)
AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')
REQUIRED_SPACE=5000000  # 5GB in KB
if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    print_error "Insufficient disk space. Available: $(($AVAILABLE_SPACE/1024/1024))GB, Required: 5GB+"
    exit 1
else
    print_azure "Disk space: $(($AVAILABLE_SPACE/1024/1024))GB (sufficient for NO-AI deployment)"
fi

# Check internet connectivity
print_status "Checking internet connectivity..."
if ! curl -s --connect-timeout 5 https://github.com > /dev/null; then
    print_error "No internet connection. Please check your network settings."
    exit 1
fi
print_success "Internet connectivity: OK"

# Detect Azure Free Tier
if curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2021-02-01" > /dev/null 2>&1; then
    VM_SIZE=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute/vmSize?api-version=2021-02-01&format=text")
    print_azure "Detected Azure VM: $VM_SIZE"
    
    if [[ "$VM_SIZE" == *"B1s"* ]]; then
        print_azure "Perfect! B1s VM detected - ideal for free tier deployment"
    elif [[ "$VM_SIZE" == *"B1ms"* ]]; then
        print_azure "B1ms VM detected - excellent for free tier deployment"
    else
        print_warning "VM size $VM_SIZE detected - this deployment works on any size"
    fi
fi

# Confirm deployment
echo ""
print_warning "⚠️  FREE TIER DEPLOYMENT CONFIRMATION"
echo "This will install and configure:"
echo "  • Node.js, Python, and essential dependencies"
echo "  • LZ Custom website with admin dashboard"
echo "  • Simple chat responses (NO AI models)"
echo "  • Nginx reverse proxy with compression"
echo "  • Memory-optimized services for 1GB RAM"
echo ""
echo "Estimated time: 10-15 minutes"
echo "Estimated download: ~500MB (NO AI models)"
echo "Memory usage: ~400-600MB (leaves room for system)"
echo ""
echo "Continue with FREE TIER deployment? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Start deployment
echo ""
print_azure "🚀 Starting Azure Free Tier deployment..."

# Download and execute the free tier provisioning script
print_status "Downloading Azure Free Tier provisioning script..."
curl -fsSL https://raw.githubusercontent.com/george-shepov/LZCustom/main/scripts/azure-free-deploy.sh -o /tmp/azure-free-deploy.sh

if [ ! -f /tmp/azure-free-deploy.sh ]; then
    print_error "Failed to download provisioning script"
    exit 1
fi

chmod +x /tmp/azure-free-deploy.sh

print_status "Executing Azure Free Tier provisioning script..."
/tmp/azure-free-deploy.sh

# Cleanup
rm -f /tmp/azure-free-deploy.sh

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

if [ "$ALL_RUNNING" = true ]; then
    echo ""
    print_success "🎉 AZURE FREE TIER DEPLOYMENT SUCCESSFUL!"
    echo ""
    
    # Get public IP
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "localhost")
    
    echo "🌐 Your LZ Custom website is now live on Azure Free Tier!"
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
    echo "🔧 Free Tier Management Commands:"
    echo "   • Start services: ~/start-lzcustom-free.sh"
    echo "   • Stop services: ~/stop-lzcustom-free.sh"
    echo "   • Monitor system: ~/monitor-lzcustom-free.sh"
    echo "   • Update application: ~/update-lzcustom-free.sh"
    echo ""
    echo "🆓 Free Tier Features:"
    echo "   • Complete admin dashboard with lead management"
    echo "   • Form submissions with zero prospect loss"
    echo "   • Simple chat responses (no AI processing needed)"
    echo "   • Professional responsive design"
    echo "   • Memory-optimized for 1GB RAM"
    echo "   • Bandwidth-optimized with gzip compression"
    echo ""
    echo "💬 Chat Feature (NO AI):"
    echo "   • Predefined helpful responses about services"
    echo "   • Directs users to call 216-268-2990 for details"
    echo "   • All conversations logged for lead tracking"
    echo "   • No memory or processing overhead"
    echo ""
    echo "📊 Resource Usage:"
    MEMORY_USED=$(free -m | awk 'NR==2{printf "%.0f", $3}')
    MEMORY_TOTAL=$(free -m | awk 'NR==2{printf "%.0f", $2}')
    echo "   • Memory: ${MEMORY_USED}MB / ${MEMORY_TOTAL}MB used"
    echo "   • Disk: $(df -h / | awk 'NR==2{printf "%s used of %s", $3, $2}')"
    echo ""
    echo "💡 Next Steps:"
    echo "   1. Access the admin dashboard to manage leads"
    echo "   2. Test the contact form to see lead tracking"
    echo "   3. Try the simple chat responses"
    echo "   4. Monitor resources with ~/monitor-lzcustom-free.sh"
    echo ""
    print_success "Perfect for Azure Free Tier! 🆓☁️"
    
else
    echo ""
    print_error "❌ DEPLOYMENT ISSUES DETECTED"
    echo ""
    echo "Some services are not running properly. Please check:"
    echo "   • Service logs: sudo journalctl -u SERVICE_NAME -f"
    echo "   • System resources: free -h && df -h"
    echo "   • Available memory for free tier"
    echo ""
    echo "For support, please check:"
    echo "   • GitHub Issues: https://github.com/george-shepov/LZCustom/issues"
    echo "   • Deployment logs above for specific errors"
    exit 1
fi
