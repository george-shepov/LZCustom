#!/bin/bash

# LZ Custom Multi-Domain Management Script
<<<<<<< HEAD
# Handles Docker operations, backups, SSL, and GitHub auto-updates
=======
# Safe Docker operations with backup protection
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

COMPOSE_FILE="docker-compose.yml"
BACKUP_DIR="./backups"
<<<<<<< HEAD
REPO_URL="https://github.com/george-shepov/LZCustom.git"
=======
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199

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
    
<<<<<<< HEAD
    # Backup important directories
    if [ -d "frontend" ]; then
        tar -czf "$backup_path/frontend.tar.gz" frontend/ 2>/dev/null || echo "Frontend backup skipped"
    fi
    
    if [ -d "backend" ]; then
        tar -czf "$backup_path/backend.tar.gz" backend/ 2>/dev/null || echo "Backend backup skipped"
    fi
    
    if [ -d "database" ]; then
        tar -czf "$backup_path/database.tar.gz" database/ 2>/dev/null || echo "Database backup skipped"
=======
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
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
    fi
    
    echo -e "${GREEN}✅ Backup created: $backup_path${NC}"
}

<<<<<<< HEAD
# Function to pull latest code from GitHub
update_from_github() {
    echo -e "${BLUE}🔄 Updating code from GitHub...${NC}"
    
    # Stash any local changes
    git stash push -m "Auto-stash before update $(date)" 2>/dev/null || true
    
    # Pull latest changes
    git pull origin main
    
    # Check if there were any changes
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Code updated from GitHub${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  No updates available or pull failed${NC}"
        return 1
    fi
}

=======
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
# Function to start all services
start_services() {
    echo -e "${BLUE}🚀 Starting all services...${NC}"
    
    check_docker
    
    # Create necessary directories
    mkdir -p nginx/conf.d nginx/logs backups
    mkdir -p docker-data/dms/{mail-data,mail-state,config}
    mkdir -p sites/{giorgiy.org,lodexinc.com}
    
<<<<<<< HEAD
    # Stop any existing non-Docker services
    sudo systemctl stop nginx 2>/dev/null || true
    pkill -f "npm run dev" 2>/dev/null || true
    pkill -f "python main.py" 2>/dev/null || true
    
    # Start Docker services
    docker-compose up -d --build
=======
    # Start services
    docker-compose up -d
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
    
    echo -e "${GREEN}✅ All services started!${NC}"
    show_status
}

<<<<<<< HEAD
=======
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

>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
# Function to show service status
show_status() {
    echo -e "${BLUE}📊 Service Status${NC}"
    echo "=================="
    
<<<<<<< HEAD
    if ! docker-compose ps 2>/dev/null | grep -q "Up"; then
        echo -e "${YELLOW}⚠️  No Docker services are currently running${NC}"
        echo -e "${BLUE}💡 Run: ./manage.sh start${NC}"
=======
    if ! docker-compose ps | grep -q "Up"; then
        echo -e "${YELLOW}⚠️  No services are currently running${NC}"
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
        return
    fi
    
    docker-compose ps
    
    echo -e "\n${BLUE}🌐 Your Websites:${NC}"
<<<<<<< HEAD
    echo "• https://lzcustom.giorgiy.org (LZ Custom - Main)"
    echo "• https://lzcustom.bravoohio.org (LZ Custom - Bravo Ohio)"
    echo "• https://lzcustom.lodexinc.com (LZ Custom - Lodex Inc)"
=======
    echo "• https://lzcustom.giorgiy.org (LZ Custom - Professional Fabrication)"
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
    echo "• https://giorgiy.org (Main Landing)"
    echo "• https://giorgiy-shepov.com (Personal - WordPress)"
    echo "• https://lodexinc.com (Lodex Inc)"
    echo "• https://bravoohio.org (Bravo Ohio - Ghost CMS)"
    echo "• https://mail.giorgiy.org (Webmail)"
    
<<<<<<< HEAD
    echo -e "\n${BLUE}🔍 Health Checks:${NC}"
    curl -s http://localhost:8000/api/health 2>/dev/null | head -3 || echo "Backend API: Not responding yet (may still be starting)"
}

# Function to update services with GitHub pull
update_services() {
    echo -e "${BLUE}🔄 Updating services from GitHub...${NC}"
=======
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
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
    
    check_docker
    create_backup
    
<<<<<<< HEAD
    # Pull latest code
    if update_from_github; then
        echo -e "${BLUE}🔄 Rebuilding services with latest code...${NC}"
        
        # Rebuild and restart
        docker-compose up -d --build
        
        echo -e "${GREEN}✅ Services updated from GitHub!${NC}"
        show_status
    else
        echo -e "${YELLOW}⚠️  No code changes, skipping rebuild${NC}"
    fi
}

# Function to setup SSL certificates
=======
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
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
setup_ssl() {
    echo -e "${BLUE}🔐 Setting up SSL certificates...${NC}"
    
    # Stop nginx temporarily
<<<<<<< HEAD
    docker-compose stop nginx 2>/dev/null || true
    
    # Install certbot if not present
    if ! command -v certbot &> /dev/null; then
        echo -e "${BLUE}Installing certbot...${NC}"
        sudo apt update && sudo apt install -y certbot
    fi
    
    # Get certificates for all domains
    echo -e "${BLUE}Getting SSL for giorgiy.org domains...${NC}"
=======
    docker-compose stop nginx
    
    # Get certificates for all domains
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
    sudo certbot certonly --standalone --non-interactive --agree-tos --email georgeshepov@gmail.com \
        -d giorgiy.org -d www.giorgiy.org \
        -d lzcustom.giorgiy.org \
        -d mail.giorgiy.org
    
<<<<<<< HEAD
    echo -e "${BLUE}Getting SSL for giorgiy-shepov.com...${NC}"
    sudo certbot certonly --standalone --non-interactive --agree-tos --email georgeshepov@gmail.com \
        -d giorgiy-shepov.com -d www.giorgiy-shepov.com
    
    echo -e "${BLUE}Getting SSL for lodexinc.com...${NC}"
    sudo certbot certonly --standalone --non-interactive --agree-tos --email georgeshepov@gmail.com \
        -d lodexinc.com -d www.lodexinc.com \
        -d lzcustom.lodexinc.com
    
    echo -e "${BLUE}Getting SSL for bravoohio.org...${NC}"
    sudo certbot certonly --standalone --non-interactive --agree-tos --email georgeshepov@gmail.com \
        -d bravoohio.org -d www.bravoohio.org \
        -d lzcustom.bravoohio.org
=======
    sudo certbot certonly --standalone --non-interactive --agree-tos --email georgeshepov@gmail.com \
        -d giorgiy-shepov.com -d www.giorgiy-shepov.com
    
    sudo certbot certonly --standalone --non-interactive --agree-tos --email georgeshepov@gmail.com \
        -d lodexinc.com -d www.lodexinc.com
    
    sudo certbot certonly --standalone --non-interactive --agree-tos --email georgeshepov@gmail.com \
        -d bravoohio.org -d www.bravoohio.org
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
    
    # Restart nginx
    docker-compose start nginx
    
    echo -e "${GREEN}✅ SSL certificates installed!${NC}"
}

<<<<<<< HEAD
# Function to setup auto-update cron job
setup_auto_update() {
    echo -e "${BLUE}⏰ Setting up auto-update from GitHub...${NC}"
    
    # Create update script
    cat > auto-update.sh << 'EOFSCRIPT'
#!/bin/bash
cd /home/shepov/LZCustom
./manage.sh update >> /var/log/lzcustom-auto-update.log 2>&1
EOFSCRIPT
    
    chmod +x auto-update.sh
    
    # Add to crontab (runs every 6 hours)
    (crontab -l 2>/dev/null; echo "0 */6 * * * /home/shepov/LZCustom/auto-update.sh") | crontab -
    
    echo -e "${GREEN}✅ Auto-update scheduled every 6 hours${NC}"
    echo -e "${BLUE}📋 Check logs: tail -f /var/log/lzcustom-auto-update.log${NC}"
}

=======
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
# Main command handler
case "${1:-help}" in
    "start")
        start_services
        ;;
    "stop")
