#!/bin/bash

# Fix Backend - Create minimal main.py without AI dependencies
# This fixes the aiohttp and llama_service import errors

echo "🔧 Fixing Backend Dependencies"
echo "==============================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# Navigate to backend directory
if [ -d "/home/shepov/LZCustom/backend" ]; then
    cd /home/shepov/LZCustom/backend
elif [ -d "LZCustom/backend" ]; then
    cd LZCustom/backend
elif [ -d "backend" ]; then
    cd backend
else
    print_error "Backend directory not found!"
    exit 1
fi

print_status "Current directory: $(pwd)"

# Stop the failing service
print_status "Stopping failing backend service..."
sudo systemctl stop lzcustom-backend

# Backup the original main.py
if [ -f main.py ]; then
    print_status "Backing up original main.py..."
    cp main.py main.py.original
fi

# Create a minimal main.py without AI dependencies
print_status "Creating minimal main.py without AI dependencies..."

cat > main.py << 'EOF'
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import sqlite3
import random
from datetime import datetime

app = FastAPI(title="LZ Custom API", version="1.0.0")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models
class ChatMessage(BaseModel):
    message: str

class ProspectCreate(BaseModel):
    name: Optional[str] = ""
    email: Optional[str] = ""
    phone: Optional[str] = ""
    project: Optional[str] = ""
    budget: Optional[str] = None
    timeline: Optional[str] = None
    message: Optional[str] = ""
    roomDimensions: Optional[str] = None
    measurements: Optional[str] = None
    woodSpecies: Optional[str] = None
    cabinetStyle: Optional[str] = None
    materialType: Optional[str] = None
    squareFootage: Optional[int] = None

# Initialize database
def init_db():
    conn = sqlite3.connect('lz_custom.db')
    cursor = conn.cursor()
    
    # Create prospects table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS prospects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            phone TEXT,
            project_type TEXT,
            budget_range TEXT,
            timeline TEXT,
            message TEXT,
            room_dimensions TEXT,
            measurements TEXT,
            wood_species TEXT,
            cabinet_style TEXT,
            material_type TEXT,
            square_footage INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            status TEXT DEFAULT 'new',
            priority TEXT DEFAULT 'normal',
            notes TEXT
        )
    ''')
    
    # Create chat conversations table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS chat_conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_message TEXT NOT NULL,
            ai_response TEXT NOT NULL,
            model_used TEXT DEFAULT 'emergency',
            response_time REAL DEFAULT 0.01,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    conn.commit()
    conn.close()

# Initialize database on startup
init_db()

# Simple chat responses (no AI needed)
CHAT_RESPONSES = {
    "greeting": [
        "Hello! Welcome to LZ Custom. How can we help with your fabrication project?",
        "Hi! We specialize in custom cabinets, countertops, and stone work. What can we do for you?",
        "Welcome to LZ Custom! We're here to help with your custom fabrication needs."
    ],
    "services": [
        "We offer custom cabinets, granite/quartz countertops, stone fabrication, and commercial painting.",
        "Our services include kitchen cabinets, bathroom vanities, countertops, and tile work.",
        "We specialize in custom millwork, stone fabrication, and high-quality finishes for residential and commercial projects."
    ],
    "contact": [
        "Call us at 216-268-2990. We serve Northeast Ohio within a 30-mile radius.",
        "Phone: 216-268-2990. Hours: Mon-Fri 8AM-5PM, Sat 9AM-3PM.",
        "Reach us at 216-268-2990 or use our quote form for detailed project information."
    ],
    "default": [
        "Great question! Call 216-268-2990 for detailed project information.",
        "For specific details about your project, please call 216-268-2990 or fill out our quote form.",
        "Our team can provide detailed answers at 216-268-2990. We'd love to discuss your project!"
    ]
}

def get_chat_response(message):
    """Get appropriate response based on message content"""
    msg = message.lower()
    
    if any(word in msg for word in ['hello', 'hi', 'hey', 'good morning', 'good afternoon']):
        return random.choice(CHAT_RESPONSES["greeting"])
    elif any(word in msg for word in ['service', 'what do you do', 'cabinet', 'counter', 'stone', 'paint']):
        return random.choice(CHAT_RESPONSES["services"])
    elif any(word in msg for word in ['contact', 'phone', 'call', 'hours', 'reach', 'location']):
        return random.choice(CHAT_RESPONSES["contact"])
    else:
        return random.choice(CHAT_RESPONSES["default"])

# API Routes
@app.get("/")
async def root():
    return {"message": "LZ Custom API is running", "status": "healthy"}

@app.get("/api/health")
async def health_check():
    return {"status": "healthy", "service": "lz-custom-api"}

@app.post("/api/chat")
async def chat(message: ChatMessage):
    """Simple chat endpoint with predefined responses"""
    try:
        response_text = get_chat_response(message.message)
        
        # Log the conversation
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO chat_conversations (user_message, ai_response, model_used, response_time)
            VALUES (?, ?, ?, ?)
        ''', (message.message, response_text, "emergency", 0.01))
        
        conn.commit()
        conn.close()
        
        return {
            "response": response_text,
            "model": "emergency",
            "response_time": 0.01
        }
    except Exception as e:
        return {
            "response": "Thanks for contacting us! Please call 216-268-2990 for immediate assistance.",
            "model": "fallback",
            "response_time": 0.01
        }

