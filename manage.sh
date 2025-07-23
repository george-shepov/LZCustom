#!/bin/bash

# LZ Custom Multi-Domain Management Script
# Safe Docker operations with backup protection

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

COMPOSE_FILE="docker-compose.yml"
BACKUP_DIR="./backups"

echo -e "${BLUE}🐳 LZ Custom Multi-Domain Manager${NC}"
echo "=================================="

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
        exit 1
    fi
}

# Function to create backup before major operations
create_backup() {
    echo -e "${YELLOW}📦 Creating safety backup...${NC}"
    
    local backup_name="manual_backup_$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    mkdir -p "$backup_path"
    
    # Backup databases if containers are running
    if docker-compose ps | grep -q mysql-db; then
        echo "Backing up databases..."
        docker-compose exec -T mysql-db mysqldump -u root -proot_password_secure --all-databases > "$backup_path/databases.sql" 2>/dev/null || echo "Database backup skipped (container not ready)"
    fi
    
    # Backup important directories
    if [ -d "LZCustom" ]; then
        tar -czf "$backup_path/lzcustom.tar.gz" LZCustom/ 2>/dev/null || echo "LZCustom backup skipped"
    fi
    
    if [ -d "sites" ]; then
        tar -czf "$backup_path/sites.tar.gz" sites/ 2>/dev/null || echo "Sites backup skipped"
    fi
    
    echo -e "${GREEN}✅ Backup created: $backup_path${NC}"
}

# Function to start all services
start_services() {
    echo -e "${BLUE}🚀 Starting all services...${NC}"
    
    check_docker
    
    # Create necessary directories
    mkdir -p nginx/conf.d nginx/logs backups
    mkdir -p docker-data/dms/{mail-data,mail-state,config}
    mkdir -p sites/{giorgiy.org,lodexinc.com}
    
    # Start services
    docker-compose up -d
    
    echo -e "${GREEN}✅ All services started!${NC}"
    show_status
}

# Function to stop all services
stop_services() {
    echo -e "${YELLOW}🛑 Stopping all services...${NC}"
    
    check_docker
    create_backup
    
    docker-compose down
    
    echo -e "${GREEN}✅ All services stopped safely${NC}"
}

# Function to restart services
restart_services() {
    echo -e "${BLUE}🔄 Restarting all services...${NC}"
    
    check_docker
    create_backup
    
    docker-compose down
    docker-compose up -d
    
    echo -e "${GREEN}✅ All services restarted!${NC}"
    show_status
}

# Function to show service status
show_status() {
    echo -e "${BLUE}📊 Service Status${NC}"
    echo "=================="
    
    if ! docker-compose ps | grep -q "Up"; then
        echo -e "${YELLOW}⚠️  No services are currently running${NC}"
        return
    fi
    
    docker-compose ps
    
    echo -e "\n${BLUE}🌐 Your Websites:${NC}"
    echo "• https://lzcustom.giorgiy.org (LZ Custom - Professional Fabrication)"
    echo "• https://giorgiy.org (Main Landing)"
    echo "• https://giorgiy-shepov.com (Personal - WordPress)"
    echo "• https://lodexinc.com (Lodex Inc)"
    echo "• https://bravoohio.org (Bravo Ohio - Ghost CMS)"
    echo "• https://mail.giorgiy.org (Webmail)"
    
    echo -e "\n${BLUE}📧 Email Domains:${NC}"
    echo "• info@giorgiy.org"
    echo "• contact@giorgiy-shepov.com"
    echo "• info@lodexinc.com"
    echo "• info@bravoohio.org"
}

# Function to view logs
view_logs() {
    local service="$1"
    
    if [ -z "$service" ]; then
        echo -e "${BLUE}📋 Available services:${NC}"
        docker-compose config --services
        echo ""
        echo "Usage: $0 logs <service-name>"
        echo "Example: $0 logs lzcustom-frontend"
        return
    fi
    
    echo -e "${BLUE}📋 Viewing logs for $service...${NC}"
    docker-compose logs -f "$service"
}

# Function to update services
update_services() {
    echo -e "${BLUE}🔄 Updating services...${NC}"
    
    check_docker
    create_backup
    
    # Pull latest images
    docker-compose pull
    
    # Rebuild and restart
    docker-compose up -d --build
    
    echo -e "${GREEN}✅ Services updated!${NC}"
    show_status
}

