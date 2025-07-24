# Enterprise FastAPI Backend with Multi-Database Support
# Separate endpoints for each domain: giorgiy.org, giorgiy-shepov.com, bravoohio.org, lodexinc.com

from fastapi import FastAPI, HTTPException, Request, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import uuid
import asyncio
import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime

# Import enterprise database components
from database_enterprise import (
    DatabaseManager, 
    ProspectsRepository, 
    ChatRepository, 
    SessionManager, 
    CacheManager
)
from llama_service import LLaMAService, QuestionClassifier

# Domain-specific branding configurations
DOMAIN_CONFIGS = {
    "giorgiy": {
        "company_name": "LZ Custom Fabrication",
        "tagline": "Premier Custom Cabinet & Stone Fabrication",
        "specialty": "custom cabinets, granite countertops, stone fabrication",
        "location": "Northeast Ohio",
        "phone": "216-268-2990",
        "color_scheme": "professional blue and grey",
        "email": "george@giorgiy.org"
    },
    "giorgiy-shepov": {
        "company_name": "Giorgiy Shepov Consulting",
        "tagline": "Business Development & Technical Solutions",
        "specialty": "business consulting, technical strategy, digital transformation",
        "location": "Cleveland, Ohio",
        "phone": "216-268-2990",
        "color_scheme": "modern black and gold",
        "email": "giorgiy@giorgiy-shepov.com"
    },
    "bravoohio": {
        "company_name": "Bravo Ohio Business Consulting",
        "tagline": "Strategic Business Growth Solutions",
        "specialty": "business consulting, market analysis, operational optimization",
        "location": "Ohio",
        "phone": "216-268-2990",
        "color_scheme": "bold red and blue",
        "email": "info@bravoohio.org"
    },
    "lodexinc": {
        "company_name": "Lodex Inc",
        "tagline": "Corporate Development & Strategy",
        "specialty": "corporate consulting, business development, strategic planning",
        "location": "Ohio",
        "phone": "216-268-2990",
        "color_scheme": "corporate navy and silver",
        "email": "contact@lodexinc.com"
    }
}

def get_domain_context(domain_brand: str) -> str:
    """Get domain-specific context for LLM"""
    config = DOMAIN_CONFIGS.get(domain_brand, DOMAIN_CONFIGS["giorgiy"])
    
    return f"""You are a helpful customer service representative for {config['company_name']}, 
    {config['tagline']}. We specialize in {config['specialty']} and are located in {config['location']} 
    with 30+ years of experience. Our phone number is {config['phone']}. 
    Always be helpful and encourage customers to call for quotes and consultations."""

def detect_domain_from_request(request: Request) -> str:
    """Detect domain brand from request headers or host"""
    # Try X-Domain-Brand header first (set by nginx)
    domain_brand = request.headers.get("x-domain-brand")
    if domain_brand:
        return domain_brand
    
    # Fallback to host detection
    host = request.headers.get("host", "").replace("www.", "")
    domain_mapping = {
        "giorgiy.org": "giorgiy",
        "giorgiy-shepov.com": "giorgiy-shepov",
        "bravoohio.org": "bravoohio", 
        "lodexinc.com": "lodexinc"
    }
    
    return domain_mapping.get(host, "giorgiy")

# Email configuration
EMAIL_CONFIG = {
    "smtp_server": os.environ.get("SMTP_SERVER", "mailserver"),
    "smtp_port": int(os.environ.get("SMTP_PORT", "587")),
    "smtp_username": os.environ.get("SMTP_USERNAME", "noreply@giorgiy.org"),
    "smtp_password": os.environ.get("SMTP_PASSWORD", ""),
    "from_email": os.environ.get("FROM_EMAIL", "noreply@giorgiy.org")
}

async def send_email(to_email: str, subject: str, body: str, is_html: bool = False) -> bool:
    """Send email using SMTP"""
    try:
        msg = MIMEMultipart()
        msg['From'] = EMAIL_CONFIG["from_email"]
        msg['To'] = to_email
        msg['Subject'] = subject
        
        msg.attach(MIMEText(body, 'html' if is_html else 'plain'))
        
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

