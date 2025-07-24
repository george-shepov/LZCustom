#!/bin/bash

# SSL Certificate Setup for Multiple Domains
# This script sets up Let's Encrypt SSL certificates for all domains

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔐 SSL Certificate Setup for Multiple Domains${NC}"
echo "=================================================="

# Domains to secure
DOMAINS=(
    "giorgiy.org"
    "www.giorgiy.org"
    "giorgiy-shepov.com"
    "www.giorgiy-shepov.com"
    "bravoohio.org"
    "www.bravoohio.org"
    "lodexinc.com"
    "www.lodexinc.com"
)

# Function to check if domain points to this server
check_domain_dns() {
    local domain="$1"
    local server_ip=$(curl -s ifconfig.me)
    local domain_ip=$(dig +short "$domain" | tail -n1)
    
    if [ "$domain_ip" = "$server_ip" ]; then
        echo -e "${GREEN}✅ $domain points to this server ($server_ip)${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  $domain points to $domain_ip, not $server_ip${NC}"
        return 1
    fi
}

# Function to setup basic nginx config for domain verification
setup_basic_nginx() {
    echo -e "${BLUE}[INFO] Setting up basic Nginx configuration...${NC}"
    
    # Create basic config for domain verification
    cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    
    server_name _;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 200 'SSL Setup in Progress...';
        add_header Content-Type text/plain;
    }
}
EOF
    
    # Enable the site
    sudo ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl reload nginx
}

# Function to obtain SSL certificate for a domain
obtain_ssl_cert() {
    local primary_domain="$1"
    local additional_domains="$2"
    
    echo -e "${BLUE}[INFO] Obtaining SSL certificate for $primary_domain...${NC}"
    
    # Build certbot command
    local certbot_cmd="sudo certbot certonly --nginx --non-interactive --agree-tos --email georgeshepov@gmail.com"
    certbot_cmd="$certbot_cmd -d $primary_domain"
    
    if [ -n "$additional_domains" ]; then
        for domain in $additional_domains; do
            certbot_cmd="$certbot_cmd -d $domain"
        done
    fi
    
    # Run certbot
    if eval "$certbot_cmd"; then
        echo -e "${GREEN}✅ SSL certificate obtained for $primary_domain${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to obtain SSL certificate for $primary_domain${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo -e "${BLUE}[START] SSL certificate setup started${NC}"
    
    # Check if running as root or with sudo
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}❌ Please run this script with sudo${NC}"
        exit 1
    fi
    
    # Install required packages
    echo -e "${BLUE}[INFO] Installing required packages...${NC}"
    apt update
    apt install -y nginx certbot python3-certbot-nginx dig
    
    # Setup basic nginx
    setup_basic_nginx
    
    # Check DNS for each domain
    echo -e "${BLUE}[INFO] Checking DNS configuration...${NC}"
    for domain in "${DOMAINS[@]}"; do
        check_domain_dns "$domain" || echo -e "${YELLOW}[WARNING] $domain may not be ready for SSL${NC}"
    done
    
    # Obtain SSL certificates
    echo -e "${BLUE}[INFO] Obtaining SSL certificates...${NC}"
    
    # Primary domain with www
    obtain_ssl_cert "giorgiy.org" "www.giorgiy.org"
    
    # Other domains
    obtain_ssl_cert "giorgiy-shepov.com" "www.giorgiy-shepov.com"
    obtain_ssl_cert "bravoohio.org" "www.bravoohio.org"
    obtain_ssl_cert "lodexinc.com" "www.lodexinc.com"
    
    # Install the production nginx config
    echo -e "${BLUE}[INFO] Installing production Nginx configuration...${NC}"
    
    # For Docker deployment, copy to the container mount point
    if [ -d "nginx/conf.d" ]; then
        cp nginx/conf.d/multi-domain.conf /etc/nginx/conf.d/
        echo -e "${GREEN}✅ Docker nginx config updated${NC}"
    else
        # For direct server deployment
        cp nginx-multi-domain.conf /etc/nginx/sites-available/multi-domain 2>/dev/null || true
        ln -sf /etc/nginx/sites-available/multi-domain /etc/nginx/sites-enabled/ 2>/dev/null || true
        rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true
        echo -e "${GREEN}✅ Server nginx config updated${NC}"
    fi
    
    # Test and reload nginx
    if nginx -t; then
        systemctl reload nginx
        echo -e "${GREEN}✅ Nginx configuration updated${NC}"
    else
        echo -e "${RED}❌ Nginx configuration error${NC}"
        exit 1
    fi
    
    # Setup auto-renewal
    echo -e "${BLUE}[INFO] Setting up SSL certificate auto-renewal...${NC}"
    (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
    
    echo -e "${GREEN}🎉 SSL setup completed!${NC}"
    echo -e "${BLUE}Your domains are now secured with HTTPS:${NC}"
    for domain in giorgiy.org giorgiy-shepov.com bravoohio.org lodexinc.com; do
        echo -e "  • https://$domain"
        echo -e "  • https://www.$domain"
    done
}

# Run main function
main "$@"