# Function to backup data
backup_data() {
    echo -e "${BLUE}💾 Creating full backup...${NC}"
    
    create_backup
    
    echo -e "${GREEN}✅ Backup completed!${NC}"
    echo -e "${BLUE}📁 Backups are stored in: $BACKUP_DIR${NC}"
    ls -la "$BACKUP_DIR" | tail -5
}

# Function to restore from backup
restore_backup() {
    local backup_name="$1"
    
    if [ -z "$backup_name" ]; then
        echo -e "${BLUE}📁 Available backups:${NC}"
        ls -la "$BACKUP_DIR" | grep "^d" | tail -10
        echo ""
        echo "Usage: $0 restore <backup-directory-name>"
        return
    fi
    
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [ ! -d "$backup_path" ]; then
        echo -e "${RED}❌ Backup not found: $backup_path${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}⚠️  This will restore from backup and restart services.${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Restore cancelled."
        return
    fi
    
    echo -e "${BLUE}🔄 Restoring from backup...${NC}"
    
    # Stop services
    docker-compose down
    
    # Restore files
    if [ -f "$backup_path/lzcustom.tar.gz" ]; then
        tar -xzf "$backup_path/lzcustom.tar.gz"
    fi
    
    if [ -f "$backup_path/sites.tar.gz" ]; then
        tar -xzf "$backup_path/sites.tar.gz"
    fi
    
    # Start services
    docker-compose up -d
    
    # Restore database
    if [ -f "$backup_path/databases.sql" ]; then
        echo "Waiting for database to be ready..."
        sleep 30
        docker-compose exec -T mysql-db mysql -u root -proot_password_secure < "$backup_path/databases.sql"
    fi
    
    echo -e "${GREEN}✅ Restore completed!${NC}"
    show_status
}

# Function to get SSL certificates
setup_ssl() {
    echo -e "${BLUE}🔐 Setting up SSL certificates...${NC}"
    
    # Stop nginx temporarily
    docker-compose stop nginx
    
    # Get certificates for all domains
    sudo certbot certonly --standalone --non-interactive --agree-tos --email georgeshepov@gmail.com \
        -d giorgiy.org -d www.giorgiy.org \
        -d lzcustom.giorgiy.org \
        -d mail.giorgiy.org
    
    sudo certbot certonly --standalone --non-interactive --agree-tos --email georgeshepov@gmail.com \
        -d giorgiy-shepov.com -d www.giorgiy-shepov.com
    
    sudo certbot certonly --standalone --non-interactive --agree-tos --email georgeshepov@gmail.com \
        -d lodexinc.com -d www.lodexinc.com
    
    sudo certbot certonly --standalone --non-interactive --agree-tos --email georgeshepov@gmail.com \
        -d bravoohio.org -d www.bravoohio.org
    
    # Restart nginx
    docker-compose start nginx
    
    echo -e "${GREEN}✅ SSL certificates installed!${NC}"
}

# Main command handler
case "${1:-help}" in
    "start")
        start_services
        ;;
    "stop")
        stop_services
        ;;
    "restart")
        restart_services
        ;;
    "status")
        show_status
        ;;
    "logs")
        view_logs "$2"
        ;;
    "update")
        update_services
        ;;
    "backup")
        backup_data
        ;;
    "restore")
        restore_backup "$2"
        ;;
    "ssl")
        setup_ssl
        ;;
    "help"|*)
        echo -e "${BLUE}Usage: $0 {command}${NC}"
        echo ""
        echo -e "${GREEN}Available commands:${NC}"
        echo "  start    - Start all services"
        echo "  stop     - Stop all services (with backup)"
        echo "  restart  - Restart all services (with backup)"
        echo "  status   - Show service status and URLs"
        echo "  logs     - View logs for a specific service"
        echo "  update   - Update and rebuild services"
        echo "  backup   - Create manual backup"
        echo "  restore  - Restore from backup"
        echo "  ssl      - Setup SSL certificates"
        echo "  help     - Show this help"
        echo ""
        echo -e "${BLUE}Examples:${NC}"
        echo "  $0 start"
        echo "  $0 logs lzcustom-frontend"
        echo "  $0 backup"
        echo "  $0 restore manual_backup_20250722_120000"
        ;;
esac
