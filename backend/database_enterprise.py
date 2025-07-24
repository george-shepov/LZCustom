# Multi-Database Connection Manager for Enterprise LZCustom Platform
# Manages PostgreSQL, Redis, MongoDB, and Qdrant connections

import asyncpg
import redis.asyncio as redis
import motor.motor_asyncio
from qdrant_client.async_qdrant_client import AsyncQdrantClient
from contextlib import asynccontextmanager
import os
import json
from typing import Optional, Dict, Any, List
import logging
import asyncio

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DatabaseManager:
    """Central database connection manager for all database systems"""
    
    def __init__(self):
        # PostgreSQL settings
        self.pg_host = os.getenv("POSTGRES_HOST", "postgres")
        self.pg_port = int(os.getenv("POSTGRES_PORT", "5432"))
        self.pg_db = os.getenv("POSTGRES_DB", "lzcustom_db")
        self.pg_user = os.getenv("POSTGRES_USER", "lzcustom")
        self.pg_password = os.getenv("POSTGRES_PASSWORD", "lzcustom_password")
        
        # Redis settings
        self.redis_host = os.getenv("REDIS_HOST", "redis")
        self.redis_port = int(os.getenv("REDIS_PORT", "6379"))
        self.redis_password = os.getenv("REDIS_PASSWORD", "redis_password")
        
        # MongoDB settings
        self.mongo_host = os.getenv("MONGODB_HOST", "mongo")
        self.mongo_port = int(os.getenv("MONGODB_PORT", "27017"))
        self.mongo_db = os.getenv("MONGODB_DB", "lzcustom_docs")
        
        # Qdrant settings
        self.qdrant_host = os.getenv("QDRANT_HOST", "qdrant")
        self.qdrant_port = int(os.getenv("QDRANT_PORT", "6333"))
        
        # Connection pools
        self.pg_pool = None
        self.redis_client = None
        self.mongo_client = None
        self.qdrant_client = None
        
    async def initialize(self):
        """Initialize all database connections"""
        try:
            await self._init_postgresql()
            await self._init_redis()
            await self._init_mongodb()
            await self._init_qdrant()
            logger.info("✅ All database connections initialized successfully")
        except Exception as e:
            logger.error(f"❌ Failed to initialize database connections: {e}")
            raise
    
    async def _init_postgresql(self):
        """Initialize PostgreSQL connection pool"""
        try:
            self.pg_pool = await asyncpg.create_pool(
                host=self.pg_host,
                port=self.pg_port,
                database=self.pg_db,
                user=self.pg_user,
                password=self.pg_password,
                min_size=5,
                max_size=20,
                command_timeout=60
            )
            logger.info("✅ PostgreSQL connection pool created")
        except Exception as e:
            logger.error(f"❌ PostgreSQL connection failed: {e}")
            raise
    
    async def _init_redis(self):
        """Initialize Redis connection"""
        try:
            self.redis_client = redis.Redis(
                host=self.redis_host,
                port=self.redis_port,
                password=self.redis_password,
                decode_responses=True,
                health_check_interval=30
            )
            # Test connection
            await self.redis_client.ping()
            logger.info("✅ Redis connection established")
        except Exception as e:
            logger.error(f"❌ Redis connection failed: {e}")
            raise
    
    async def _init_mongodb(self):
        """Initialize MongoDB connection"""
        try:
            mongo_url = f"mongodb://{self.mongo_host}:{self.mongo_port}"
            self.mongo_client = motor.motor_asyncio.AsyncIOMotorClient(mongo_url)
            # Test connection
            await self.mongo_client.admin.command('ping')
            logger.info("✅ MongoDB connection established")
        except Exception as e:
            logger.error(f"❌ MongoDB connection failed: {e}")
            raise
    
    async def _init_qdrant(self):
        """Initialize Qdrant vector database connection"""
        try:
            self.qdrant_client = AsyncQdrantClient(
                host=self.qdrant_host,
                port=self.qdrant_port
            )
            # Test connection
            collections = await self.qdrant_client.get_collections()
            logger.info("✅ Qdrant vector database connection established")
        except Exception as e:
            logger.error(f"❌ Qdrant connection failed: {e}")
            raise
    
    async def close(self):
        """Close all database connections"""
        if self.pg_pool:
            await self.pg_pool.close()
        if self.redis_client:
            await self.redis_client.close()
        if self.mongo_client:
            self.mongo_client.close()
        if self.qdrant_client:
            await self.qdrant_client.close()
        logger.info("✅ All database connections closed")
    
    @asynccontextmanager
    async def get_postgres_connection(self):
        """Get PostgreSQL connection from pool"""
        async with self.pg_pool.acquire() as connection:
            yield connection
    
    def get_redis(self):
        """Get Redis client"""
        return self.redis_client
    
    def get_mongodb(self):
        """Get MongoDB database"""
        return self.mongo_client[self.mongo_db]
    
    def get_qdrant(self):
        """Get Qdrant client"""
        return self.qdrant_client

