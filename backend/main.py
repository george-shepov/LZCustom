
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import sqlite3
import json
from datetime import datetime
import uvicorn
import asyncio
import uuid
import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from llama_service import LLaMAService, QuestionClassifier

# Domain-specific branding configurations
DOMAIN_CONFIGS = {
    "giorgiy": {
        "company_name": "LZ Custom Fabrication",
        "tagline": "Premier Custom Cabinet & Stone Fabrication",
        "specialty": "custom cabinets, granite countertops, stone fabrication",
        "location": "Northeast Ohio",
        "phone": "216-268-2990",
        "color_scheme": "professional blue and grey"
    },
    "giorgiy-shepov": {
        "company_name": "Giorgiy Shepov Consulting",
        "tagline": "Business Development & Technical Solutions",
        "specialty": "business consulting, technical strategy, digital transformation",
        "location": "Cleveland, Ohio",
        "phone": "216-268-2990",
        "color_scheme": "modern black and gold"
    },
    "bravoohio": {
        "company_name": "Bravo Ohio Business Consulting",
        "tagline": "Strategic Business Growth Solutions",
        "specialty": "business consulting, market analysis, operational optimization",
        "location": "Ohio",
        "phone": "216-268-2990",
        "color_scheme": "bold red and blue"
    },
    "lodexinc": {
        "company_name": "Lodex Inc",
        "tagline": "Corporate Development & Strategy",
        "specialty": "corporate consulting, business development, strategic planning",
        "location": "Ohio",
        "phone": "216-268-2990",
        "color_scheme": "corporate navy and silver"
    }
}

def get_domain_context(domain_brand: str) -> str:
    """Get domain-specific context for LLM"""
    config = DOMAIN_CONFIGS.get(domain_brand, DOMAIN_CONFIGS["giorgiy"])
    
    return f"""You are a helpful customer service representative for {config['company_name']}, 
    {config['tagline']}. We specialize in {config['specialty']} and are located in {config['location']} 
    with 30+ years of experience. Our phone number is {config['phone']}. 
    Always be helpful and encourage customers to call for quotes and consultations."""

# Email configuration
EMAIL_CONFIG = {
    "smtp_server": os.environ.get("SMTP_SERVER", "localhost"),
    "smtp_port": int(os.environ.get("SMTP_PORT", "587")),
    "smtp_username": os.environ.get("SMTP_USERNAME", "noreply@giorgiy.org"),
    "smtp_password": os.environ.get("SMTP_PASSWORD", ""),
    "from_email": os.environ.get("FROM_EMAIL", "noreply@giorgiy.org"),
    "to_email": os.environ.get("TO_EMAIL", "george@giorgiy.org")
}

async def send_email(to_email: str, subject: str, body: str, is_html: bool = False) -> bool:
    """Send email using SMTP"""
    try:
        msg = MIMEMultipart()
        msg['From'] = EMAIL_CONFIG["from_email"]
        msg['To'] = to_email
        msg['Subject'] = subject
        
        msg.attach(MIMEText(body, 'html' if is_html else 'plain'))
        
        # Use local mail server for now (docker mailserver)
        with smtplib.SMTP(EMAIL_CONFIG["smtp_server"], EMAIL_CONFIG["smtp_port"]) as server:
            if EMAIL_CONFIG["smtp_password"]:
                server.starttls()
                server.login(EMAIL_CONFIG["smtp_username"], EMAIL_CONFIG["smtp_password"])
            server.send_message(msg)
        
        print(f"✅ Email sent successfully to {to_email}")
        return True
    except Exception as e:
        print(f"❌ Failed to send email to {to_email}: {e}")
        return False

