#!/bin/bash

# Start All Services Script
# Starts all websites, backends, and mail server

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting All Services${NC}"
echo "========================"

# Function to start a frontend service
start_frontend() {
    local domain="$1"
    local port="$2"
    
    echo -e "${BLUE}Starting frontend for $domain on port $port...${NC}"
    
    cd "sites/$domain/frontend"
    
    # Create simple Python HTTP server for static files
    cat > server.py << EOF
#!/usr/bin/env python3
import http.server
import socketserver
import os

PORT = $port

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

if __name__ == "__main__":
    with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
        print(f"Frontend for $domain serving at port {PORT}")
        httpd.serve_forever()
EOF
    
    python3 server.py &
    echo $! > "../frontend.pid"
    cd ../../..
    
    echo -e "${GREEN}✅ Frontend for $domain started on port $port${NC}"
}

# Function to start a backend service
start_backend() {
    local domain="$1"
    local port="$2"
    
    echo -e "${BLUE}Starting backend for $domain on port $port...${NC}"
    
    cd "sites/$domain/backend"
    
    # Install requirements if needed
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    else
        source venv/bin/activate
    fi
    
    # Start the backend
    python3 app.py &
    echo $! > "../backend.pid"
    cd ../../..
    
    echo -e "${GREEN}✅ Backend for $domain started on port $port${NC}"
}

# Function to stop all services
stop_all_services() {
    echo -e "${YELLOW}Stopping all services...${NC}"
    
    # Stop frontends and backends
    for domain in giorgiy.org giorgiy-shepov.com lodexinc.com bravoohiocci.org; do
        if [ -f "sites/$domain/frontend.pid" ]; then
            kill $(cat "sites/$domain/frontend.pid") 2>/dev/null || true
            rm -f "sites/$domain/frontend.pid"
        fi
        
        if [ -f "sites/$domain/backend.pid" ]; then
            kill $(cat "sites/$domain/backend.pid") 2>/dev/null || true
            rm -f "sites/$domain/backend.pid"
        fi
    done
    
    # Stop any Python servers on our ports
    sudo pkill -f "python3.*server.py" || true
    sudo pkill -f "python3.*app.py" || true
    
    echo -e "${GREEN}✅ All services stopped${NC}"
}

# Function to start mail server
start_mail_server() {
    echo -e "${BLUE}Starting mail server...${NC}"
    
    if [ -f "docker-compose-mail.yml" ]; then
        docker-compose -f docker-compose-mail.yml up -d
        echo -e "${GREEN}✅ Mail server started${NC}"
    else
        echo -e "${YELLOW}⚠️  Mail server config not found, skipping...${NC}"
    fi
}

# Function to setup Nginx
setup_nginx() {
    echo -e "${BLUE}Setting up Nginx...${NC}"
    
    if [ -f "nginx/conf.d/multi-domain.conf" ]; then
        sudo cp nginx/conf.d/multi-domain.conf /etc/nginx/sites-available/multi-domain
        sudo ln -sf /etc/nginx/sites-available/multi-domain /etc/nginx/sites-enabled/
        sudo rm -f /etc/nginx/sites-enabled/default
        
        # Test and reload nginx
        if sudo nginx -t; then
            sudo systemctl reload nginx
            echo -e "${GREEN}✅ Nginx configured and reloaded${NC}"
        else
            echo -e "${YELLOW}⚠️  Nginx configuration error${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Nginx config not found${NC}"
    fi
}

# Function to show status
show_status() {
    echo -e "${BLUE}📊 Service Status${NC}"
    echo "=================="
    
    echo -e "${BLUE}Websites:${NC}"
    echo "• https://giorgiy.org (LZ Custom)"
    echo "• https://giorgiy-shepov.com (Personal)"
    echo "• https://lodexinc.com (Lodex Inc)"
    echo "• https://bravoohiocci.org (Bravo Ohio CCI)"
    
    echo -e "${BLUE}Direct Access (for testing):${NC}"
    echo "• http://104.237.9.52:3001 (LZ Custom frontend)"
    echo "• http://104.237.9.52:3002 (Personal frontend)"
    echo "• http://104.237.9.52:3003 (Lodex frontend)"
    echo "• http://104.237.9.52:3004 (Bravo Ohio frontend)"
    
    echo -e "${BLUE}APIs:${NC}"
    echo "• http://104.237.9.52:4001/api (LZ Custom API)"
    echo "• http://104.237.9.52:4002/api (Personal API)"
    echo "• http://104.237.9.52:4003/api (Lodex API)"
    echo "• http://104.237.9.52:4004/api (Bravo Ohio API)"
    
    echo -e "${BLUE}Mail:${NC}"
    echo "• https://mail.giorgiy.org (Webmail)"
    
    echo -e "${GREEN}All services should be running!${NC}"
}

# Main execution
main() {
    case "${1:-start}" in
        "start")
            echo -e "${BLUE}[START] Starting all services...${NC}"
            
            # Stop any existing services first
            stop_all_services
            
            # Start all frontends
            start_frontend "giorgiy.org" "3001"
            start_frontend "giorgiy-shepov.com" "3002"
            start_frontend "lodexinc.com" "3003"
            start_frontend "bravoohiocci.org" "3004"
            
            # Start all backends
            start_backend "giorgiy.org" "4001"
            start_backend "giorgiy-shepov.com" "4002"
            start_backend "lodexinc.com" "4003"
            start_backend "bravoohiocci.org" "4004"
            
            # Start mail server
            start_mail_server
            
            # Setup Nginx
            setup_nginx
            
            # Show status
            show_status
            
            echo -e "${GREEN}🎉 All services started successfully!${NC}"
            ;;
            
        "stop")
            stop_all_services
            docker-compose -f docker-compose-mail.yml down 2>/dev/null || true
            ;;
            
        "restart")
            $0 stop
            sleep 2
            $0 start
            ;;
            
        "status")
            show_status
            ;;
            
        *)
            echo "Usage: $0 {start|stop|restart|status}"
            echo ""
            echo "Commands:"
            echo "  start   - Start all services"
            echo "  stop    - Stop all services"
            echo "  restart - Restart all services"
            echo "  status  - Show service status"
            ;;
    esac
}

# Handle Ctrl+C
trap 'echo -e "\n${YELLOW}Stopping services...${NC}"; stop_all_services; exit 0' INT

main "$@"