class DomainBasedRepository:
    """Base repository class for domain-specific data operations"""
    
    DOMAIN_SCHEMAS = {
        "giorgiy": "lz_custom",
        "giorgiy-shepov": "gs_consulting", 
        "bravoohio": "bravo_ohio",
        "lodexinc": "lodex_inc"
    }
    
    def __init__(self, db_manager: DatabaseManager):
        self.db = db_manager
    
    def get_schema_for_domain(self, domain_brand: str) -> str:
        """Get PostgreSQL schema name for domain"""
        return self.DOMAIN_SCHEMAS.get(domain_brand, "lz_custom")
    
    async def execute_query(self, query: str, params: tuple = None, domain_brand: str = "giorgiy"):
        """Execute PostgreSQL query with domain-specific schema"""
        schema = self.get_schema_for_domain(domain_brand)
        formatted_query = query.replace("{schema}", schema)
        
        async with self.db.get_postgres_connection() as conn:
            if params:
                return await conn.fetch(formatted_query, *params)
            else:
                return await conn.fetch(formatted_query)
    
    async def execute_command(self, query: str, params: tuple = None, domain_brand: str = "giorgiy"):
        """Execute PostgreSQL command (INSERT, UPDATE, DELETE) with domain-specific schema"""
        schema = self.get_schema_for_domain(domain_brand)
        formatted_query = query.replace("{schema}", schema)
        
        async with self.db.get_postgres_connection() as conn:
            if params:
                return await conn.execute(formatted_query, *params)
            else:
                return await conn.execute(formatted_query)

class ProspectsRepository(DomainBasedRepository):
    """Repository for prospects/leads data"""
    
    async def create_prospect(self, prospect_data: Dict[str, Any], domain_brand: str = "giorgiy") -> str:
        """Create new prospect in domain-specific schema"""
        query = """
            INSERT INTO {schema}.prospects (
                name, email, phone, project_type, budget_range, timeline,
                message, room_dimensions, measurements, wood_species,
                cabinet_style, material_type, square_footage, priority
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
            RETURNING id
        """
        
        params = (
            prospect_data.get('name'),
            prospect_data.get('email'),
            prospect_data.get('phone'),
            prospect_data.get('project_type'),
            prospect_data.get('budget_range'),
            prospect_data.get('timeline'),
            prospect_data.get('message'),
            prospect_data.get('room_dimensions'),
            prospect_data.get('measurements'),
            prospect_data.get('wood_species'),
            prospect_data.get('cabinet_style'),
            prospect_data.get('material_type'),
            prospect_data.get('square_footage'),
            prospect_data.get('priority', 'normal')
        )
        
        result = await self.execute_query(query, params, domain_brand)
        return str(result[0]['id']) if result else None
    
    async def get_prospects(self, domain_brand: str = "giorgiy", limit: int = 100) -> List[Dict]:
        """Get prospects for specific domain"""
        query = """
            SELECT id, name, email, phone, project_type, budget_range, 
                   timeline, created_at, status, priority
            FROM {schema}.prospects 
            ORDER BY 
                CASE priority 
                    WHEN 'high' THEN 1 
                    WHEN 'normal' THEN 2 
                    WHEN 'low' THEN 3 
                END,
                created_at DESC
            LIMIT $1
        """
        
        results = await self.execute_query(query, (limit,), domain_brand)
        return [dict(row) for row in results]
    
    async def get_prospect_by_id(self, prospect_id: str, domain_brand: str = "giorgiy") -> Optional[Dict]:
        """Get specific prospect by ID"""
        query = "SELECT * FROM {schema}.prospects WHERE id = $1"
        results = await self.execute_query(query, (prospect_id,), domain_brand)
        return dict(results[0]) if results else None
    
    async def update_prospect_status(self, prospect_id: str, status: str, notes: str = "", domain_brand: str = "giorgiy"):
        """Update prospect status and notes"""
        query = """
            UPDATE {schema}.prospects 
            SET status = $1, notes = $2, updated_at = CURRENT_TIMESTAMP
            WHERE id = $3
        """
        await self.execute_command(query, (status, notes, prospect_id), domain_brand)

