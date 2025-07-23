#!/bin/bash

# LZ Custom Multi-Domain Management Script
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🐳 LZ Custom Multi-Domain Manager${NC}"
echo "=================================="

# Function to show service status
show_status() {
    echo -e "${BLUE}📊 Service Status${NC}"
    echo "=================="
    
    docker-compose ps
    
    echo -e "\n${BLUE}🌐 Your Websites:${NC}"
    echo "• Frontend: http://104.237.9.52:3000"
    echo "• Backend API: http://104.237.9.52:8001"
    echo "• Nginx Proxy: http://104.237.9.52:8080"
    
    echo -e "\n${BLUE}🔍 Health Checks:${NC}"
    curl -s http://localhost:8001/health 2>/dev/null | head -3 || echo "Backend: Not responding"
    curl -s http://localhost:11435/api/tags 2>/dev/null | jq '.models[0].name' 2>/dev/null || echo "Ollama: Not responding"
}

# Main command handler
case "${1:-status}" in
    "start")
        echo -e "${BLUE}🚀 Starting all services...${NC}"
        docker-compose up -d
        show_status
        ;;
    "stop")
        echo -e "${YELLOW}🛑 Stopping all services...${NC}"
        docker-compose down
        ;;
    "restart")
        echo -e "${BLUE}🔄 Restarting all services...${NC}"
        docker-compose down
        docker-compose up -d
        show_status
        ;;
    "status")
        show_status
        ;;
    "logs")
        if [ -z "$2" ]; then
            echo "Available services: lzcustom-frontend lzcustom-backend nginx ollama"
        else
            docker-compose logs -f "$2"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        ;;
esac
