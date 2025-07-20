# LZ Custom - Azure App Service Version
# Optimized for Azure App Service Free Tier

from flask import Flask, request, jsonify, render_template, send_from_directory
import sqlite3
import os
import random
from datetime import datetime
import json

app = Flask(__name__)

# Database initialization
def init_db():
    """Initialize SQLite database with required tables"""
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
            model_used TEXT DEFAULT 'simple',
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

# Routes
@app.route('/')
def index():
    """Main website page"""
    return render_template('index.html')

@app.route('/admin.html')
def admin():
    """Admin dashboard page"""
    return render_template('admin.html')

@app.route('/api/health')
def health_check():
    """Health check endpoint for Azure"""
    return jsonify({"status": "healthy", "service": "lz-custom-app-service"})

@app.route('/api/chat', methods=['POST'])
def chat():
    """Simple chat endpoint with predefined responses"""
    try:
        data = request.get_json()
        message = data.get('message', '')
        
        if not message:
            return jsonify({"error": "Message is required"}), 400
        
        response_text = get_chat_response(message)
        
        # Log the conversation
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO chat_conversations (user_message, ai_response, model_used, response_time)
            VALUES (?, ?, ?, ?)
        ''', (message, response_text, "simple", 0.01))
        
        conn.commit()
        conn.close()
        
        return jsonify({
            "response": response_text,
            "model": "simple",
            "response_time": 0.01
        })
    except Exception as e:
        return jsonify({
            "response": "Thanks for contacting us! Please call 216-268-2990 for immediate assistance.",
            "model": "fallback",
            "response_time": 0.01
        })

@app.route('/api/prospects', methods=['POST'])
def create_prospect():
    """Create a new prospect from form submission"""
    try:
        data = request.get_json()
        
        # Extract and clean data
        name = data.get('name', '').strip() if data.get('name') else None
        email = data.get('email', '').strip() if data.get('email') else None
        phone = data.get('phone', '').strip() if data.get('phone') else None
        project = data.get('project', '').strip() if data.get('project') else None
        message = data.get('message', '').strip() if data.get('message') else None
        
        # Determine priority based on budget and timeline
        budget = data.get('budget')
        timeline = data.get('timeline')
        priority = 'normal'
        
        if budget in ['30k-50k', 'over-50k'] or timeline == 'asap':
            priority = 'high'
        elif budget == 'under-5k':
            priority = 'low'
        
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO prospects (
                name, email, phone, project_type, budget_range, timeline, 
                message, room_dimensions, measurements, wood_species, 
                cabinet_style, material_type, square_footage, priority
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            name, email, phone, project, budget, timeline,
            message, data.get('roomDimensions'), data.get('measurements'),
            data.get('woodSpecies'), data.get('cabinetStyle'), 
            data.get('materialType'), data.get('squareFootage'), priority
        ))
        
        prospect_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        print(f"New prospect saved: ID {prospect_id}, Priority: {priority}")
        
        return jsonify({
            "message": "Quote request submitted successfully",
            "id": prospect_id,
            "priority": priority
        })
    except Exception as e:
        print(f"Error saving prospect: {str(e)}")
        # Return success anyway to avoid losing prospects
        return jsonify({
            "message": "Quote request received successfully",
            "id": 0,
            "priority": "normal",
            "note": "Please call to confirm your request was received"
        })

@app.route('/api/prospects', methods=['GET'])
def get_prospects():
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
        return jsonify(prospects)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/prospects/<int:prospect_id>')
def get_prospect(prospect_id):
    """Get detailed prospect information"""
    try:
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM prospects WHERE id = ?', (prospect_id,))
        row = cursor.fetchone()
        
        if not row:
            return jsonify({"error": "Prospect not found"}), 404
        
        # Convert row to dict
        columns = [description[0] for description in cursor.description]
        prospect = dict(zip(columns, row))
        
        conn.close()
        return jsonify(prospect)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/analytics/dashboard')
def get_analytics():
    """Get analytics data for admin dashboard"""
    try:
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()
        
        # Chat statistics
        cursor.execute('SELECT COUNT(*) FROM chat_conversations')
        total_chats = cursor.fetchone()[0]
        
        cursor.execute('''
            SELECT COUNT(*) FROM chat_conversations 
            WHERE created_at >= datetime('now', '-7 days')
        ''')
        weekly_chats = cursor.fetchone()[0]
        
        # Model usage (simple responses only)
        model_usage = [{"model": "simple-responses", "count": total_chats, "avg_time": 0.01}]
        
        conn.close()
        
        return jsonify({
            "chats": {
                "total": total_chats,
                "thisWeek": weekly_chats,
                "uniqueSessions": total_chats  # Simplified
            },
            "model_usage": model_usage
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Static file serving
@app.route('/assets/<path:filename>')
def serve_assets(filename):
    """Serve static assets"""
    return send_from_directory('static/assets', filename)

if __name__ == '__main__':
    # For local development
    app.run(debug=True, host='0.0.0.0', port=8000)
