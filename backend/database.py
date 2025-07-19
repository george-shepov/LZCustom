"""
Database configuration and models for LZ Custom Fabrication
Supports both SQLite (development) and PostgreSQL (production)
"""

import os
import asyncio
import asyncpg
import redis.asyncio as redis
from typing import Optional, Dict, Any, List
from datetime import datetime, date
import json
import uuid
from dataclasses import dataclass
from enum import Enum

class DatabaseTier(Enum):
    TIER1 = "basic"      # SQLite only
    TIER2 = "standard"   # PostgreSQL
    TIER3 = "enhanced"   # PostgreSQL + Redis
    TIER4 = "professional" # PostgreSQL + Redis + Analytics
    TIER5 = "enterprise" # Full stack + Monitoring

@dataclass
class DatabaseConfig:
    tier: DatabaseTier
    postgres_url: Optional[str] = None
    redis_url: Optional[str] = None
    enable_analytics: bool = False
    enable_monitoring: bool = False

class DatabaseManager:
    def __init__(self, config: DatabaseConfig):
        self.config = config
        self.postgres_pool = None
        self.redis_client = None
        
    async def initialize(self):
        """Initialize database connections based on tier"""
        if self.config.tier in [DatabaseTier.TIER2, DatabaseTier.TIER3, DatabaseTier.TIER4, DatabaseTier.TIER5]:
            await self._init_postgres()
            
        if self.config.tier in [DatabaseTier.TIER3, DatabaseTier.TIER4, DatabaseTier.TIER5]:
            await self._init_redis()
            
        await self._create_tables()
    
    async def _init_postgres(self):
        """Initialize PostgreSQL connection pool"""
        self.postgres_pool = await asyncpg.create_pool(
            self.config.postgres_url,
            min_size=2,
            max_size=10,
            command_timeout=60
        )
    
    async def _init_redis(self):
        """Initialize Redis connection"""
        self.redis_client = redis.from_url(
            self.config.redis_url,
            decode_responses=True,
            retry_on_timeout=True
        )
    
    async def _create_tables(self):
        """Create database tables based on tier"""
        if self.config.tier == DatabaseTier.TIER1:
            await self._create_sqlite_tables()
        else:
            await self._create_postgres_tables()
    
    async def _create_postgres_tables(self):
        """Create PostgreSQL tables"""
        async with self.postgres_pool.acquire() as conn:
            # Prospects table
            await conn.execute('''
                CREATE TABLE IF NOT EXISTS prospects (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(255),
                    email VARCHAR(255),
                    phone VARCHAR(50),
                    project_type VARCHAR(100),
                    budget_range VARCHAR(50),
                    timeline VARCHAR(100),
                    message TEXT,
                    room_dimensions VARCHAR(255),
                    measurements TEXT,
                    wood_species VARCHAR(100),
                    cabinet_style VARCHAR(100),
                    material_type VARCHAR(100),
                    square_footage INTEGER,
                    project_details TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    status VARCHAR(50) DEFAULT 'new',
                    priority VARCHAR(50) DEFAULT 'normal',
                    follow_up_date DATE,
                    notes TEXT,
                    vps_tier VARCHAR(20),
                    source VARCHAR(100)
                )
            ''')
            
            # Chat conversations with VPS tier tracking
            await conn.execute('''
                CREATE TABLE IF NOT EXISTS chat_conversations (
                    id SERIAL PRIMARY KEY,
                    session_id UUID,
                    user_message TEXT NOT NULL,
                    ai_response TEXT NOT NULL,
                    model_used VARCHAR(100) NOT NULL,
                    tier VARCHAR(20) NOT NULL,
                    vps_tier VARCHAR(20),
                    response_time REAL,
                    success BOOLEAN DEFAULT true,
                    error_message TEXT,
                    user_ip INET,
                    user_agent TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    upgrade_prompted BOOLEAN DEFAULT false
                )
            ''')
            
            # Chat sessions
            await conn.execute('''
                CREATE TABLE IF NOT EXISTS chat_sessions (
                    id SERIAL PRIMARY KEY,
                    session_id UUID UNIQUE NOT NULL,
                    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    message_count INTEGER DEFAULT 0,
                    user_ip INET,
                    user_agent TEXT,
                    vps_tier VARCHAR(20),
                    converted_to_quote BOOLEAN DEFAULT false
                )
            ''')
            
            # VPS tier usage analytics (Tier 4+)
            if self.config.tier in [DatabaseTier.TIER4, DatabaseTier.TIER5]:
                await conn.execute('''
                    CREATE TABLE IF NOT EXISTS vps_analytics (
                        id SERIAL PRIMARY KEY,
                        date DATE DEFAULT CURRENT_DATE,
                        vps_tier VARCHAR(20),
                        chat_requests INTEGER DEFAULT 0,
                        quote_submissions INTEGER DEFAULT 0,
                        avg_response_time REAL,
                        upgrade_prompts INTEGER DEFAULT 0,
                        successful_upgrades INTEGER DEFAULT 0,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                ''')
            
            # Create indexes for performance
            await conn.execute('CREATE INDEX IF NOT EXISTS idx_prospects_created_at ON prospects(created_at)')
            await conn.execute('CREATE INDEX IF NOT EXISTS idx_chat_session_id ON chat_conversations(session_id)')
            await conn.execute('CREATE INDEX IF NOT EXISTS idx_chat_created_at ON chat_conversations(created_at)')
            
    async def _create_sqlite_tables(self):
        """Fallback SQLite tables for Tier 1"""
        import sqlite3
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
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                vps_tier TEXT DEFAULT 'tier1'
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS upgrade_prompts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                session_id TEXT,
                current_tier TEXT,
                target_tier TEXT,
                prompt_shown TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                action_taken TEXT
            )
        ''')
        
        conn.commit()
        conn.close()

    async def save_prospect(self, prospect_data: Dict[str, Any]) -> int:
        """Save prospect data with VPS tier tracking"""
        if self.config.tier == DatabaseTier.TIER1:
            return await self._save_prospect_sqlite(prospect_data)
        else:
            return await self._save_prospect_postgres(prospect_data)
    
    async def _save_prospect_postgres(self, data: Dict[str, Any]) -> int:
        async with self.postgres_pool.acquire() as conn:
            return await conn.fetchval('''
                INSERT INTO prospects 
                (name, email, phone, project_type, budget_range, timeline, message, vps_tier)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                RETURNING id
            ''', data.get('name'), data.get('email'), data.get('phone'), 
                data.get('project_type'), data.get('budget_range'), 
                data.get('timeline'), data.get('message'), 
                data.get('vps_tier', 'unknown'))
    
    async def save_chat_conversation(self, conversation_data: Dict[str, Any]) -> int:
        """Save chat conversation with tier and performance tracking"""
        if self.config.tier == DatabaseTier.TIER1:
            return 0  # Skip for basic tier
        
        async with self.postgres_pool.acquire() as conn:
            return await conn.fetchval('''
                INSERT INTO chat_conversations 
                (session_id, user_message, ai_response, model_used, tier, vps_tier, 
                 response_time, success, user_ip, upgrade_prompted)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
                RETURNING id
            ''', conversation_data.get('session_id'), conversation_data.get('user_message'),
                conversation_data.get('ai_response'), conversation_data.get('model_used'),
                conversation_data.get('tier'), conversation_data.get('vps_tier'),
                conversation_data.get('response_time'), conversation_data.get('success'),
                conversation_data.get('user_ip'), conversation_data.get('upgrade_prompted', False))
    
    async def cache_session(self, session_id: str, data: Dict[str, Any], ttl: int = 3600):
        """Cache session data in Redis (Tier 3+)"""
        if self.redis_client:
            await self.redis_client.setex(
                f"session:{session_id}", 
                ttl, 
                json.dumps(data, default=str)
            )
    
    async def get_session(self, session_id: str) -> Optional[Dict[str, Any]]:
        """Get session data from Redis cache"""
        if self.redis_client:
            data = await self.redis_client.get(f"session:{session_id}")
            return json.loads(data) if data else None
        return None
    
    async def record_upgrade_prompt(self, session_id: str, current_tier: str, target_tier: str):
        """Record when upgrade prompt is shown"""
        if self.config.tier in [DatabaseTier.TIER4, DatabaseTier.TIER5]:
            async with self.postgres_pool.acquire() as conn:
                await conn.execute('''
                    UPDATE chat_conversations 
                    SET upgrade_prompted = true 
                    WHERE session_id = $1 AND created_at = (
                        SELECT MAX(created_at) FROM chat_conversations WHERE session_id = $1
                    )
                ''', uuid.UUID(session_id))
    
    async def get_tier_analytics(self) -> Dict[str, Any]:
        """Get VPS tier usage analytics (Tier 4+)"""
        if self.config.tier not in [DatabaseTier.TIER4, DatabaseTier.TIER5]:
            return {"error": "Analytics not available in this tier"}
        
        async with self.postgres_pool.acquire() as conn:
            stats = await conn.fetchrow('''
                SELECT 
                    COUNT(*) as total_chats,
                    COUNT(DISTINCT session_id) as unique_sessions,
                    AVG(response_time) as avg_response_time,
                    COUNT(*) FILTER (WHERE upgrade_prompted = true) as upgrade_prompts
                FROM chat_conversations 
                WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
            ''')
            
            return dict(stats) if stats else {}

def get_database_config() -> DatabaseConfig:
    """Get database configuration based on environment"""
    vps_tier = os.getenv('VPS_TIER', 'tier1')
    
    tier_mapping = {
        'tier1': DatabaseTier.TIER1,
        'tier2': DatabaseTier.TIER2,
        'tier3': DatabaseTier.TIER3,
        'tier4': DatabaseTier.TIER4,
        'tier5': DatabaseTier.TIER5,
    }
    
    tier = tier_mapping.get(vps_tier, DatabaseTier.TIER1)
    
    return DatabaseConfig(
        tier=tier,
        postgres_url=os.getenv('DATABASE_URL'),
        redis_url=os.getenv('REDIS_URL'),
        enable_analytics=tier in [DatabaseTier.TIER4, DatabaseTier.TIER5],
        enable_monitoring=tier == DatabaseTier.TIER5
    )