# LZ Custom - VPS Dime Deployment with Full AI Features
# Complete professional website with configurable AI capabilities

from flask import Flask, request, jsonify, render_template, send_from_directory
import sqlite3
import os
import random
import json
import logging
import asyncio
import aiohttp
from datetime import datetime
from typing import Optional, Dict, Any

app = Flask(__name__)

# Configuration Class
class Config:
    # AI Configuration - Configurable via environment variables
    AI_ENABLED = os.environ.get('AI_ENABLED', 'false').lower() == 'true'
    AI_MODEL = os.environ.get('AI_MODEL', 'simple')  # 'simple', 'openai', 'azure', 'ollama', 'claude'
    
    # OpenAI Configuration
    OPENAI_API_KEY = os.environ.get('OPENAI_API_KEY', '')
    OPENAI_MODEL = os.environ.get('OPENAI_MODEL', 'gpt-3.5-turbo')
    OPENAI_MAX_TOKENS = int(os.environ.get('OPENAI_MAX_TOKENS', '150'))
    
    # Azure OpenAI Configuration
    AZURE_OPENAI_ENDPOINT = os.environ.get('AZURE_OPENAI_ENDPOINT', '')
    AZURE_OPENAI_KEY = os.environ.get('AZURE_OPENAI_KEY', '')
    AZURE_OPENAI_DEPLOYMENT = os.environ.get('AZURE_OPENAI_DEPLOYMENT', '')
    AZURE_OPENAI_VERSION = os.environ.get('AZURE_OPENAI_VERSION', '2023-12-01-preview')
    
    # Ollama Configuration (Local AI)
    OLLAMA_ENDPOINT = os.environ.get('OLLAMA_ENDPOINT', 'http://localhost:11434')
    OLLAMA_MODEL = os.environ.get('OLLAMA_MODEL', 'llama2')
    
    # Claude Configuration
    CLAUDE_API_KEY = os.environ.get('CLAUDE_API_KEY', '')
    CLAUDE_MODEL = os.environ.get('CLAUDE_MODEL', 'claude-3-haiku-20240307')
    
    # Business Configuration
    BUSINESS_NAME = os.environ.get('BUSINESS_NAME', 'LZ Custom')
    BUSINESS_PHONE = os.environ.get('BUSINESS_PHONE', '216-268-2990')
    BUSINESS_EMAIL = os.environ.get('BUSINESS_EMAIL', 'info@lzcustom.com')
    SERVICE_AREA = os.environ.get('SERVICE_AREA', 'Northeast Ohio within 30 miles')
    BUSINESS_HOURS = os.environ.get('BUSINESS_HOURS', 'Mon-Fri 8AM-5PM, Sat 9AM-3PM')
    
    # Database Configuration
    DATABASE_PATH = os.environ.get('DATABASE_PATH', 'lz_custom.db')
    
    # Security Configuration
    SECRET_KEY = os.environ.get('SECRET_KEY', 'your-secret-key-change-this')
    ADMIN_USERNAME = os.environ.get('ADMIN_USERNAME', 'admin')
    ADMIN_PASSWORD = os.environ.get('ADMIN_PASSWORD', 'admin123')

app.config.from_object(Config)

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# AI Service Classes
class SimpleAI:
    """Simple predefined responses - no external dependencies"""
    
    RESPONSES = {
        "greeting": [
            f"Hello! Welcome to {Config.BUSINESS_NAME}. How can we help with your fabrication project?",
            f"Hi! We specialize in custom cabinets, countertops, and stone work. What can we do for you?",
            f"Welcome to {Config.BUSINESS_NAME}! We're here to help with your custom fabrication needs."
        ],
        "services": [
            "We offer custom cabinets, granite/quartz countertops, stone fabrication, and commercial painting.",
            "Our services include kitchen cabinets, bathroom vanities, countertops, and tile work.",
            "We specialize in custom millwork, stone fabrication, and high-quality finishes for residential and commercial projects."
        ],
        "contact": [
            f"Call us at {Config.BUSINESS_PHONE}. We serve {Config.SERVICE_AREA}.",
            f"Phone: {Config.BUSINESS_PHONE}. Hours: {Config.BUSINESS_HOURS}.",
            f"Reach us at {Config.BUSINESS_PHONE} or use our quote form for detailed project information."
        ],
        "pricing": [
            f"For accurate pricing, please call {Config.BUSINESS_PHONE} or fill out our quote form with project details.",
            "Pricing varies by project scope and materials. We provide free estimates for all custom work.",
            f"Contact us at {Config.BUSINESS_PHONE} for a personalized quote based on your specific needs."
        ],
        "timeline": [
            "Project timelines vary based on scope and complexity. We'll provide an estimated timeline with your quote.",
            "Most cabinet projects take 2-4 weeks, countertops 1-2 weeks. We'll give you specific timelines during consultation.",
            f"Call {Config.BUSINESS_PHONE} to discuss your project timeline and scheduling."
        ],
        "default": [
            f"Great question! Call {Config.BUSINESS_PHONE} for detailed project information.",
            f"For specific details about your project, please call {Config.BUSINESS_PHONE} or fill out our quote form.",
            f"Our team can provide detailed answers at {Config.BUSINESS_PHONE}. We'd love to discuss your project!"
        ]
    }
    
    def get_response(self, message: str) -> str:
        """Get appropriate response based on message content"""
        msg = message.lower()
        
        if any(word in msg for word in ['hello', 'hi', 'hey', 'good morning', 'good afternoon']):
            return random.choice(self.RESPONSES["greeting"])
        elif any(word in msg for word in ['service', 'what do you do', 'cabinet', 'counter', 'stone', 'paint']):
            return random.choice(self.RESPONSES["services"])
        elif any(word in msg for word in ['contact', 'phone', 'call', 'hours', 'reach', 'location']):
            return random.choice(self.RESPONSES["contact"])
        elif any(word in msg for word in ['price', 'cost', 'how much', 'estimate', 'quote']):
            return random.choice(self.RESPONSES["pricing"])
        elif any(word in msg for word in ['time', 'how long', 'when', 'schedule', 'timeline']):
            return random.choice(self.RESPONSES["timeline"])
        else:
            return random.choice(self.RESPONSES["default"])

