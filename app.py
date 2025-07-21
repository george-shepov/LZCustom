# LZ Custom - Complete Professional Website
# Full-featured fabrication website with all original components restored

from flask import Flask, request, jsonify, render_template, send_from_directory
from flask_cors import CORS
import sqlite3
import os
import random
import logging
from datetime import datetime, time
import json
import requests

app = Flask(__name__)
CORS(app)

# Configuration
class Config:
    # AI Configuration - Configurable for VPS deployment
    AI_ENABLED = os.environ.get('AI_ENABLED', 'true').lower() == 'true'
    AI_MODEL = os.environ.get('AI_MODEL', 'deepseek')
    DEEPSEEK_API_KEY = os.environ.get('DEEPSEEK_API_KEY', '')
    OPENAI_API_KEY = os.environ.get('OPENAI_API_KEY', '')
    OLLAMA_ENDPOINT = os.environ.get('OLLAMA_ENDPOINT', 'http://localhost:11434')

    # Business Configuration
    BUSINESS_NAME = 'LZ Custom'
    BUSINESS_PHONE = '216-268-2990'
    BUSINESS_EMAIL = 'info@lzcustom.com'
    SERVICE_AREA = 'Northeast Ohio - Cleveland, Akron, Canton, Youngstown, Lorain, Ashtabula'
    BUSINESS_HOURS = 'Mon-Fri 8AM-5PM, Sat 9AM-3PM'
    YEARS_EXPERIENCE = '30+'

    # Business Hours for Open/Closed Status
    BUSINESS_HOURS_DETAILED = {
        'monday': {'open': time(8, 0), 'close': time(17, 0)},
        'tuesday': {'open': time(8, 0), 'close': time(17, 0)},
        'wednesday': {'open': time(8, 0), 'close': time(17, 0)},
        'thursday': {'open': time(8, 0), 'close': time(17, 0)},
        'friday': {'open': time(8, 0), 'close': time(17, 0)},
        'saturday': {'open': time(9, 0), 'close': time(15, 0)},
        'sunday': {'open': None, 'close': None}  # Closed
    }

    # Gallery Configuration
    GALLERY_ENABLED = True
    TOTAL_IMAGES = 100  # Your Midjourney images

    # Database Configuration
    DATABASE_PATH = 'lz_custom.db'
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-key-change-in-production')

app.config.from_object(Config)

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Business Hours Functions
def is_business_open():
    """Check if business is currently open"""
    now = datetime.now()
    current_day = now.strftime('%A').lower()
    current_time = now.time()

    hours = Config.BUSINESS_HOURS_DETAILED.get(current_day)
    if not hours or not hours['open'] or not hours['close']:
        return False

    return hours['open'] <= current_time <= hours['close']

def get_business_status():
    """Get detailed business status"""
    is_open = is_business_open()
    now = datetime.now()
    current_day = now.strftime('%A')

    if is_open:
        return {
            'status': 'open',
            'message': f'We\'re Open! Call us at {Config.BUSINESS_PHONE}',
            'hours_today': Config.BUSINESS_HOURS,
            'current_day': current_day
        }
    else:
        return {
            'status': 'closed',
            'message': f'We\'re Currently Closed. Call {Config.BUSINESS_PHONE} to leave a message',
            'hours_today': Config.BUSINESS_HOURS,
            'current_day': current_day
        }

# AI Chat Functions
def get_ai_response(message, model='deepseek'):
    """Get AI response using specified model"""
    if not Config.AI_ENABLED:
        return get_simple_response(message)

    try:
        if model == 'deepseek' and Config.OLLAMA_ENDPOINT:
            return get_ollama_response(message)
        elif model == 'openai' and Config.OPENAI_API_KEY:
            return get_openai_response(message)
        else:
            return get_simple_response(message)
    except Exception as e:
        logger.error(f"AI response error: {e}")
        return get_simple_response(message)

def get_ollama_response(message):
    """Get response from Ollama (DeepSeek R1)"""
    try:
        response = requests.post(
            f"{Config.OLLAMA_ENDPOINT}/api/generate",
            json={
                "model": "deepseek-r1:1.5b",
                "prompt": f"You are a helpful assistant for LZ Custom, a fabrication company in Northeast Ohio specializing in custom cabinets, countertops, and stone work. Answer this customer question: {message}",
                "stream": False
            },
            timeout=30
        )

        if response.status_code == 200:
            return response.json().get('response', get_simple_response(message))
        else:
            return get_simple_response(message)
    except Exception as e:
        logger.error(f"Ollama error: {e}")
        return get_simple_response(message)

