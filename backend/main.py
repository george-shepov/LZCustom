
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import sqlite3
import json
from datetime import datetime
import uvicorn

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

@app.on_event("startup")
async def startup_event():
    init_db()

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

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