<<<<<<< HEAD
        docker-compose down 2>/dev/null || true
        echo -e "${GREEN}✅ All services stopped${NC}"
        ;;
    "restart")
        create_backup
        docker-compose down 2>/dev/null || true
        docker-compose up -d --build
        echo -e "${GREEN}✅ All services restarted!${NC}"
        show_status
=======
        stop_services
        ;;
    "restart")
        restart_services
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
        ;;
    "status")
        show_status
        ;;
    "logs")
<<<<<<< HEAD
        if [ -z "$2" ]; then
            echo -e "${BLUE}Available services:${NC}"
            docker-compose config --services 2>/dev/null || echo "lzcustom-frontend lzcustom-backend nginx ollama"
        else
            docker-compose logs -f "$2"
        fi
=======
        view_logs "$2"
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
        ;;
    "update")
        update_services
        ;;
    "backup")
<<<<<<< HEAD
        create_backup
=======
        backup_data
        ;;
    "restore")
        restore_backup "$2"
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
        ;;
    "ssl")
        setup_ssl
        ;;
<<<<<<< HEAD
    "auto-update")
        setup_auto_update
        ;;
=======
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
    "help"|*)
        echo -e "${BLUE}Usage: $0 {command}${NC}"
        echo ""
        echo -e "${GREEN}Available commands:${NC}"
<<<<<<< HEAD
        echo "  start       - Start all services"
        echo "  stop        - Stop all services"
        echo "  restart     - Restart all services (with backup)"
        echo "  status      - Show service status and URLs"
        echo "  logs        - View logs for a specific service"
        echo "  update      - Update from GitHub and rebuild services"
        echo "  backup      - Create manual backup"
        echo "  ssl         - Setup SSL certificates"
        echo "  auto-update - Setup automatic GitHub updates"
        echo "  help        - Show this help"
=======
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
>>>>>>> 4d7235ba580355678b3f9516e87ccb47a1d85199
        ;;
esac