class ChatRepository(DomainBasedRepository):
    """Repository for chat conversations"""
    
    async def log_conversation(self, conversation_data: Dict[str, Any], domain_brand: str = "giorgiy"):
        """Log chat conversation in domain-specific schema"""
        query = """
            INSERT INTO {schema}.chat_conversations (
                session_id, user_message, ai_response, model_used, tier,
                response_time, success, error_message, user_ip, user_agent
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        """
        
        params = (
            conversation_data['session_id'],
            conversation_data['user_message'],
            conversation_data['ai_response'],
            conversation_data['model_used'],
            conversation_data['tier'],
            conversation_data['response_time'],
            conversation_data['success'],
            conversation_data.get('error_message'),
            conversation_data.get('user_ip'),
            conversation_data.get('user_agent')
        )
        
        await self.execute_command(query, params, domain_brand)
    
    async def get_conversations(self, domain_brand: str = "giorgiy", session_id: str = None, limit: int = 50) -> List[Dict]:
        """Get chat conversations for domain"""
        if session_id:
            query = """
                SELECT * FROM {schema}.chat_conversations
                WHERE session_id = $1
                ORDER BY created_at DESC
                LIMIT $2
            """
            params = (session_id, limit)
        else:
            query = """
                SELECT * FROM {schema}.chat_conversations
                ORDER BY created_at DESC
                LIMIT $1
            """
            params = (limit,)
        
        results = await self.execute_query(query, params, domain_brand)
        return [dict(row) for row in results]

class SessionManager:
    """Redis-based session management"""
    
    def __init__(self, db_manager: DatabaseManager):
        self.db = db_manager
        self.redis = db_manager.get_redis()
    
    async def create_session(self, session_id: str, domain_brand: str, user_data: Dict = None, ttl: int = 3600):
        """Create new session in Redis"""
        session_data = {
            "domain_brand": domain_brand,
            "created_at": str(asyncio.get_event_loop().time()),
            "message_count": 0,
            **(user_data or {})
        }
        
        await self.redis.hset(f"session:{session_id}", mapping=session_data)
        await self.redis.expire(f"session:{session_id}", ttl)
        
        # Also log in PostgreSQL shared.sessions table
        async with self.db.get_postgres_connection() as conn:
            await conn.execute("""
                INSERT INTO shared.sessions (session_token, domain, expires_at)
                VALUES ($1, $2, NOW() + INTERVAL '%s seconds')
                ON CONFLICT (session_token) DO UPDATE SET
                    domain = EXCLUDED.domain,
                    expires_at = EXCLUDED.expires_at
            """ % ttl, session_id, domain_brand)
    
    async def get_session(self, session_id: str) -> Optional[Dict]:
        """Get session data from Redis"""
        session_data = await self.redis.hgetall(f"session:{session_id}")
        return session_data if session_data else None
    
    async def update_session(self, session_id: str, updates: Dict):
        """Update session data"""
        await self.redis.hset(f"session:{session_id}", mapping=updates)
    
    async def increment_message_count(self, session_id: str):
        """Increment message count for session"""
        await self.redis.hincrby(f"session:{session_id}", "message_count", 1)
    
    async def delete_session(self, session_id: str):
        """Delete session"""
        await self.redis.delete(f"session:{session_id}")

class CacheManager:
    """Redis-based caching for API responses"""
    
    def __init__(self, db_manager: DatabaseManager):
        self.redis = db_manager.get_redis()
    
    async def get(self, key: str) -> Optional[Any]:
        """Get cached value"""
        value = await self.redis.get(key)
        return json.loads(value) if value else None
    
    async def set(self, key: str, value: Any, ttl: int = 300):
        """Set cached value with TTL"""
        await self.redis.setex(key, ttl, json.dumps(value, default=str))
    
    async def delete(self, key: str):
        """Delete cached value"""
        await self.redis.delete(key)
    
    async def clear_domain_cache(self, domain_brand: str):
        """Clear all cache for specific domain"""
        pattern = f"*:{domain_brand}:*"
        keys = await self.redis.keys(pattern)
        if keys:
            await self.redis.delete(*keys)

# Global database manager instance
db_manager = DatabaseManager()