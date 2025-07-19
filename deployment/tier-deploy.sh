#!/bin/bash

# VPS Dime Tier-Based Deployment Script
# Automatically detects or sets VPS tier and deploys appropriate configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "      LZ Custom - VPS Dime Tier Deployment"
    echo "=================================================="
    echo -e "${NC}"
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

detect_system_resources() {
    local memory_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local memory_gb=$((memory_kb / 1024 / 1024))
    local cpu_cores=$(nproc)
    
    echo "Detected System Resources:"
    echo "  Memory: ${memory_gb}GB"
    echo "  CPU Cores: ${cpu_cores}"
    
    # Determine tier based on memory
    if [ $memory_gb -le 1 ]; then
        DETECTED_TIER="tier1"
    elif [ $memory_gb -le 3 ]; then
        DETECTED_TIER="tier2"
    elif [ $memory_gb -le 6 ]; then
        DETECTED_TIER="tier3"
    elif [ $memory_gb -le 12 ]; then
        DETECTED_TIER="tier4"
    else
        DETECTED_TIER="tier5"
    fi
    
    echo "  Recommended Tier: ${DETECTED_TIER}"
}

select_tier() {
    if [ -n "$VPS_TIER" ]; then
        SELECTED_TIER=$VPS_TIER
        print_status "Using environment tier: $SELECTED_TIER"
        return
    fi
    
    if [ -n "$1" ]; then
        SELECTED_TIER=$1
        print_status "Using specified tier: $SELECTED_TIER"
        return
    fi
    
    detect_system_resources
    
    echo ""
    echo "Available VPS Tiers:"
    echo "  tier1 (1GB)  - Basic website + external AI     - $3-5/month"
    echo "  tier2 (2GB)  - Local AI + Redis               - $6-10/month"
    echo "  tier3 (4GB)  - Smart AI + Analytics           - $15-20/month"
    echo "  tier4 (8GB)  - Dual AI + Monitoring           - $25-35/month ⭐ RECOMMENDED"
    echo "  tier5 (16GB) - Full AI stack + Enterprise     - $45-60/month"
    echo ""
    
    read -p "Select tier (or press Enter for detected tier $DETECTED_TIER): " user_input
    SELECTED_TIER=${user_input:-$DETECTED_TIER}
}

validate_tier() {
    case $SELECTED_TIER in
        tier1|tier2|tier3|tier4|tier5)
            print_status "Selected tier: $SELECTED_TIER"
            ;;
        *)
            print_error "Invalid tier: $SELECTED_TIER"
            print_error "Valid tiers: tier1, tier2, tier3, tier4, tier5"
            exit 1
            ;;
    esac
}

setup_environment() {
    print_status "Setting up environment for $SELECTED_TIER..."
    
    # Create .env file if it doesn't exist
    if [ ! -f .env ]; then
        print_status "Creating .env file..."
        cat > .env << EOF
# VPS Tier Configuration
VPS_TIER=$SELECTED_TIER

# Database Configuration
DB_PASSWORD=lzpassword123

# VPS Dime Referral Configuration
REFERRAL_CODE=lzcustom
VPS_DIME_AFFILIATE_URL=https://vpsdime.com?ref=lzcustom

# External AI Configuration (Tier 1)
OPENAI_API_KEY=your_openai_key_here

# Monitoring Configuration (Tier 4+)
GRAFANA_PASSWORD=admin123

# SSL Configuration
SSL_EMAIL=admin@lzcustom.com
EOF
        print_warning "Please edit .env file with your actual configuration"
    fi
    
    # Create necessary directories
    mkdir -p backups logs monitoring/grafana/{dashboards,datasources} ssl nginx
}

install_dependencies() {
    print_status "Installing dependencies..."
    
    # Update system
    sudo apt-get update
    
    # Install Docker if not present
    if ! command -v docker &> /dev/null; then
        print_status "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
    fi
    
    # Install Docker Compose if not present
    if ! command -v docker-compose &> /dev/null; then
        print_status "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
}