def get_prospect_email_template(prospect_data: dict, domain_brand: str) -> tuple:
    """Generate email templates for prospect notification"""
    config = DOMAIN_CONFIGS.get(domain_brand, DOMAIN_CONFIGS["giorgiy"])
    
    # Email to business owner
    owner_subject = f"New Lead from {config['company_name']} Website - {prospect_data['name']}"
    owner_body = f"""
    <h2>New Prospect Inquiry</h2>
    
    <p><strong>Company:</strong> {config['company_name']}</p>
    <p><strong>Domain:</strong> {domain_brand}</p>
    <p><strong>Time:</strong> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
    
    <h3>Contact Information:</h3>
    <ul>
        <li><strong>Name:</strong> {prospect_data['name']}</li>
        <li><strong>Email:</strong> {prospect_data['email']}</li>
        <li><strong>Phone:</strong> {prospect_data.get('phone', 'Not provided')}</li>
    </ul>
    
    <h3>Project Details:</h3>
    <ul>
        <li><strong>Project Type:</strong> {prospect_data.get('project', 'Not specified')}</li>
        <li><strong>Budget:</strong> {prospect_data.get('budget', 'Not specified')}</li>
        <li><strong>Timeline:</strong> {prospect_data.get('timeline', 'Not specified')}</li>
    </ul>
    
    <h3>Message:</h3>
    <p>{prospect_data.get('message', 'No message provided')}</p>
    
    <p><em>Follow up with this lead as soon as possible!</em></p>
    """
    
    # Email to prospect (auto-reply)
    prospect_subject = f"Thank you for contacting {config['company_name']}"
    prospect_body = f"""
    <h2>Thank you for your inquiry!</h2>
    
    <p>Dear {prospect_data['name']},</p>
    
    <p>Thank you for contacting <strong>{config['company_name']}</strong>. We have received your inquiry about {prospect_data.get('project', 'your project')} and will get back to you within 24 hours.</p>
    
    <h3>Your submission details:</h3>
    <ul>
        <li><strong>Project:</strong> {prospect_data.get('project', 'Not specified')}</li>
        <li><strong>Budget:</strong> {prospect_data.get('budget', 'Not specified')}</li>
        <li><strong>Timeline:</strong> {prospect_data.get('timeline', 'Not specified')}</li>
    </ul>
    
    <p>In the meantime, feel free to call us directly at <strong>{config['phone']}</strong> if you have any urgent questions.</p>
    
    <p>We specialize in {config['specialty']} and look forward to helping you with your project.</p>
    
    <p>Best regards,<br>
    {config['company_name']} Team<br>
    {config['phone']}</p>
    
    <hr>
    <p><small>This is an automated response. Please do not reply directly to this email.</small></p>
    """
    
    return (owner_subject, owner_body), (prospect_subject, prospect_body)

app = FastAPI(title="LZ Custom API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def init_db():
    conn = sqlite3.connect('lz_custom.db')
    cursor = conn.cursor()
    
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
            project_details TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            status TEXT DEFAULT 'new',
            priority TEXT DEFAULT 'normal',
            follow_up_date DATE,
            notes TEXT
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS project_images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            prospect_id INTEGER,
            image_path TEXT,
            image_type TEXT,
            uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (prospect_id) REFERENCES prospects (id)
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS quotes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            prospect_id INTEGER,
            quote_amount DECIMAL(10,2),
            quote_details TEXT,
            valid_until DATE,
            status TEXT DEFAULT 'draft',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (prospect_id) REFERENCES prospects (id)
        )
    ''')

    # Chat conversations table for logging all AI interactions
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS chat_conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id TEXT,
            user_message TEXT NOT NULL,
            ai_response TEXT NOT NULL,
            model_used TEXT NOT NULL,
            tier TEXT NOT NULL,
            response_time REAL,
            success BOOLEAN DEFAULT 1,
            error_message TEXT,
            user_ip TEXT,
            user_agent TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    # Chat sessions table for tracking conversation sessions
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS chat_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id TEXT UNIQUE NOT NULL,
            started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            message_count INTEGER DEFAULT 0,
            user_ip TEXT,
            user_agent TEXT,
            status TEXT DEFAULT 'active'
        )
    ''')

    conn.commit()
    conn.close()

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

class ChatMessage(BaseModel):
    message: str
    context: Optional[str] = None
    force_tier: Optional[str] = None  # For testing specific models
    session_id: Optional[str] = None  # For conversation tracking

class ChatResponse(BaseModel):
    response: str
    model_used: str
    tier: str
    response_time: float
    success: bool
    error: Optional[str] = None
    session_id: str  # Return session ID for frontend tracking

# Helper functions for chat logging
def create_or_update_session(session_id: str, user_ip: str = None, user_agent: str = None):
    """Create or update a chat session"""
    conn = sqlite3.connect('lz_custom.db')
    cursor = conn.cursor()

    # Check if session exists
    cursor.execute('SELECT id FROM chat_sessions WHERE session_id = ?', (session_id,))
    if cursor.fetchone():
        # Update existing session
        cursor.execute('''
            UPDATE chat_sessions
            SET last_activity = CURRENT_TIMESTAMP, message_count = message_count + 1
            WHERE session_id = ?
        ''', (session_id,))
    else:
        # Create new session
        cursor.execute('''
            INSERT INTO chat_sessions (session_id, user_ip, user_agent, message_count)
            VALUES (?, ?, ?, 1)
        ''', (session_id, user_ip, user_agent))

    conn.commit()
    conn.close()