# Initialize FastAPI app
app = FastAPI(title="LZCustom Enterprise API", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global instances
db_manager = DatabaseManager()
prospects_repo = None
chat_repo = None
session_manager = None
cache_manager = None
llama_service = None

@app.on_event("startup")
async def startup_event():
    global prospects_repo, chat_repo, session_manager, cache_manager, llama_service
    
    try:
        # Initialize database connections
        await db_manager.initialize()
        
        # Initialize repositories
        prospects_repo = ProspectsRepository(db_manager)
        chat_repo = ChatRepository(db_manager)
        session_manager = SessionManager(db_manager)
        cache_manager = CacheManager(db_manager)
        
        # Initialize LLaMA service
        llama_service = LLaMAService()
        await llama_service.__aenter__()
        
        print("✅ Enterprise backend initialized successfully")
        
    except Exception as e:
        print(f"❌ Failed to initialize enterprise backend: {e}")
        raise

@app.on_event("shutdown")
async def shutdown_event():
    global llama_service
    if llama_service:
        await llama_service.__aexit__(None, None, None)
    await db_manager.close()

# Pydantic models
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
    force_tier: Optional[str] = None
    session_id: Optional[str] = None

class ChatResponse(BaseModel):
    response: str
    model_used: str
    tier: str
    response_time: float
    success: bool
    error: Optional[str] = None
    session_id: str

# DOMAIN-SPECIFIC ENDPOINTS

# LZ Custom Fabrication (giorgiy.org) - Cabinet & Stone Fabrication
@app.post("/api/lz-custom/prospects", tags=["LZ Custom"])
async def create_lz_custom_prospect(prospect: ProspectCreate, request: Request):
    """Create prospect for LZ Custom Fabrication"""
    return await create_prospect_for_domain(prospect, request, "giorgiy")

@app.get("/api/lz-custom/prospects", tags=["LZ Custom"])
async def get_lz_custom_prospects():
    """Get prospects for LZ Custom Fabrication"""
    return await get_prospects_for_domain("giorgiy")

@app.post("/api/lz-custom/chat", response_model=ChatResponse, tags=["LZ Custom"])
async def chat_lz_custom(message: ChatMessage, request: Request):
    """Chat with LZ Custom AI assistant"""
    return await chat_for_domain(message, request, "giorgiy")

# Giorgiy Shepov Consulting (giorgiy-shepov.com) - Business Consulting  
@app.post("/api/gs-consulting/prospects", tags=["GS Consulting"])
async def create_gs_consulting_prospect(prospect: ProspectCreate, request: Request):
    """Create prospect for Giorgiy Shepov Consulting"""
    return await create_prospect_for_domain(prospect, request, "giorgiy-shepov")

@app.get("/api/gs-consulting/prospects", tags=["GS Consulting"])
async def get_gs_consulting_prospects():
    """Get prospects for Giorgiy Shepov Consulting"""
    return await get_prospects_for_domain("giorgiy-shepov")

@app.post("/api/gs-consulting/chat", response_model=ChatResponse, tags=["GS Consulting"])
async def chat_gs_consulting(message: ChatMessage, request: Request):
    """Chat with GS Consulting AI assistant"""
    return await chat_for_domain(message, request, "giorgiy-shepov")

# Bravo Ohio (bravoohio.org) - Business Growth Solutions
@app.post("/api/bravo-ohio/prospects", tags=["Bravo Ohio"])
async def create_bravo_ohio_prospect(prospect: ProspectCreate, request: Request):
    """Create prospect for Bravo Ohio"""
    return await create_prospect_for_domain(prospect, request, "bravoohio")

@app.get("/api/bravo-ohio/prospects", tags=["Bravo Ohio"]) 
async def get_bravo_ohio_prospects():
    """Get prospects for Bravo Ohio"""
    return await get_prospects_for_domain("bravoohio")

@app.post("/api/bravo-ohio/chat", response_model=ChatResponse, tags=["Bravo Ohio"])
async def chat_bravo_ohio(message: ChatMessage, request: Request):
    """Chat with Bravo Ohio AI assistant"""
    return await chat_for_domain(message, request, "bravoohio")

# Lodex Inc (lodexinc.com) - Corporate Development
@app.post("/api/lodex-inc/prospects", tags=["Lodex Inc"])
async def create_lodex_inc_prospect(prospect: ProspectCreate, request: Request):
    """Create prospect for Lodex Inc"""
    return await create_prospect_for_domain(prospect, request, "lodexinc")

@app.get("/api/lodex-inc/prospects", tags=["Lodex Inc"])
async def get_lodex_inc_prospects():
    """Get prospects for Lodex Inc"""
    return await get_prospects_for_domain("lodexinc")

@app.post("/api/lodex-inc/chat", response_model=ChatResponse, tags=["Lodex Inc"])
async def chat_lodex_inc(message: ChatMessage, request: Request):
    """Chat with Lodex Inc AI assistant"""
    return await chat_for_domain(message, request, "lodexinc")

# LEGACY UNIFIED ENDPOINTS (for backward compatibility)
@app.post("/api/prospects")
async def create_prospect_legacy(prospect: ProspectCreate, request: Request):
    """Legacy unified prospects endpoint - detects domain automatically"""
    domain_brand = detect_domain_from_request(request)
    return await create_prospect_for_domain(prospect, request, domain_brand)

@app.post("/api/chat", response_model=ChatResponse)
async def chat_legacy(message: ChatMessage, request: Request):
    """Legacy unified chat endpoint - detects domain automatically"""
    domain_brand = detect_domain_from_request(request)
    return await chat_for_domain(message, request, domain_brand)

# SHARED IMPLEMENTATION FUNCTIONS
async def create_prospect_for_domain(prospect: ProspectCreate, request: Request, domain_brand: str):
    """Create prospect for specific domain"""
    try:
        # Prepare prospect data
        prospect_data = {
            'name': prospect.name.strip() if prospect.name else None,
            'email': prospect.email.strip() if prospect.email else None,
            'phone': prospect.phone.strip() if prospect.phone else None,
            'project_type': prospect.project.strip() if prospect.project else None,
            'budget_range': prospect.budget,
            'timeline': prospect.timeline,
            'message': prospect.message.strip() if prospect.message else None,
            'room_dimensions': prospect.roomDimensions,
            'measurements': prospect.measurements,
            'wood_species': prospect.woodSpecies,
            'cabinet_style': prospect.cabinetStyle,
            'material_type': prospect.materialType,
            'square_footage': prospect.squareFootage,
            'priority': 'high' if prospect.budget in ['30k-50k', 'over-50k'] or prospect.timeline == 'asap' else 'normal'
        }
        
        # Save to domain-specific PostgreSQL schema
        prospect_id = await prospects_repo.create_prospect(prospect_data, domain_brand)
        
        # Send email notifications
        try:
            config = DOMAIN_CONFIGS.get(domain_brand, DOMAIN_CONFIGS["giorgiy"])
            
            email_data = {
                "name": prospect_data['name'],
                "email": prospect_data['email'],
                "phone": prospect_data['phone'],
                "project": prospect_data['project_type'],
                "message": prospect_data['message'],
                "budget": prospect.budget,
                "timeline": prospect.timeline
            }
            
            (owner_subject, owner_body), (prospect_subject, prospect_body) = get_prospect_email_template(email_data, domain_brand)
            
            # Send to business owner
            await send_email(config["email"], owner_subject, owner_body, is_html=True)
            
            # Send auto-reply to prospect
            if prospect_data['email']:
                await send_email(prospect_data['email'], prospect_subject, prospect_body, is_html=True)
                
        except Exception as email_error:
            print(f"⚠️  Email sending failed: {email_error}")
        
        return {
            "message": "Quote request submitted successfully",
            "id": prospect_id,
            "domain": domain_brand,
            "priority": prospect_data['priority']
        }
        
    except Exception as e:
        print(f"Error creating prospect for {domain_brand}: {e}")
        return {
            "message": "Quote request received successfully",
            "id": "0",
            "domain": domain_brand,
            "priority": "normal",
            "note": "Please call to confirm your request was received"
        }

async def get_prospects_for_domain(domain_brand: str):
    """Get prospects for specific domain"""
    try:
        # Try cache first
        cache_key = f"prospects:{domain_brand}"
        cached_prospects = await cache_manager.get(cache_key)
        
        if cached_prospects:
            return {"prospects": cached_prospects, "cached": True}
        
        # Fetch from database
        prospects = await prospects_repo.get_prospects(domain_brand)
        
        # Cache for 5 minutes
        await cache_manager.set(cache_key, prospects, ttl=300)
        
        return {"prospects": prospects, "cached": False}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch prospects: {str(e)}")

async def chat_for_domain(message: ChatMessage, request: Request, domain_brand: str):
    """Chat implementation for specific domain"""
    global llama_service
    
    # Generate session ID if not provided
    session_id = message.session_id or str(uuid.uuid4())
    user_ip = request.client.host if request.client else None
    user_agent = request.headers.get("user-agent", "")
    
    # Create or update session in Redis
    await session_manager.create_session(session_id, domain_brand, {
        "user_ip": user_ip,
        "user_agent": user_agent
    })
    
    if not llama_service:
        fallback_response = ChatResponse(
            response=f"AI assistant is currently unavailable. Please call us at {DOMAIN_CONFIGS[domain_brand]['phone']} for immediate assistance!",
            model_used="fallback",
            tier="FALLBACK",
            response_time=0,
            success=False,
            error="LLaMA service not initialized",
            session_id=session_id
        )
        
        await chat_repo.log_conversation({
            "session_id": session_id,
            "user_message": message.message,
            "ai_response": fallback_response.response,
            "model_used": "fallback",
            "tier": "FALLBACK",
            "response_time": 0,
            "success": False,
            "error_message": "LLaMA service not initialized",
            "user_ip": user_ip,
            "user_agent": user_agent
        }, domain_brand)
        
        return fallback_response
    
    try:
        # Force specific tier if requested
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
        
        result["session_id"] = session_id
        
        # Increment message count in session
        await session_manager.increment_message_count(session_id)
        
        # Log conversation to domain-specific schema
        await chat_repo.log_conversation({
            "session_id": session_id,
            "user_message": message.message,
            "ai_response": result["response"],
            "model_used": result["model_used"],
            "tier": result["tier"],
            "response_time": result["response_time"],
            "success": result["success"],
            "error_message": None,
            "user_ip": user_ip,
            "user_agent": user_agent
        }, domain_brand)
        
        return ChatResponse(**result)
        
    except Exception as e:
        error_response = ChatResponse(
            response=f"I'm experiencing technical difficulties. Please call {DOMAIN_CONFIGS[domain_brand]['phone']} for immediate assistance.",
            model_used="error",
            tier="ERROR",
            response_time=0,
            success=False,
            error=str(e),
            session_id=session_id
        )
        
        await chat_repo.log_conversation({
            "session_id": session_id,
            "user_message": message.message,
            "ai_response": error_response.response,
            "model_used": "error",
            "tier": "ERROR",
            "response_time": 0,
            "success": False,
            "error_message": str(e),
            "user_ip": user_ip,
            "user_agent": user_agent
        }, domain_brand)
        
        return error_response

# ANALYTICS AND MONITORING ENDPOINTS
@app.get("/api/analytics/overview", tags=["Analytics"])
async def get_analytics_overview():
    """Get cross-domain analytics overview"""
    try:
        analytics = {}
        
        for domain_brand in DOMAIN_CONFIGS.keys():
            # Get prospect count
            prospects = await prospects_repo.get_prospects(domain_brand, limit=1000)
            
            # Get recent chat activity
            conversations = await chat_repo.get_conversations(domain_brand, limit=100)
            
            analytics[domain_brand] = {
                "prospects_count": len(prospects),
                "conversations_count": len(conversations),
                "config": DOMAIN_CONFIGS[domain_brand]
            }
        
        return {"analytics": analytics, "generated_at": datetime.now()}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/health", tags=["System"])
async def health_check():
    """System health check for all databases"""
    health = {
        "status": "healthy",
        "databases": {},
        "timestamp": datetime.now()
    }
    
    # Check PostgreSQL
    try:
        async with db_manager.get_postgres_connection() as conn:
            await conn.fetchval("SELECT 1")
        health["databases"]["postgresql"] = "healthy"
    except Exception as e:
        health["databases"]["postgresql"] = f"error: {str(e)}"
        health["status"] = "degraded"
    
    # Check Redis
    try:
        await db_manager.get_redis().ping()
        health["databases"]["redis"] = "healthy"
    except Exception as e:
        health["databases"]["redis"] = f"error: {str(e)}"
        health["status"] = "degraded"
    
    # Check MongoDB
    try:
        await db_manager.get_mongodb().admin.command('ping')
        health["databases"]["mongodb"] = "healthy"
    except Exception as e:
        health["databases"]["mongodb"] = f"error: {str(e)}"
        health["status"] = "degraded"
    
    # Check Qdrant
    try:
        await db_manager.get_qdrant().get_collections()
        health["databases"]["qdrant"] = "healthy"
    except Exception as e:
        health["databases"]["qdrant"] = f"error: {str(e)}"
        health["status"] = "degraded"
    
    return health

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)