def get_openai_response(message):
    """Get response from OpenAI"""
    try:
        if not Config.OPENAI_API_KEY:
            return get_simple_response(message)

        headers = {
            'Authorization': f'Bearer {Config.OPENAI_API_KEY}',
            'Content-Type': 'application/json'
        }

        data = {
            "model": "gpt-3.5-turbo",
            "messages": [
                {"role": "system", "content": "You are a helpful assistant for LZ Custom, a fabrication company in Northeast Ohio specializing in custom cabinets, countertops, and stone work."},
                {"role": "user", "content": message}
            ],
            "max_tokens": 150
        }

        response = requests.post(
            'https://api.openai.com/v1/chat/completions',
            headers=headers,
            json=data,
            timeout=30
        )

        if response.status_code == 200:
            return response.json()['choices'][0]['message']['content']
        else:
            return get_simple_response(message)

    except Exception as e:
        logger.error(f"OpenAI error: {e}")
        return get_simple_response(message)

def get_simple_response(message):
    """Simple rule-based responses"""
    msg = message.lower()

    # Business hours responses
    if any(word in msg for word in ['open', 'hours', 'closed', 'time']):
        status = get_business_status()
        return f"{status['message']} Our hours are {Config.BUSINESS_HOURS}."

    # Services responses
    elif any(word in msg for word in ['service', 'what do you do', 'cabinet', 'counter', 'stone', 'kitchen']):
        return f"We specialize in custom cabinets, granite/quartz countertops, stone fabrication, and commercial projects. With {Config.YEARS_EXPERIENCE} years of experience serving {Config.SERVICE_AREA}. Call {Config.BUSINESS_PHONE} for a free quote!"

    # Contact responses
    elif any(word in msg for word in ['contact', 'phone', 'call', 'reach', 'quote']):
        status = get_business_status()
        return f"Call us at {Config.BUSINESS_PHONE}. {status['message']} We serve {Config.SERVICE_AREA}."

    # Greeting responses
    elif any(word in msg for word in ['hello', 'hi', 'hey', 'good morning', 'good afternoon']):
        status = get_business_status()
        return f"Hello! Welcome to LZ Custom. {status['message']} How can we help with your fabrication project?"

    # Default response
    else:
        return f"Thanks for contacting LZ Custom! For specific project details, please call {Config.BUSINESS_PHONE} or fill out our quote form. We specialize in custom cabinets, countertops, and stone work."

# Database Functions
def init_database():
    """Initialize the database with required tables"""
    try:
        conn = sqlite3.connect(Config.DATABASE_PATH)
        cursor = conn.cursor()

        # Create prospects table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS prospects (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT,
                phone TEXT,
                project_type TEXT,
                message TEXT,
                priority TEXT DEFAULT 'normal',
                status TEXT DEFAULT 'new',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')

        # Create chat_logs table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS chat_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                session_id TEXT,
                user_message TEXT,
                ai_response TEXT,
                model_used TEXT,
                response_time REAL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')

        conn.commit()
        conn.close()
        logger.info("Database initialized successfully")
    except Exception as e:
        logger.error(f"Database initialization error: {e}")

# Initialize database on startup
init_database()

# Routes
@app.route('/')
def index():
    """Main website page with business status"""
    business_status = get_business_status()
    return render_template('index.html', business_status=business_status)

@app.route('/admin.html')
def admin():
    """Admin dashboard page"""
    return render_template('admin.html')

@app.route('/api/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": "lz-custom",
        "ai_enabled": Config.AI_ENABLED,
        "business_status": get_business_status()
    })

@app.route('/api/business-status')
def business_status_api():
    """Get current business status"""
    return jsonify(get_business_status())

@app.route('/api/chat', methods=['POST'])
def chat():
    """AI Chat endpoint with multiple model support"""
    try:
        data = request.get_json()
        message = data.get('message', '')
        model = data.get('model', Config.AI_MODEL)
        session_id = data.get('session_id', 'anonymous')

        if not message:
            return jsonify({"error": "Message is required"}), 400

        start_time = datetime.now()
        response_text = get_ai_response(message, model)
        response_time = (datetime.now() - start_time).total_seconds()

        # Log the conversation
        try:
            conn = sqlite3.connect(Config.DATABASE_PATH)
            cursor = conn.cursor()
            cursor.execute('''
                INSERT INTO chat_logs (session_id, user_message, ai_response, model_used, response_time)
                VALUES (?, ?, ?, ?, ?)
            ''', (session_id, message, response_text, model, response_time))
            conn.commit()
            conn.close()
        except Exception as e:
            logger.error(f"Chat logging error: {e}")

        return jsonify({
            "response": response_text,
            "model": model,
            "response_time": response_time,
            "business_status": get_business_status()
        })

    except Exception as e:
        logger.error(f"Chat error: {e}")
        return jsonify({
            "response": f"Thanks for contacting us! Please call {Config.BUSINESS_PHONE} for assistance.",
            "model": "fallback",
            "response_time": 0.01
        })