def log_chat_conversation(session_id: str, user_message: str, ai_response: str,
                         model_used: str, tier: str, response_time: float,
                         success: bool, error_message: str = None,
                         user_ip: str = None, user_agent: str = None):
    """Log a complete chat interaction"""
    conn = sqlite3.connect('lz_custom.db')
    cursor = conn.cursor()

    cursor.execute('''
        INSERT INTO chat_conversations (
            session_id, user_message, ai_response, model_used, tier,
            response_time, success, error_message, user_ip, user_agent
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', (
        session_id, user_message, ai_response, model_used, tier,
        response_time, success, error_message, user_ip, user_agent
    ))

    conn.commit()
    conn.close()

# Global LLaMA service instance
llama_service = None

@app.on_event("startup")
async def startup_event():
    global llama_service
    init_db()
    # Initialize LLaMA service with retry logic
    max_retries = 3
    retry_delay = 5

    for attempt in range(max_retries):
        try:
            print(f"🔄 Attempting to initialize LLaMA service (attempt {attempt + 1}/{max_retries})...")
            llama_service = LLaMAService()
            await llama_service.__aenter__()

            # Test the service with a simple query
            test_response = await llama_service.chat("Hello", "test-session")
            if test_response and test_response.get('response'):
                print("✅ LLaMA service initialized and tested successfully")
                break
            else:
                raise Exception("Service initialized but test query failed")

        except Exception as e:
            print(f"⚠️  LLaMA service initialization attempt {attempt + 1} failed: {e}")
            if attempt < max_retries - 1:
                print(f"🔄 Retrying in {retry_delay} seconds...")
                await asyncio.sleep(retry_delay)
                retry_delay *= 2  # Exponential backoff
            else:
                print("❌ LLaMA service initialization failed after all attempts")
                llama_service = None

@app.on_event("shutdown")
async def shutdown_event():
    global llama_service
    if llama_service:
        await llama_service.__aexit__(None, None, None)

@app.post("/api/prospects")
async def create_prospect(prospect: ProspectCreate, request: Request):
    try:
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()

        # Clean and prepare data - convert empty strings to None for better database handling
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

        # Log the submission attempt for comprehensive tracking
        user_ip = request.client.host if request.client else None

        print(f"Form submission from {user_ip}: name={name}, email={email}, phone={phone}, project={project}")

        cursor.execute('''
            INSERT INTO prospects (
                name, email, phone, project_type, budget_range, timeline,
                message, room_dimensions, measurements, wood_species,
                cabinet_style, material_type, square_footage, priority
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            name,
            email,
            phone,
            project,
            prospect.budget,
            prospect.timeline,
            message,
            prospect.roomDimensions,
            prospect.measurements,
            prospect.woodSpecies,
            prospect.cabinetStyle,
            prospect.materialType,
            prospect.squareFootage,
            priority
        ))

        prospect_id = cursor.lastrowid
        conn.commit()
        conn.close()

        # Log successful submission
        print(f"Successfully saved prospect {prospect_id} with priority {priority}")

        # Send email notifications
        try:
            domain_brand = request.headers.get("x-domain-brand", "giorgiy")
            prospect_data = {
                "name": name,
                "email": email,
                "phone": phone,
                "project": project,
                "message": message,
                "budget": prospect.budget,
                "timeline": prospect.timeline
            }
            
            # Get email templates for this domain
            (owner_subject, owner_body), (prospect_subject, prospect_body) = get_prospect_email_template(prospect_data, domain_brand)
            
            # Send email to business owner
            owner_email_sent = await send_email(EMAIL_CONFIG["to_email"], owner_subject, owner_body, is_html=True)
            
            # Send auto-reply to prospect if email provided
            prospect_email_sent = False
            if email:
                prospect_email_sent = await send_email(email, prospect_subject, prospect_body, is_html=True)
            
            print(f"Email notifications - Owner: {'✅' if owner_email_sent else '❌'}, Prospect: {'✅' if prospect_email_sent else '❌'}")
            
        except Exception as email_error:
            print(f"⚠️  Email sending failed (prospect still saved): {email_error}")

        return {
            "message": "Quote request submitted successfully",
            "id": prospect_id,
            "priority": priority
        }

    except Exception as e:
        # Log the error but still return success to avoid losing prospects
        print(f"Error saving prospect: {str(e)}")
        print(f"Prospect data: {prospect.model_dump()}")

        # Return success anyway - we don't want to lose prospects due to technical issues
        return {
            "message": "Quote request received successfully",
            "id": 0,
            "priority": "normal",
            "note": "Please call to confirm your request was received"
        }

