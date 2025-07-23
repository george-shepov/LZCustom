#!/bin/bash

# Multi-Domain Website Setup Script
# Creates 4 professional websites with contact forms and email integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🌐 Multi-Domain Website Setup${NC}"
echo "=================================="

# Create directory structure
create_directories() {
    echo -e "${BLUE}[INFO] Creating directory structure...${NC}"
    
    # Main domains
    DOMAINS=("giorgiy.org" "giorgiy-shepov.com" "lodexinc.com" "bravoohiocci.org")
    
    for domain in "${DOMAINS[@]}"; do
        echo -e "${BLUE}Creating structure for $domain...${NC}"
        
        # Create domain directories
        mkdir -p "sites/$domain"/{frontend,backend,database}
        mkdir -p "sites/$domain/frontend"/{static,templates}
        mkdir -p "sites/$domain/backend"/{app,config}
        
        # Create basic files
        touch "sites/$domain/database/contacts.db"
        touch "sites/$domain/backend/app.py"
        touch "sites/$domain/frontend/index.html"
        
        echo -e "${GREEN}✅ Structure created for $domain${NC}"
    done
    
    # Create shared directories
    mkdir -p nginx/conf.d
    mkdir -p ssl
    mkdir -p logs
    
    echo -e "${GREEN}[SUCCESS] Directory structure created${NC}"
}

# Create Nginx configuration
create_nginx_config() {
    echo -e "${BLUE}[INFO] Creating Nginx configuration...${NC}"
    
    cat > nginx/conf.d/multi-domain.conf << 'EOF'
# Multi-Domain Nginx Configuration
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name giorgiy.org www.giorgiy.org giorgiy-shepov.com www.giorgiy-shepov.com lodexinc.com www.lodexinc.com bravoohiocci.org www.bravoohiocci.org;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# giorgiy.org - LZ Custom (Main Site)
server {
    listen 443 ssl http2;
    server_name giorgiy.org www.giorgiy.org;
    
    ssl_certificate /etc/letsencrypt/live/giorgiy.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/giorgiy.org/privkey.pem;
    
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    location / {
        proxy_pass http://localhost:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/ {
        proxy_pass http://localhost:4001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# giorgiy-shepov.com - Personal Site
server {
    listen 443 ssl http2;
    server_name giorgiy-shepov.com www.giorgiy-shepov.com;
    
    ssl_certificate /etc/letsencrypt/live/giorgiy-shepov.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/giorgiy-shepov.com/privkey.pem;
    
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    location / {
        proxy_pass http://localhost:3002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/ {
        proxy_pass http://localhost:4002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# lodexinc.com - Lodex Inc
server {
    listen 443 ssl http2;
    server_name lodexinc.com www.lodexinc.com;
    
    ssl_certificate /etc/letsencrypt/live/lodexinc.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/lodexinc.com/privkey.pem;
    
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    location / {
        proxy_pass http://localhost:3003;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/ {
        proxy_pass http://localhost:4003;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# bravoohiocci.org - Bravo Ohio CCI
server {
    listen 443 ssl http2;
    server_name bravoohiocci.org www.bravoohiocci.org;
    
    ssl_certificate /etc/letsencrypt/live/bravoohiocci.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/bravoohiocci.org/privkey.pem;
    
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    location / {
        proxy_pass http://localhost:3004;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/ {
        proxy_pass http://localhost:4004;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Mail server web interface
server {
    listen 443 ssl http2;
    server_name mail.giorgiy.org;
    
    ssl_certificate /etc/letsencrypt/live/giorgiy.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/giorgiy.org/privkey.pem;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
    
    echo -e "${GREEN}[SUCCESS] Nginx configuration created${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}[START] Multi-domain setup started${NC}"
    
    create_directories
    create_nginx_config
    
    echo -e "${GREEN}[COMPLETE] Multi-domain setup completed${NC}"
    echo -e "${BLUE}[INFO] Next steps:${NC}"
    echo -e "  1. Run SSL setup: sudo ./setup-ssl.sh"
    echo -e "  2. Create website content with: ./create-websites.sh"
    echo -e "  3. Start mail server: docker-compose -f docker-compose-mail.yml up -d"
}

# Run main function
main "$@"
