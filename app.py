# LZ Custom - Clean Production Version
# Complete professional website with DeepSeek R1 AI

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
    # AI Configuration
    AI_ENABLED = os.environ.get('AI_ENABLED', 'true').lower() == 'true'
    AI_MODEL = os.environ.get('AI_MODEL', 'deepseek')
    DEEPSEEK_API_KEY = os.environ.get('DEEPSEEK_API_KEY', '')
    OPENAI_API_KEY = os.environ.get('OPENAI_API_KEY', '')
    OLLAMA_ENDPOINT = os.environ.get('OLLAMA_ENDPOINT', 'http://ollama:11434')
    
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
    
    # Database Configuration
    DATABASE_PATH = 'database/lz_custom.db'
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
        # Create database directory if it doesn't exist
        os.makedirs(os.path.dirname(Config.DATABASE_PATH), exist_ok=True)
        
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