class OpenAIService:
    """OpenAI GPT integration"""
    
    def __init__(self):
        self.api_key = Config.OPENAI_API_KEY
        self.model = Config.OPENAI_MODEL
        self.max_tokens = Config.OPENAI_MAX_TOKENS
        
        self.system_prompt = f"""You are a helpful assistant for {Config.BUSINESS_NAME}, a professional fabrication company specializing in:
- Custom kitchen and bathroom cabinets
- Granite, quartz, and marble countertops
- Professional tile installation
- Commercial painting services

Business details:
- Phone: {Config.BUSINESS_PHONE}
- Service area: {Config.SERVICE_AREA}
- Hours: {Config.BUSINESS_HOURS}

Guidelines:
- Be professional and helpful
- Always mention the phone number for detailed quotes
- Keep responses concise (under 100 words)
- Focus on our fabrication services
- Encourage customers to call for specific pricing and timelines
"""
    
    async def get_response(self, message: str) -> str:
        """Get AI response from OpenAI"""
        if not self.api_key:
            return "AI service not configured. Please call us at " + Config.BUSINESS_PHONE
        
        try:
            async with aiohttp.ClientSession() as session:
                headers = {
                    'Authorization': f'Bearer {self.api_key}',
                    'Content-Type': 'application/json'
                }
                
                data = {
                    'model': self.model,
                    'messages': [
                        {'role': 'system', 'content': self.system_prompt},
                        {'role': 'user', 'content': message}
                    ],
                    'max_tokens': self.max_tokens,
                    'temperature': 0.7
                }
                
                async with session.post(
                    'https://api.openai.com/v1/chat/completions',
                    headers=headers,
                    json=data
                ) as response:
                    if response.status == 200:
                        result = await response.json()
                        return result['choices'][0]['message']['content'].strip()
                    else:
                        logger.error(f"OpenAI API error: {response.status}")
                        return f"I'm having trouble right now. Please call us at {Config.BUSINESS_PHONE} for immediate assistance!"
                        
        except Exception as e:
            logger.error(f"OpenAI error: {str(e)}")
            return f"Thanks for your message! Please call us at {Config.BUSINESS_PHONE} for assistance."

class OllamaService:
    """Local Ollama AI integration"""
    
    def __init__(self):
        self.endpoint = Config.OLLAMA_ENDPOINT
        self.model = Config.OLLAMA_MODEL
        
        self.system_prompt = f"""You are a helpful assistant for {Config.BUSINESS_NAME}, a professional fabrication company. 
We specialize in custom cabinets, countertops, stone work, and commercial painting.
Phone: {Config.BUSINESS_PHONE}. Service area: {Config.SERVICE_AREA}.
Keep responses helpful, professional, and under 100 words. Always mention our phone number for quotes."""
    
    async def get_response(self, message: str) -> str:
        """Get AI response from local Ollama"""
        try:
            async with aiohttp.ClientSession() as session:
                data = {
                    'model': self.model,
                    'prompt': f"{self.system_prompt}\n\nCustomer: {message}\nAssistant:",
                    'stream': False
                }
                
                async with session.post(
                    f'{self.endpoint}/api/generate',
                    json=data
                ) as response:
                    if response.status == 200:
                        result = await response.json()
                        return result['response'].strip()
                    else:
                        logger.error(f"Ollama API error: {response.status}")
                        return f"Please call us at {Config.BUSINESS_PHONE} for assistance!"
                        
        except Exception as e:
            logger.error(f"Ollama error: {str(e)}")
            return f"Thanks for your message! Please call us at {Config.BUSINESS_PHONE} for assistance."