create_nginx_config() {
    print_status "Creating Nginx configuration for $SELECTED_TIER..."
    
    cat > nginx/${SELECTED_TIER}.conf << 'EOF'
server {
    listen 80;
    server_name _;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Frontend
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files $uri $uri/ /index.html;
    }
    
    # API proxy
    location /api/ {
        proxy_pass http://backend:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Health check
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF
}

create_monitoring_config() {
    if [[ "$SELECTED_TIER" == "tier4" || "$SELECTED_TIER" == "tier5" ]]; then
        print_status "Creating monitoring configuration..."
        
        # Prometheus config
        cat > monitoring/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'lzcustom-backend'
    static_configs:
      - targets: ['backend:8000']
    metrics_path: '/metrics'
    
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']
      
  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
EOF
        
        # Grafana datasource
        mkdir -p monitoring/grafana/datasources
        cat > monitoring/grafana/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
EOF
    fi
}

deploy_tier() {
    print_status "Deploying $SELECTED_TIER configuration..."
    
    # Stop any existing containers
    if [ -f "docker-compose.${SELECTED_TIER}.yml" ]; then
        docker-compose -f docker-compose.${SELECTED_TIER}.yml down 2>/dev/null || true
    fi
    
    # Check if compose file exists
    if [ ! -f "docker-compose.${SELECTED_TIER}.yml" ]; then
        print_error "Docker compose file for $SELECTED_TIER not found!"
        print_status "Available configurations:"
        ls -1 docker-compose.tier*.yml 2>/dev/null || echo "  No tier configurations found"
        exit 1
    fi
    
    # Deploy the selected tier
    print_status "Starting services for $SELECTED_TIER..."
    docker-compose -f docker-compose.${SELECTED_TIER}.yml up -d
    
    # Wait for services to be ready
    print_status "Waiting for services to start..."
    sleep 10
    
    # Show status
    docker-compose -f docker-compose.${SELECTED_TIER}.yml ps
}

show_success_info() {
    print_header
    echo -e "${GREEN}Deployment Successful!${NC}"
    echo ""
    echo "VPS Tier: $SELECTED_TIER"
    echo "Website: http://$(curl -s ifconfig.me 2>/dev/null || echo 'your-server-ip')"
    echo "API: http://$(curl -s ifconfig.me 2>/dev/null || echo 'your-server-ip'):8000"
    echo ""
    
    case $SELECTED_TIER in
        tier1)
            echo "Features: Basic website, External AI (limited usage)"
            echo "Next: Edit .env file and add your OpenAI API key"
            ;;
        tier2)
            echo "Features: Local AI, Redis caching"
            echo "AI Model: llama3.2:1b (downloading in background)"
            ;;
        tier3)
            echo "Features: Smart AI, Analytics, PostgreSQL"
            echo "AI Model: llama3.2:3b (downloading in background)"
            ;;
        tier4)
            echo "Features: Dual AI, Monitoring, Analytics"
            echo "AI Models: llama3.2:3b, gemma3:4b (downloading in background)"
            echo "Monitoring: http://$(curl -s ifconfig.me 2>/dev/null || echo 'your-server-ip'):3000 (admin/admin123)"
            ;;
        tier5)
            echo "Features: Full AI stack, Enterprise monitoring"
            echo "AI Models: llama3.2:3b, gemma3:4b, qwen2.5:7b"
            echo "Monitoring: http://$(curl -s ifconfig.me 2>/dev/null || echo 'your-server-ip'):3000"
            ;;
    esac
    
    echo ""
    echo "VPS Dime 3-Day Trial: https://vpsdime.com?ref=lzcustom"
    echo "Upgrade anytime: Contact support or use the upgrade prompts in the app"
    echo ""
    echo "Logs: docker-compose -f docker-compose.${SELECTED_TIER}.yml logs -f"
    echo "Stop: docker-compose -f docker-compose.${SELECTED_TIER}.yml down"
}

# Main execution
print_header

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --tier)
            VPS_TIER="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--tier tierX]"
            echo "  --tier: Specify VPS tier (tier1-tier5)"
            echo "  --help: Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Main deployment flow
select_tier $VPS_TIER
validate_tier
setup_environment
install_dependencies
create_nginx_config
create_monitoring_config
deploy_tier
show_success_info

print_status "Deployment complete! 🚀"