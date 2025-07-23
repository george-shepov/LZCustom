import asyncio
import aiohttp
import time
import os
from enum import Enum
from typing import Dict, Optional
from dataclasses import dataclass

class ModelTier(Enum):
    FAST = "fast"
    MEDIUM = "medium"
    ADVANCED = "advanced"
    EXPERT = "expert"

@dataclass
class ModelConfig:
    model_name: str
    timeout: int
    max_tokens: int

class QuestionClassifier:
    @staticmethod
    def classify_question(question: str) -> ModelTier:
        """Classify question complexity"""
        question_lower = question.lower()
        word_count = len(question.split())
        
        # Technical keywords
        technical_keywords = [
            'granite', 'quartz', 'marble', 'countertop', 'cabinet', 'installation',
            'fabrication', 'cnc', 'cutting', 'edge', 'backsplash', 'tile'
        ]
        
        technical_matches = sum(1 for keyword in technical_keywords if keyword in question_lower)
        
        if word_count <= 5 and technical_matches == 0:
            return ModelTier.FAST
        elif technical_matches >= 2 or word_count > 20:
            return ModelTier.ADVANCED
        elif technical_matches >= 1 or word_count > 15:
            return ModelTier.MEDIUM
        else:
            return ModelTier.FAST

class LLaMAService:
    """Service for interacting with local LLaMA models via Ollama"""
    
    def __init__(self, base_url: str = None):
        # Use environment variable or default
        self.base_url = base_url or os.environ.get('OLLAMA_HOST', 'http://localhost:11434')
        self.session = None
        self.classifier = QuestionClassifier()
        
        # Model configurations
        self.models = {
            ModelTier.FAST: ModelConfig("qwen2.5:7b-instruct-q4_k_m", 15, 200),
            ModelTier.MEDIUM: ModelConfig("qwen2.5:7b-instruct-q4_k_m", 25, 400),
            ModelTier.ADVANCED: ModelConfig("qwen2.5:7b-instruct-q4_k_m", 35, 600),
            ModelTier.EXPERT: ModelConfig("qwen2.5:7b-instruct-q4_k_m", 45, 800)
        }

    async def __aenter__(self):
        """Async context manager entry"""
        connector = aiohttp.TCPConnector(limit=10, limit_per_host=5)
        timeout = aiohttp.ClientTimeout(total=60, connect=10)
        self.session = aiohttp.ClientSession(connector=connector, timeout=timeout)
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit"""
        if self.session:
            await self.session.close()

    async def chat(self, question: str, session_id: str) -> Dict:
        """Main chat interface"""
        return await self.generate_response(question)

    async def generate_response(self, question: str, tier: ModelTier = None) -> Dict:
        """Generate response using Ollama with intelligent model routing"""
        start_time = time.time()
        
        try:
            # Classify question if tier not specified
            if tier is None:
                tier = self.classifier.classify_question(question)
            
            config = self.models.get(tier, self.models[ModelTier.FAST])
            
            # Generate response
            response = await self._call_ollama(question, config)
            response_time = time.time() - start_time
            
            return {
                "response": response,
                "model_used": config.model_name,
                "tier": tier.name,
                "response_time": round(response_time, 2),
                "success": True
            }
            
        except Exception as e:
            # Simplified exception handling - catch everything
            print(f"❌ LLaMA Error: {e}")
            return self._error_response(str(e))

    async def _call_ollama(self, question: str, config: ModelConfig) -> str:
        """Make API call to Ollama"""
        if not self.session:
            raise Exception("Session not initialized")
            
        try:
            # Create LZ Custom context
            lz_context = """You are a helpful customer service representative for LZ Custom Fabrication, 
            a premier custom cabinet and stone fabrication company in Northeast Ohio with 30+ years of experience. 
            We specialize in custom cabinets, countertops (granite, quartz, marble), tile installation, 
            flooring, and commercial painting. We do in-house manufacturing and don't outsource. 
            Our phone number is 216-268-2990. Always be helpful and encourage customers to call for quotes."""
            
            payload = {
                "model": config.model_name,
                "prompt": f"{lz_context}\n\nCustomer question: {question}\n\nResponse:",
                "stream": False,
                "options": {
                    "temperature": 0.7,
                    "top_p": 0.9,
                    "max_tokens": config.max_tokens
                }
            }
            
            # Create timeout for this specific request
            timeout = aiohttp.ClientTimeout(total=config.timeout)
            
            async with self.session.post(
                f"{self.base_url}/api/generate",
                json=payload,
                timeout=timeout
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    content = data.get('response', '').strip()
                    
                    if content:
                        print(f"✅ Ollama response: {content[:100]}...")
                        return content
                    else:
                        raise Exception("Empty response from Ollama")
                else:
                    error_text = await response.text()
                    print(f"❌ Ollama API error {response.status}: {error_text}")
                    raise Exception(f"Ollama API error: {response.status}")
                    
        except asyncio.TimeoutError:
            print(f"⏰ Ollama timeout after {config.timeout}s")
            raise Exception(f"Ollama timeout: {config.timeout}s")
        except aiohttp.ClientError as e:
            print(f"🔌 Ollama connection error: {e}")
            raise Exception(f"Ollama connection error: {e}")
        except Exception as e:
            print(f"❌ Failed to call Ollama: {type(e).__name__}: {e}")
            raise Exception(f"Failed to call Ollama: {type(e).__name__}: {e}")
    
    def _fallback_response(self, question: str) -> Dict:
        """Fallback response when AI is unavailable"""
        return {
            "response": "I'm having trouble processing your question right now. Please call us at 216-268-2990 or fill out our quote form, and we'll get back to you within 2 hours!",
            "model_used": "fallback",
            "tier": "FALLBACK",
            "response_time": 0,
            "success": False
        }
    
    def _error_response(self, error: str) -> Dict:
        """Error response"""
        return {
            "response": "I'm experiencing technical difficulties. For immediate assistance, please call 216-268-2990. Our team is available Mon-Fri 8AM-5PM.",
            "model_used": "error",
            "tier": "ERROR",
            "response_time": 0,
            "success": False,
            "error": error
        }

# Performance testing function
async def test_model_performance():
    """Test all models with sample questions"""
    test_questions = [
        "What are your hours?",  # Simple
        "What's the difference between granite and quartz?",  # Technical
        "I need custom cabinets for my kitchen renovation with specific storage requirements"  # Complex
    ]
    
    async with LLaMAService() as service:
        results = []
        
        for question in test_questions:
            print(f"\nTesting: {question}")
            
            for tier in ModelTier:
                try:
                    result = await service.generate_response(question, tier)
                    results.append({
                        "question": question,
                        "tier": tier.name,
                        "model": result["model_used"],
                        "response_time": result["response_time"],
                        "response_length": len(result["response"]),
                        "success": result["success"]
                    })
                    print(f"  {tier.name}: {result['response_time']}s - {result['model_used']}")
                except Exception as e:
                    print(f"  {tier.name}: ERROR - {e}")
        
        return results

if __name__ == "__main__":
    # Run performance test
    asyncio.run(test_model_performance())