# AI Service Factory
class AIService:
    """AI service factory and manager"""
    
    def __init__(self):
        self.simple_ai = SimpleAI()
        self.openai_service = OpenAIService() if Config.OPENAI_API_KEY else None
        self.ollama_service = OllamaService()
    
    async def get_response(self, message: str) -> Dict[str, Any]:
        """Get AI response based on configuration"""
        start_time = datetime.now()
        
        try:
            if not Config.AI_ENABLED or Config.AI_MODEL == 'simple':
                response = self.simple_ai.get_response(message)
                model_used = 'simple'
            elif Config.AI_MODEL == 'openai' and self.openai_service:
                response = await self.openai_service.get_response(message)
                model_used = f'openai-{Config.OPENAI_MODEL}'
            elif Config.AI_MODEL == 'ollama':
                response = await self.ollama_service.get_response(message)
                model_used = f'ollama-{Config.OLLAMA_MODEL}'
            else:
                # Fallback to simple responses
                response = self.simple_ai.get_response(message)
                model_used = 'simple-fallback'
            
            response_time = (datetime.now() - start_time).total_seconds()
            
            return {
                'response': response,
                'model': model_used,
                'response_time': response_time
            }
            
        except Exception as e:
            logger.error(f"AI service error: {str(e)}")
            response_time = (datetime.now() - start_time).total_seconds()
            
            return {
                'response': f"Thanks for contacting us! Please call {Config.BUSINESS_PHONE} for immediate assistance.",
                'model': 'error-fallback',
                'response_time': response_time
            }

# Initialize AI service
ai_service = AIService()

# Database initialization
def init_db():
    """Initialize SQLite database with all required tables"""
    conn = sqlite3.connect(Config.DATABASE_PATH)
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
            notes TEXT,
            source TEXT DEFAULT 'website',
            follow_up_date DATE,
            estimated_value DECIMAL(10,2)
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
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            session_id TEXT,
            user_ip TEXT,
            user_agent TEXT
        )
    ''')

    # Create analytics table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS analytics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_type TEXT NOT NULL,
            event_data TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            user_ip TEXT,
            user_agent TEXT
        )
    ''')

    # Create admin users table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS admin_users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            email TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_login TIMESTAMP,
            is_active BOOLEAN DEFAULT 1
        )
    ''')

    conn.commit()
    conn.close()
    logger.info("Database initialized successfully")

# Initialize database on startup
init_db()

# Enable CORS
from flask_cors import CORS
CORS(app)

# Routes
@app.route('/')
def index():
    """Main website page"""
    return render_template('index.html', config=Config)

@app.route('/admin.html')
def admin():
    """Admin dashboard page"""
    return render_template('admin.html', config=Config)

@app.route('/api/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": "lz-custom-vps-dime",
        "ai_enabled": Config.AI_ENABLED,
        "ai_model": Config.AI_MODEL,
        "timestamp": datetime.now().isoformat()
    })

@app.route('/api/config')
def get_config():
    """Get public configuration"""
    return jsonify({
        "business_name": Config.BUSINESS_NAME,
        "business_phone": Config.BUSINESS_PHONE,
        "service_area": Config.SERVICE_AREA,
        "business_hours": Config.BUSINESS_HOURS,
        "ai_enabled": Config.AI_ENABLED,
        "ai_model": Config.AI_MODEL if Config.AI_ENABLED else "simple"
    })

@app.route('/api/chat', methods=['POST'])
async def chat():
    """AI-powered chat endpoint"""
    try:
        data = request.get_json()
        message = data.get('message', '').strip()

        if not message:
            return jsonify({"error": "Message is required"}), 400

        # Get AI response
        ai_response = await ai_service.get_response(message)

        # Log the conversation
        try:
            conn = sqlite3.connect(Config.DATABASE_PATH)
            cursor = conn.cursor()

            cursor.execute('''
                INSERT INTO chat_conversations (
                    user_message, ai_response, model_used, response_time,
                    session_id, user_ip, user_agent
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (
                message,
                ai_response['response'],
                ai_response['model'],
                ai_response['response_time'],
                request.headers.get('X-Session-ID', ''),
                request.remote_addr,
                request.headers.get('User-Agent', '')
            ))

            conn.commit()
            conn.close()
        except Exception as e:
            logger.error(f"Error logging chat: {str(e)}")

        return jsonify(ai_response)

    except Exception as e:
        logger.error(f"Chat error: {str(e)}")
        return jsonify({
            "response": f"Thanks for contacting us! Please call {Config.BUSINESS_PHONE} for immediate assistance.",
            "model": "error-fallback",
            "response_time": 0.01
        })
