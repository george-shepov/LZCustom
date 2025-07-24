#!/bin/bash

# LZCustom Enterprise Deployment Script
# Deploys full multi-database stack with PostgreSQL, Redis, MongoDB, and Qdrant

set -e

echo "🚀 Starting LZCustom Enterprise Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "docker-compose.enterprise.yml" ]; then
    print_error "docker-compose.enterprise.yml not found. Are you in the LZCustom directory?"
    exit 1
fi

# Create necessary directories for database initialization
print_status "Creating database initialization directories..."
mkdir -p database/init
mkdir -p database/mongo-init
mkdir -p uploads
mkdir -p nginx/logs

# Copy database initialization files
print_status "Copying database initialization files..."
cp init-postgres.sql database/init/ 2>/dev/null || print_warning "init-postgres.sql not found in current directory"
cp init-mongo.js database/mongo-init/ 2>/dev/null || print_warning "init-mongo.js not found in current directory"

# Stop any existing containers
print_status "Stopping existing containers..."
docker-compose -f docker-compose.enterprise.yml down 2>/dev/null || true

# Pull latest images
print_status "Pulling latest Docker images..."
docker-compose -f docker-compose.enterprise.yml pull

# Build custom images
print_status "Building custom application images..."
docker-compose -f docker-compose.enterprise.yml build --no-cache

# Start the enterprise stack
print_status "Starting enterprise database stack..."
docker-compose -f docker-compose.enterprise.yml up -d postgres redis mongo qdrant

# Wait for databases to be ready
print_status "Waiting for databases to initialize..."
sleep 30

# Check database health
print_status "Checking database connectivity..."

# Check PostgreSQL
if docker-compose -f docker-compose.enterprise.yml exec -T postgres pg_isready -U lzcustom -d lzcustom_db > /dev/null 2>&1; then
    print_success "PostgreSQL is ready"
else
    print_warning "PostgreSQL might not be fully ready yet"
fi

# Check Redis
if docker-compose -f docker-compose.enterprise.yml exec -T redis redis-cli ping > /dev/null 2>&1; then
    print_success "Redis is ready"
else
    print_warning "Redis might not be fully ready yet"
fi

# Check MongoDB
if docker-compose -f docker-compose.enterprise.yml exec -T mongo mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    print_success "MongoDB is ready"
else
    print_warning "MongoDB might not be fully ready yet"
fi

# Start the application services
print_status "Starting application services..."
docker-compose -f docker-compose.enterprise.yml up -d lzcustom-backend lzcustom-frontend

# Wait for backend to initialize
print_status "Waiting for backend to initialize..."
sleep 15

# Start supporting services
print_status "Starting supporting services..."
docker-compose -f docker-compose.enterprise.yml up -d nginx ollama

# Optional: Start admin tools
read -p "Do you want to start database admin tools (pgAdmin, Redis Commander, Mongo Express)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Starting database admin tools..."
    docker-compose -f docker-compose.enterprise.yml up -d pgadmin redis-commander mongo-express
    
    print_success "Admin tools started:"
    echo "  - pgAdmin: http://localhost:5050 (admin@giorgiy.org / pgadmin_password)"
    echo "  - Redis Commander: http://localhost:8081"
    echo "  - Mongo Express: http://localhost:8082 (admin / mongoexpress_password)"
fi

# Optional: Start monitoring
read -p "Do you want to start monitoring services (Prometheus, Grafana)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Starting monitoring services..."
    docker-compose -f docker-compose.enterprise.yml up -d prometheus grafana
    
    print_success "Monitoring started:"
    echo "  - Prometheus: http://localhost:9090"
    echo "  - Grafana: http://localhost:3001 (admin / grafana_password)"
fi

# Show status
print_status "Checking final deployment status..."
docker-compose -f docker-compose.enterprise.yml ps

# Test API endpoints
print_status "Testing API endpoints..."
sleep 5

# Test health endpoint
if curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    print_success "Backend API is responding"
else
    print_warning "Backend API might not be ready yet"
fi

# Display final information
echo
print_success "🎉 LZCustom Enterprise Deployment Complete!"
echo
echo "📋 Service Information:"
echo "  Frontend: http://localhost:5173"
echo "  Backend API: http://localhost:8000"
echo "  API Docs: http://localhost:8000/docs"
echo "  Health Check: http://localhost:8000/api/health"
echo
echo "🔍 Domain-Specific API Endpoints:"
echo "  LZ Custom (giorgiy.org):"
echo "    - Prospects: POST /api/lz-custom/prospects"
echo "    - Chat: POST /api/lz-custom/chat"
echo "  GS Consulting (giorgiy-shepov.com):"
echo "    - Prospects: POST /api/gs-consulting/prospects"  
echo "    - Chat: POST /api/gs-consulting/chat"
echo "  Bravo Ohio (bravoohio.org):"
echo "    - Prospects: POST /api/bravo-ohio/prospects"
echo "    - Chat: POST /api/bravo-ohio/chat"
echo "  Lodex Inc (lodexinc.com):"
echo "    - Prospects: POST /api/lodex-inc/prospects"
echo "    - Chat: POST /api/lodex-inc/chat"
echo
echo "💾 Database Ports:"
echo "  PostgreSQL: localhost:5432"
echo "  Redis: localhost:6379"
echo "  MongoDB: localhost:27017"
echo "  Qdrant: localhost:6333"
echo
echo "📊 Analytics:"
echo "  Overview: GET /api/analytics/overview"
echo
print_status "To view logs: docker-compose -f docker-compose.enterprise.yml logs -f [service_name]"
print_status "To stop all services: docker-compose -f docker-compose.enterprise.yml down"

echo
print_warning "Note: If you experience issues, wait a few more minutes for all services to fully initialize."
print_warning "You can check service logs with: docker-compose -f docker-compose.enterprise.yml logs [service_name]"