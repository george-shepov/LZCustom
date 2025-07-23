"""
LLaMA Local AI Service for LZ Custom Fabrication
Intelligent model routing based on question complexity
"""

import asyncio
import aiohttp
import json
import re
import time
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum

class ModelTier(Enum):
    FAST = "llama3.2:3b"           # Simple questions, quick responses
    MEDIUM = "gemma3:4b"           # Moderate complexity
    ADVANCED = "qwen2.5:7b"        # Technical fabrication questions
    EXPERT = "llama4:16x17b"       # Complex design/engineering questions

@dataclass
class ModelConfig:
    name: str
    max_tokens: int
    temperature: float
    timeout: int
    
MODEL_CONFIGS = {
    ModelTier.FAST: ModelConfig("llama3.2:3b", 150, 0.3, 15),
    ModelTier.MEDIUM: ModelConfig("gemma3:4b", 250, 0.5, 20),
    ModelTier.ADVANCED: ModelConfig("qwen2.5:7b-instruct-q4_k_m", 400, 0.7, 25),
    ModelTier.EXPERT: ModelConfig("llama4:16x17b", 600, 0.8, 30)
}

class QuestionClassifier:
    """Classifies questions to determine appropriate model tier"""
    
    SIMPLE_PATTERNS = [
        r'\b(hours?|open|closed|phone|contact|address|location)\b',
        r'\b(hello|hi|hey|thanks?|thank you)\b',
        r'\b(yes|no|ok|okay)\b',
        r'\b(price|cost|how much)\b',
        r'\b(when|what time)\b'
    ]
    
    TECHNICAL_PATTERNS = [
        r'\b(granite|marble|quartz|quartzite|engineered stone)\b',
        r'\b(fabrication|installation|templating|cutting)\b',
        r'\b(edge profile|bullnose|ogee|beveled)\b',
        r'\b(cabinet|door|drawer|hardware)\b',
        r'\b(dimensions?|measurements?|square feet?)\b'
    ]
    
    COMPLEX_PATTERNS = [
        r'\b(design|layout|custom|specification)\b',
        r'\b(structural|load bearing|support)\b',
        r'\b(commercial|industrial|restaurant)\b',
        r'\b(timeline|project management|coordination)\b',
        r'\b(material comparison|pros and cons)\b'
    ]
    
    @classmethod
    def classify_question(cls, question: str) -> ModelTier:
        """Determine the appropriate model tier for a question"""
        question_lower = question.lower()
        
        # Count pattern matches
        simple_matches = sum(1 for pattern in cls.SIMPLE_PATTERNS 
                           if re.search(pattern, question_lower))
        technical_matches = sum(1 for pattern in cls.TECHNICAL_PATTERNS 
                              if re.search(pattern, question_lower))
        complex_matches = sum(1 for pattern in cls.COMPLEX_PATTERNS 
                            if re.search(pattern, question_lower))
        
        # Question length factor
        word_count = len(question.split())
        
        # Decision logic
        if simple_matches >= 1 and word_count < 10:
            return ModelTier.FAST
        elif complex_matches >= 2 or word_count > 30:
            return ModelTier.EXPERT
        elif technical_matches >= 1 or word_count > 15:
            return ModelTier.ADVANCED
        else:
            return ModelTier.MEDIUM

class LLaMAService:
    """Service for interacting with local LLaMA models via Ollama"""
    
    def __init__(self, base_url: str = None):
        # Use environment variable or default
        self.base_url = base_url or os.environ.get('OLLAMA_HOST', 'http://localhost:11434')
        self.session = None
        
        # LZ Custom context for all models
        self.system_context = """You are a friendly, knowledgeable customer service representative for LZ Custom Fabrication, Northeast Ohio's premier custom cabinet and stone fabrication company with over 30 years of excellence.

COMPANY OVERVIEW:
LZ Custom Fabrication specializes in luxury custom cabinets and premium stone fabrication. We serve discerning homeowners and commercial clients within 30 miles of Cleveland, Ohio.

OUR SERVICES & EXPERTISE:
• Custom Cabinets: Handcrafted from premium hardwoods (Oak, Maple, Cherry, Walnut)
  - Timeline: 4-6 weeks | Investment: $15,000-$50,000+
• Premium Countertops: Granite, Marble, Quartz, and exotic stones
  - Timeline: 2-3 weeks | Investment: $3,000-$15,000
• Master Stone Fabrication: Custom stone work and architectural elements
  - Timeline: 2-4 weeks | Investment: $2,000-$20,000
• Commercial Surfaces: Restaurant, office, and retail installations
  - Timeline: 1-2 weeks | Investment: $1,000-$10,000

CONTACT & BUSINESS INFO:
📞 Phone: 216-268-2990
🕒 Hours: Monday-Friday 8:00 AM - 5:00 PM
📍 Service Area: 30-mile radius from Cleveland, Ohio
✅ Licensed & Insured | BBB A+ Rating
💰 FREE consultations and estimates

YOUR ROLE:
- Be warm, professional, and genuinely helpful
- Answer questions about services, materials, timelines, and processes
- Encourage customers to call 216-268-2990 for detailed quotes
- Emphasize our 30+ years of experience and quality craftsmanship
- Always offer to connect them with our team for personalized service
- If you don't know something specific, direct them to call for expert guidance"""

    async def __aenter__(self):
        self.session = aiohttp.ClientSession()
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()
    
    async def generate_response(self, question: str, tier: ModelTier = None) -> Dict:
        """Generate response using appropriate model tier"""
        if not tier:
            tier = QuestionClassifier.classify_question(question)
        
        config = MODEL_CONFIGS[tier]
        start_time = time.time()
        
        try:
            response = await self._call_ollama(question, config)
            response_time = time.time() - start_time
            
            return {
                "response": response,
                "model_used": config.name,
                "tier": tier.name,
                "response_time": round(response_time, 2),
                "success": True
            }
            
        except (asyncio.TimeoutError, aiohttp.ClientTimeout):
            # Fallback to faster model if timeout
            if tier != ModelTier.FAST:
                return await self.generate_response(question, ModelTier.FAST)
            else:
                return self._fallback_response(question)
        except Exception as e:
            print(f"❌ LLaMA Error: {e}")
            return self._error_response(str(e))
    
    async def _call_ollama(self, question: str, config: ModelConfig) -> str:
        """Make API call to Ollama"""
        print(f"🔄 Calling Ollama with model: {config.name}")
        payload = {
            "model": config.name,
            "messages": [
                {"role": "system", "content": self.system_context},
                {"role": "user", "content": question}
            ],
            "options": {
                "temperature": config.temperature,
                "num_predict": config.max_tokens
            },
            "stream": False
        }
        
        try:
            timeout = aiohttp.ClientTimeout(total=config.timeout)
            print(f"🔗 Connecting to {self.base_url}/api/chat with timeout {config.timeout}s")

            async with self.session.post(
                f"{self.base_url}/api/chat",
                json=payload,
                timeout=timeout
            ) as response:
                print(f"📡 Ollama response status: {response.status}")
                if response.status == 200:
                    data = await response.json()
                    content = data["message"]["content"].strip()
                    print(f"✅ Ollama response: {content[:100]}...")
                    return content
                else:
                    error_text = await response.text()
                    print(f"❌ Ollama API error {response.status}: {error_text}")
                    raise Exception(f"Ollama API error: {response.status}")
        except aiohttp.ClientTimeout as e:
            print(f"⏰ Ollama timeout: {e}")
            raise Exception(f"Ollama timeout: {e}")
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
