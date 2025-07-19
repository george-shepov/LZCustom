
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import sqlite3
import json
from datetime import datetime
import uvicorn
import asyncio
from llama_service import LLaMAService, QuestionClassifier

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
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            phone TEXT NOT NULL,
            project_type TEXT NOT NULL,
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
    
    conn.commit()
    conn.close()

class ProspectCreate(BaseModel):
    name: str
    email: str
    phone: str
    project: str
    budget: Optional[str] = None
    timeline: Optional[str] = None
    message: str
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

class ChatResponse(BaseModel):
    response: str
    model_used: str
    tier: str
    response_time: float
    success: bool
    error: Optional[str] = None

# Global LLaMA service instance
llama_service = None

@app.on_event("startup")
async def startup_event():
    global llama_service
    init_db()
    # Initialize LLaMA service
    try:
        llama_service = LLaMAService()
        await llama_service.__aenter__()
        print("✅ LLaMA service initialized successfully")
    except Exception as e:
        print(f"⚠️  LLaMA service initialization failed: {e}")
        llama_service = None

@app.on_event("shutdown")
async def shutdown_event():
    global llama_service
    if llama_service:
        await llama_service.__aexit__(None, None, None)

@app.post("/api/prospects")
async def create_prospect(prospect: ProspectCreate):
    try:
        conn = sqlite3.connect('lz_custom.db')
        cursor = conn.cursor()
        
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
            prospect.name,
            prospect.email, 
            prospect.phone,
            prospect.project,
            prospect.budget,
            prospect.timeline,
            prospect.message,
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
        
        return {
            "message": "Quote request submitted successfully",
            "id": prospect_id,
            "priority": priority
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

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
async def chat_with_ai(message: ChatMessage):
    """
    Chat with local LLaMA models with intelligent routing
    """
    global llama_service

    if not llama_service:
        return ChatResponse(
            response="AI assistant is currently unavailable. Please call us at 216-268-2990 for immediate assistance!",
            model_used="fallback",
            tier="FALLBACK",
            response_time=0,
            success=False,
            error="LLaMA service not initialized"
        )

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

        # Generate response
        result = await llama_service.generate_response(
            message.message,
            tier=force_tier
        )

        return ChatResponse(**result)

    except Exception as e:
        return ChatResponse(
            response="I'm experiencing technical difficulties. Please call 216-268-2990 for immediate assistance.",
            model_used="error",
            tier="ERROR",
            response_time=0,
            success=False,
            error=str(e)
        )

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

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