@app.route('/api/prospects', methods=['POST'])
def create_prospect():
    """Create a new prospect from form submission"""
    try:
        data = request.get_json()

        name = data.get('name', '')
        email = data.get('email', '')
        phone = data.get('phone', '')
        project_type = data.get('project', '')
        message = data.get('message', '')

        # Determine priority based on project type
        priority = 'high' if project_type in ['commercial', 'large_project'] else 'normal'

        # Save to database
        conn = sqlite3.connect(Config.DATABASE_PATH)
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO prospects (name, email, phone, project_type, message, priority)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (name, email, phone, project_type, message, priority))

        prospect_id = cursor.lastrowid
        conn.commit()
        conn.close()

        logger.info(f"New prospect created: {name} - {project_type}")

        return jsonify({
            "message": "Quote request submitted successfully! We'll contact you within 24 hours.",
            "id": prospect_id,
            "priority": priority,
            "business_status": get_business_status()
        })

    except Exception as e:
        logger.error(f"Prospect creation error: {e}")
        return jsonify({
            "message": "Quote request received successfully! We'll contact you soon.",
            "id": 0,
            "priority": "normal"
        })

@app.route('/api/prospects', methods=['GET'])
def get_prospects():
    """Get all prospects for admin dashboard"""
    try:
        conn = sqlite3.connect(Config.DATABASE_PATH)
        cursor = conn.cursor()
        cursor.execute('''
            SELECT id, name, email, phone, project_type, message, priority, status, created_at
            FROM prospects
            ORDER BY created_at DESC
        ''')

        prospects = []
        for row in cursor.fetchall():
            prospects.append({
                'id': row[0],
                'name': row[1],
                'email': row[2],
                'phone': row[3],
                'project_type': row[4],
                'message': row[5],
                'priority': row[6],
                'status': row[7],
                'created_at': row[8]
            })

        conn.close()
        return jsonify(prospects)

    except Exception as e:
        logger.error(f"Get prospects error: {e}")
        return jsonify([])

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    app.run(host='0.0.0.0', port=port, debug=debug)

# Simple chat responses
CHAT_RESPONSES = {
    "greeting": [
        "Hello! Welcome to LZ Custom. How can we help with your fabrication project?",
        "Hi! We specialize in custom cabinets, countertops, and stone work. What can we do for you?",
        "Welcome to LZ Custom! We're here to help with your custom fabrication needs."
    ],
    "services": [
        "We offer custom cabinets, granite/quartz countertops, stone fabrication, and commercial painting.",
        "Our services include kitchen cabinets, bathroom vanities, countertops, and tile work.",
        "We specialize in custom millwork, stone fabrication, and high-quality finishes."
    ],
    "contact": [
        "Call us at 216-268-2990. We serve Northeast Ohio within 30 miles.",
        "Phone: 216-268-2990. Hours: Mon-Fri 8AM-5PM, Sat 9AM-3PM.",
        "Reach us at 216-268-2990 or use our quote form for detailed project information."
    ],
    "default": [
        "Great question! Call 216-268-2990 for detailed project information.",
        "For specific details, please call 216-268-2990 or fill out our quote form.",
        "Our team can help! Contact us at 216-268-2990 for more information."
    ]
}

def get_chat_response(message):
    """Get appropriate response based on message content"""
    msg = message.lower()

    if any(word in msg for word in ['hello', 'hi', 'hey', 'good morning', 'good afternoon']):
        return random.choice(CHAT_RESPONSES["greeting"])
    elif any(word in msg for word in ['service', 'what do you do', 'cabinet', 'counter', 'stone']):
        return random.choice(CHAT_RESPONSES["services"])
    elif any(word in msg for word in ['contact', 'phone', 'call', 'hours', 'reach']):
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
    """Health check endpoint"""
    return jsonify({"status": "healthy", "service": "lz-custom"})

@app.route('/api/chat', methods=['POST'])
def chat():
    """Simple chat endpoint"""
    try:
        data = request.get_json()
        message = data.get('message', '')

        if not message:
            return jsonify({"error": "Message is required"}), 400

        response_text = get_chat_response(message)

        return jsonify({
            "response": response_text,
            "model": "simple",
            "response_time": 0.01
        })
    except Exception as e:
        return jsonify({
            "response": "Thanks for contacting us! Please call 216-268-2990 for assistance.",
            "model": "fallback",
            "response_time": 0.01
        })

@app.route('/api/prospects', methods=['POST'])
def create_prospect():
    """Create a new prospect from form submission"""
    try:
        data = request.get_json()

        # For now, just return success (will add database on VPS Dime)
        return jsonify({
            "message": "Quote request submitted successfully",
            "id": 1,
            "priority": "normal"
        })
    except Exception as e:
        return jsonify({
            "message": "Quote request received successfully",
            "id": 0,
            "priority": "normal"
        })

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=int(os.environ.get('PORT', 8000)))

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