@app.post("/api/prospects")
async def create_prospect(prospect: ProspectCreate):
    """Create a new prospect from form submission"""
    try:
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()
        
        # Clean and prepare data
        name = prospect.name.strip() if prospect.name else None
        email = prospect.email.strip() if prospect.email else None
        phone = prospect.phone.strip() if prospect.phone else None
        project = prospect.project.strip() if prospect.project else None
        message = prospect.message.strip() if prospect.message else None
        
        # Determine priority based on budget and timeline
        priority = 'normal'
        if prospect.budget in ['30k-50k', 'over-50k'] or prospect.timeline == 'asap':
            priority = 'high'
        elif prospect.budget == 'under-5k':
            priority = 'low'
        
        cursor.execute('''
            INSERT INTO prospects (
                name, email, phone, project_type, budget_range, timeline, 
                message, room_dimensions, measurements, wood_species, 
                cabinet_style, material_type, square_footage, priority
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            name, email, phone, project, prospect.budget, prospect.timeline,
            message, prospect.roomDimensions, prospect.measurements,
            prospect.woodSpecies, prospect.cabinetStyle, prospect.materialType,
            prospect.squareFootage, priority
        ))
        
        prospect_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        print(f"New prospect saved: ID {prospect_id}, Priority: {priority}")
        
        return {
            "message": "Quote request submitted successfully",
            "id": prospect_id,
            "priority": priority
        }
    except Exception as e:
        print(f"Error saving prospect: {str(e)}")
        # Return success anyway to avoid losing prospects
        return {
            "message": "Quote request received successfully",
            "id": 0,
            "priority": "normal",
            "note": "Please call to confirm your request was received"
        }

@app.get("/api/prospects")
async def get_prospects():
    """Get all prospects for admin dashboard"""
    try:
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT id, name, email, phone, project_type, budget_range, timeline,
                   message, created_at, status, priority
            FROM prospects 
            ORDER BY created_at DESC
        ''')
        
        prospects = []
        for row in cursor.fetchall():
            prospects.append({
                "id": row[0],
                "name": row[1],
                "email": row[2],
                "phone": row[3],
                "project_type": row[4],
                "budget_range": row[5],
                "timeline": row[6],
                "message": row[7],
                "created_at": row[8],
                "status": row[9],
                "priority": row[10]
            })
        
        conn.close()
        return prospects
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/prospects/{prospect_id}")
async def get_prospect(prospect_id: int):
    """Get detailed prospect information"""
    try:
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT * FROM prospects WHERE id = ?
        ''', (prospect_id,))
        
        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Prospect not found")
        
        # Convert row to dict (simplified)
        prospect = {
            "id": row[0],
            "name": row[1],
            "email": row[2],
            "phone": row[3],
            "project_type": row[4],
            "budget_range": row[5],
            "timeline": row[6],
            "message": row[7],
            "room_dimensions": row[8],
            "measurements": row[9],
            "wood_species": row[10],
            "cabinet_style": row[11],
            "material_type": row[12],
            "square_footage": row[13],
            "created_at": row[14],
            "status": row[15],
            "priority": row[16],
            "notes": row[18] if len(row) > 18 else None
        }
        
        conn.close()
        return prospect
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

print_success "Created minimal main.py without AI dependencies"

# Create emergency chat module (standalone)
cat > emergency_chat.py << 'EOF'
# Emergency chat system - no external dependencies
import random

RESPONSES = {
    "greeting": [
        "Hello! Welcome to LZ Custom. How can we help with your fabrication project?",
        "Hi! We specialize in custom cabinets, countertops, and stone work. What can we do for you?",
        "Welcome to LZ Custom! We're here to help with your custom fabrication needs."
    ],
    "services": [
        "We offer custom cabinets, granite/quartz countertops, stone fabrication, and commercial painting.",
        "Our services include kitchen cabinets, bathroom vanities, countertops, and tile work.",
        "We specialize in custom millwork, stone fabrication, and high-quality finishes for residential and commercial projects."
    ],
    "contact": [
        "Call us at 216-268-2990. We serve Northeast Ohio within a 30-mile radius.",
        "Phone: 216-268-2990. Hours: Mon-Fri 8AM-5PM, Sat 9AM-3PM.",
        "Reach us at 216-268-2990 or use our quote form for detailed project information."
    ],
    "default": [
        "Great question! Call 216-268-2990 for detailed project information.",
        "For specific details about your project, please call 216-268-2990 or fill out our quote form.",
        "Our team can provide detailed answers at 216-268-2990. We'd love to discuss your project!"
    ]
}

def get_response(message):
    """Get appropriate response based on message content"""
    msg = message.lower()
    
    if any(word in msg for word in ['hello', 'hi', 'hey', 'good morning', 'good afternoon']):
        return random.choice(RESPONSES["greeting"])
    elif any(word in msg for word in ['service', 'what do you do', 'cabinet', 'counter', 'stone', 'paint']):
        return random.choice(RESPONSES["services"])
    elif any(word in msg for word in ['contact', 'phone', 'call', 'hours', 'reach', 'location']):
        return random.choice(RESPONSES["contact"])
    else:
        return random.choice(RESPONSES["default"])
EOF

print_success "Created emergency chat module"

# Restart the backend service
print_status "Restarting backend service..."
sudo systemctl start lzcustom-backend

# Wait a moment and check status
sleep 3

if sudo systemctl is-active --quiet lzcustom-backend; then
    print_success "✅ Backend service is now running!"
    
    # Test the API
    print_status "Testing API endpoints..."
    
    if curl -s http://localhost:8000/ > /dev/null; then
        print_success "✅ API is responding"
    else
        print_warning "⚠️ API might still be starting up"
    fi
    
    # Show service status
    echo ""
    echo "📊 Service Status:"
    sudo systemctl is-active lzcustom-backend && echo "✅ Backend: Running" || echo "❌ Backend: Stopped"
    sudo systemctl is-active lzcustom-frontend && echo "✅ Frontend: Running" || echo "❌ Frontend: Stopped"
    sudo systemctl is-active nginx && echo "✅ Nginx: Running" || echo "❌ Nginx: Stopped"
    
    echo ""
    echo "🌐 Your website should now be accessible:"
    PUBLIC_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "localhost")
    echo "   • Website: http://$PUBLIC_IP"
    echo "   • Admin Dashboard: http://$PUBLIC_IP/admin.html"
    echo "   • API Health: http://$PUBLIC_IP:8000/api/health"
    
    print_success "Backend fix completed successfully! 🔧"
    
else
    print_error "❌ Backend service failed to start"
    echo ""
    echo "Check the logs for more details:"
    echo "sudo journalctl -u lzcustom-backend -f"
    echo ""
    echo "Recent logs:"
    sudo journalctl -u lzcustom-backend --no-pager -n 10
fi