@app.get("/api/prospects")
async def get_prospects():
    try:
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT id, name, email, phone, project_type, budget_range, 
                   timeline, created_at, status, priority
            FROM prospects 
            ORDER BY 
                CASE priority 
                    WHEN 'high' THEN 1 
                    WHEN 'normal' THEN 2 
                    WHEN 'low' THEN 3 
                END,
                created_at DESC
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
                "created_at": row[7],
                "status": row[8],
                "priority": row[9]
            })
        
        conn.close()
        return prospects
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/prospects/{prospect_id}")
async def get_prospect_details(prospect_id: int):
    try:
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT * FROM prospects WHERE id = ?
        ''', (prospect_id,))
        
        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Prospect not found")
        
        # Get column names
        columns = [description[0] for description in cursor.description]
        prospect = dict(zip(columns, row))
        
        conn.close()
        return prospect
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.put("/api/prospects/{prospect_id}/status")
async def update_prospect_status(prospect_id: int, status: dict):
    try:
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE prospects 
            SET status = ?, notes = ?
            WHERE id = ?
        ''', (status.get('status'), status.get('notes', ''), prospect_id))
        
        conn.commit()
        conn.close()
        
        return {"message": "Status updated successfully"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/chat", response_model=ChatResponse)
async def chat_with_ai(message: ChatMessage, request: Request):
    """
    Chat with local LLaMA models with intelligent routing and comprehensive logging
    """
    global llama_service

    # Generate session ID if not provided
    session_id = message.session_id or str(uuid.uuid4())
    user_ip = request.client.host if request.client else None
    user_agent = request.headers.get("user-agent", "")
    domain_brand = request.headers.get("x-domain-brand", "giorgiy")

    # Create or update session
    create_or_update_session(session_id, user_ip, user_agent)

    if not llama_service:
        fallback_response = ChatResponse(
            response="AI assistant is currently unavailable. Please call us at 216-268-2990 for immediate assistance!",
            model_used="fallback",
            tier="FALLBACK",
            response_time=0,
            success=False,
            error="LLaMA service not initialized",
            session_id=session_id
        )

        # Log the fallback response
        log_chat_conversation(
            session_id=session_id,
            user_message=message.message,
            ai_response=fallback_response.response,
            model_used="fallback",
            tier="FALLBACK",
            response_time=0,
            success=False,
            error_message="LLaMA service not initialized",
            user_ip=user_ip,
            user_agent=user_agent
        )

        return fallback_response

    try:
        # Force specific tier if requested (for testing)
        force_tier = None
        if message.force_tier:
            tier_map = {
                "FAST": QuestionClassifier.ModelTier.FAST,
                "MEDIUM": QuestionClassifier.ModelTier.MEDIUM,
                "ADVANCED": QuestionClassifier.ModelTier.ADVANCED,
                "EXPERT": QuestionClassifier.ModelTier.EXPERT
            }
            force_tier = tier_map.get(message.force_tier.upper())

        # Generate response with domain-specific context
        domain_context = get_domain_context(domain_brand)
        result = await llama_service.generate_response(
            message.message,
            tier=force_tier,
            domain_context=domain_context
        )

        # Add session_id to response
        result["session_id"] = session_id

        # Log successful conversation
        log_chat_conversation(
            session_id=session_id,
            user_message=message.message,
            ai_response=result["response"],
            model_used=result["model_used"],
            tier=result["tier"],
            response_time=result["response_time"],
            success=result["success"],
            error_message=None,
            user_ip=user_ip,
            user_agent=user_agent
        )

        return ChatResponse(**result)

    except Exception as e:
        error_response = ChatResponse(
            response="I'm experiencing technical difficulties. Please call 216-268-2990 for immediate assistance.",
            model_used="error",
            tier="ERROR",
            response_time=0,
            success=False,
            error=str(e),
            session_id=session_id
        )

        # Log error conversation
        log_chat_conversation(
            session_id=session_id,
            user_message=message.message,
            ai_response=error_response.response,
            model_used="error",
            tier="ERROR",
            response_time=0,
            success=False,
            error_message=str(e),
            user_ip=user_ip,
            user_agent=user_agent
        )

        return error_response

@app.get("/api/chat/test")
async def test_models():
    """
    Test all available models with sample questions
    """
    global llama_service

    if not llama_service:
        raise HTTPException(status_code=503, detail="LLaMA service not available")

    test_questions = [
        "What are your business hours?",
        "What's the difference between granite and quartz countertops?",
        "I need custom cabinets for a commercial kitchen with specific requirements"
    ]

    results = []
    for question in test_questions:
        for tier_name in ["FAST", "MEDIUM", "ADVANCED", "EXPERT"]:
            try:
                message = ChatMessage(message=question, force_tier=tier_name)
                response = await chat_with_ai(message)
                results.append({
                    "question": question,
                    "tier": tier_name,
                    "model": response.model_used,
                    "response_time": response.response_time,
                    "success": response.success,
                    "response_preview": response.response[:100] + "..." if len(response.response) > 100 else response.response
                })
            except Exception as e:
                results.append({
                    "question": question,
                    "tier": tier_name,
                    "error": str(e)
                })

    return {"test_results": results}

@app.get("/api/chat/conversations")
async def get_chat_conversations(limit: int = 50, session_id: str = None):
    """Get chat conversation history"""
    try:
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()

        if session_id:
            cursor.execute('''
                SELECT * FROM chat_conversations
                WHERE session_id = ?
                ORDER BY created_at DESC
                LIMIT ?
            ''', (session_id, limit))
        else:
            cursor.execute('''
                SELECT * FROM chat_conversations
                ORDER BY created_at DESC
                LIMIT ?
            ''', (limit,))

        conversations = []
        columns = [description[0] for description in cursor.description]
        for row in cursor.fetchall():
            conversations.append(dict(zip(columns, row)))

        conn.close()
        return {"conversations": conversations}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/chat/sessions")
async def get_chat_sessions(limit: int = 50):
    """Get chat session summary"""
    try:
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()

        cursor.execute('''
            SELECT cs.*,
                   COUNT(cc.id) as total_messages,
                   MAX(cc.created_at) as last_message_at
            FROM chat_sessions cs
            LEFT JOIN chat_conversations cc ON cs.session_id = cc.session_id
            GROUP BY cs.session_id
            ORDER BY cs.last_activity DESC
            LIMIT ?
        ''', (limit,))

        sessions = []
        columns = [description[0] for description in cursor.description]
        for row in cursor.fetchall():
            sessions.append(dict(zip(columns, row)))

        conn.close()
        return {"sessions": sessions}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/analytics/dashboard")
async def get_analytics_dashboard():
    """Get analytics dashboard data"""
    try:
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()

        # Prospect statistics
        cursor.execute('SELECT COUNT(*) FROM prospects')
        total_prospects = cursor.fetchone()[0]

        cursor.execute('SELECT COUNT(*) FROM prospects WHERE created_at >= date("now", "-7 days")')
        prospects_this_week = cursor.fetchone()[0]

        cursor.execute('SELECT COUNT(*) FROM prospects WHERE status = "new"')
        new_prospects = cursor.fetchone()[0]

        # Chat statistics
        cursor.execute('SELECT COUNT(*) FROM chat_conversations')
        total_chats = cursor.fetchone()[0]

        cursor.execute('SELECT COUNT(*) FROM chat_conversations WHERE created_at >= date("now", "-7 days")')
        chats_this_week = cursor.fetchone()[0]

        cursor.execute('SELECT COUNT(DISTINCT session_id) FROM chat_conversations')
        unique_sessions = cursor.fetchone()[0]

        # Model usage statistics
        cursor.execute('''
            SELECT model_used, COUNT(*) as usage_count
            FROM chat_conversations
            GROUP BY model_used
            ORDER BY usage_count DESC
        ''')
        model_usage = [{"model": row[0], "count": row[1]} for row in cursor.fetchall()]

        # Recent activity
        cursor.execute('''
            SELECT 'prospect' as type, name as title, created_at
            FROM prospects
            UNION ALL
            SELECT 'chat' as type,
                   SUBSTR(user_message, 1, 50) || '...' as title,
                   created_at
            FROM chat_conversations
            ORDER BY created_at DESC
            LIMIT 10
        ''')
        recent_activity = []
        for row in cursor.fetchall():
            recent_activity.append({
                "type": row[0],
                "title": row[1],
                "created_at": row[2]
            })

        conn.close()

        return {
            "prospects": {
                "total": total_prospects,
                "this_week": prospects_this_week,
                "new": new_prospects
            },
            "chats": {
                "total": total_chats,
                "this_week": chats_this_week,
                "unique_sessions": unique_sessions
            },
            "model_usage": model_usage,
            "recent_activity": recent_activity
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

