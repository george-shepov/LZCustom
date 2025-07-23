# Simplified exception handling that should work
import asyncio
import aiohttp

async def generate_response(self, question: str, tier: ModelTier = None) -> Dict:
    """Generate response with simplified exception handling"""
    try:
        # Your existing code here
        start_time = time.time()
        
        # Get model config
        if tier is None:
            tier = self.classifier.classify_question(question)
        
        config = self.models.get(tier, self.models[ModelTier.FAST])
        
        # Call Ollama
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
        return {
            "response": "I'm having trouble processing your question right now. Please call us at 216-268-2990 or fill out our quote form, and we'll get back to you within 2 hours!",
            "model_used": "fallback",
            "tier": "FALLBACK",
            "response_time": 0,
            "success": False,
            "error": str(e)
        }
