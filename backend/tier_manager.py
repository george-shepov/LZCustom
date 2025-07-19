"""
VPS Tier Management and AI Model Selection
Handles tier detection, model routing, and upgrade prompts
"""

import os
import psutil
import asyncio
from typing import Dict, List, Optional, Tuple
from enum import Enum
from dataclasses import dataclass
from datetime import datetime, timedelta

class VPSTier(Enum):
    TIER1 = "tier1"  # 1GB RAM - Basic website + external AI
    TIER2 = "tier2"  # 2GB RAM - Website + Redis + tiny AI
    TIER3 = "tier3"  # 4GB RAM - Full stack + medium AI
    TIER4 = "tier4"  # 8GB RAM - Dual AI models
    TIER5 = "tier5"  # 16GB RAM - Full AI stack

@dataclass
class TierConfig:
    name: str
    min_ram_gb: float
    max_ram_gb: float
    available_models: List[str]
    features: List[str]
    upgrade_prompts: Dict[str, str]
    price_range: str

class TierManager:
    def __init__(self):
        self.current_tier = None
        self.detected_resources = None
        self.tier_configs = self._initialize_tier_configs()
        
    def _initialize_tier_configs(self) -> Dict[VPSTier, TierConfig]:
        return {
            VPSTier.TIER1: TierConfig(
                name="Basic",
                min_ram_gb=0.5,
                max_ram_gb=1.5,
                available_models=["external_api"],
                features=["Basic Website", "Contact Forms", "External AI (limited)"],
                upgrade_prompts={
                    "ai_limit": "You've reached your AI usage limit! Upgrade to Tier 2 for unlimited local AI chat.",
                    "performance": "Slow responses? Upgrade to Tier 2 for 3x faster AI with local models!",
                    "features": "Unlock Redis caching and session management with Tier 2!"
                },
                price_range="$3-5/month"
            ),
            VPSTier.TIER2: TierConfig(
                name="Standard", 
                min_ram_gb=1.5,
                max_ram_gb=3.0,
                available_models=["llama3.2:1b"],
                features=["Full Website", "Redis Cache", "Local AI Chat", "Session Management"],
                upgrade_prompts={
                    "ai_complexity": "Need technical expertise? Upgrade to Tier 3 for smarter AI models!",
                    "performance": "Get professional-grade responses! Tier 3 includes our 3B parameter model.",
                    "analytics": "Want to track performance? Tier 3 includes basic analytics!"
                },
                price_range="$6-10/month"
            ),
            VPSTier.TIER3: TierConfig(
                name="Enhanced",
                min_ram_gb=3.0,
                max_ram_gb=6.0,
                available_models=["llama3.2:3b"],
                features=["PostgreSQL", "Redis", "Smart AI (3B)", "Analytics", "Performance Monitoring"],
                upgrade_prompts={
                    "dual_ai": "Unlock dual AI models! Tier 4 provides intelligent model routing.",
                    "expertise": "Need fabrication expertise? Tier 4 includes specialized industry AI!",
                    "professional": "Go professional! Tier 4 offers enterprise-grade AI responses."
                },
                price_range="$15-20/month"
            ),
            VPSTier.TIER4: TierConfig(
                name="Professional",
                min_ram_gb=6.0,
                max_ram_gb=12.0,
                available_models=["llama3.2:3b", "gemma3:4b"],
                features=["Dual AI Models", "Smart Routing", "Advanced Analytics", "Lead Scoring", "Backup Systems"],
                upgrade_prompts={
                    "premium": "Go premium! Tier 5 includes our most advanced AI models.",
                    "enterprise": "Enterprise features available! Tier 5 offers monitoring and alerts.",
                    "expertise": "Unlock expert-level AI with our 7B parameter models in Tier 5!"
                },
                price_range="$25-35/month"
            ),
            VPSTier.TIER5: TierConfig(
                name="Enterprise",
                min_ram_gb=12.0,
                max_ram_gb=32.0,
                available_models=["llama3.2:3b", "gemma3:4b", "qwen2.5:7b"],
                features=["All AI Models", "Expert AI", "Full Monitoring", "Automated Backups", "Priority Support"],
                upgrade_prompts={},  # No upgrades available
                price_range="$45-60/month"
            )
        }
    
    async def detect_tier(self) -> VPSTier:
        """Detect current VPS tier based on available resources"""
        # Check environment variable first
        env_tier = os.getenv('VPS_TIER')
        if env_tier:
            return VPSTier(env_tier)
        
        # Detect based on system resources
        try:
            memory_gb = psutil.virtual_memory().total / (1024**3)
            cpu_count = psutil.cpu_count()
            
            self.detected_resources = {
                "memory_gb": memory_gb,
                "cpu_count": cpu_count,
                "detected_at": datetime.now()
            }
            
            # Map resources to tier
            if memory_gb <= 1.5:
                return VPSTier.TIER1
            elif memory_gb <= 3.0:
                return VPSTier.TIER2  
            elif memory_gb <= 6.0:
                return VPSTier.TIER3
            elif memory_gb <= 12.0:
                return VPSTier.TIER4
            else:
                return VPSTier.TIER5
                
        except Exception:
            # Fallback to basic tier
            return VPSTier.TIER1
    
    async def get_available_models(self, tier: Optional[VPSTier] = None) -> List[str]:
        """Get available AI models for current or specified tier"""
        if tier is None:
            tier = await self.detect_tier()
        
        return self.tier_configs[tier].available_models
    
    async def select_optimal_model(self, question_complexity: str, tier: Optional[VPSTier] = None) -> str:
        """Select optimal AI model based on question complexity and tier"""
        if tier is None:
            tier = await self.detect_tier()
        
        available = self.tier_configs[tier].available_models
        
        # External API for Tier 1
        if "external_api" in available:
            return "external_api"
        
        # Model selection logic based on complexity and availability
        complexity_mapping = {
            "simple": "llama3.2:1b",      # Basic questions
            "medium": "llama3.2:3b",      # Standard fabrication questions  
            "complex": "gemma3:4b",       # Technical specifications
            "expert": "qwen2.5:7b"        # Complex design/engineering
        }
        
        preferred_model = complexity_mapping.get(question_complexity, "llama3.2:3b")
        
        # Return best available model
        if preferred_model in available:
            return preferred_model
        elif "qwen2.5:7b" in available:
            return "qwen2.5:7b"
        elif "gemma3:4b" in available:
            return "gemma3:4b"
        elif "llama3.2:3b" in available:
            return "llama3.2:3b"
        elif "llama3.2:1b" in available:
            return "llama3.2:1b"
        else:
            return "external_api"
    
    async def should_show_upgrade_prompt(self, session_id: str, trigger: str) -> Tuple[bool, Optional[str]]:
        """Determine if upgrade prompt should be shown"""
        current_tier = await self.detect_tier()
        
        # Don't show for highest tier
        if current_tier == VPSTier.TIER5:
            return False, None
        
        config = self.tier_configs[current_tier]
        prompt = config.upgrade_prompts.get(trigger)
        
        if not prompt:
            return False, None
        
        # Check if prompt was shown recently (implement rate limiting)
        if await self._was_prompt_shown_recently(session_id, trigger):
            return False, None
        
        return True, prompt
    
    async def _was_prompt_shown_recently(self, session_id: str, trigger: str) -> bool:
        """Check if upgrade prompt was shown recently to avoid spam"""
        # Implement Redis-based rate limiting for Tier 3+
        # For now, simple time-based logic
        return False  # Placeholder
    
    def get_tier_info(self, tier: VPSTier) -> Dict:
        """Get comprehensive tier information"""
        config = self.tier_configs[tier]
        return {
            "tier": tier.value,
            "name": config.name,
            "price_range": config.price_range,
            "features": config.features,
            "available_models": config.available_models,
            "ram_range": f"{config.min_ram_gb}-{config.max_ram_gb}GB",
            "upgrade_available": tier != VPSTier.TIER5
        }
    
    def get_upgrade_comparison(self, current_tier: VPSTier) -> Dict:
        """Get comparison with next tier for upgrade prompts"""
        tier_order = [VPSTier.TIER1, VPSTier.TIER2, VPSTier.TIER3, VPSTier.TIER4, VPSTier.TIER5]
        
        try:
            current_index = tier_order.index(current_tier)
            if current_index < len(tier_order) - 1:
                next_tier = tier_order[current_index + 1]
                
                current_config = self.tier_configs[current_tier]
                next_config = self.tier_configs[next_tier]
                
                return {
                    "current": {
                        "tier": current_tier.value,
                        "name": current_config.name,
                        "price": current_config.price_range,
                        "features": current_config.features
                    },
                    "upgrade_to": {
                        "tier": next_tier.value,
                        "name": next_config.name,
                        "price": next_config.price_range,
                        "features": next_config.features,
                        "new_features": list(set(next_config.features) - set(current_config.features))
                    },
                    "vps_dime_link": f"https://vpsdime.com/upgrade?from={current_tier.value}&to={next_tier.value}&ref=lzcustom"
                }
        except ValueError:
            pass
        
        return {}

class ResourceMonitor:
    """Monitor system resources and suggest optimizations"""
    
    @staticmethod
    async def get_resource_usage() -> Dict:
        """Get current resource usage"""
        return {
            "memory_percent": psutil.virtual_memory().percent,
            "cpu_percent": psutil.cpu_percent(interval=1),
            "disk_usage": psutil.disk_usage('/').percent,
            "timestamp": datetime.now()
        }
    
    @staticmethod
    async def check_performance_issues() -> List[str]:
        """Check for performance issues and suggest upgrades"""
        issues = []
        
        memory = psutil.virtual_memory()
        if memory.percent > 85:
            issues.append("High memory usage detected. Consider upgrading for better performance.")
        
        cpu_percent = psutil.cpu_percent(interval=1)
        if cpu_percent > 80:
            issues.append("High CPU usage. Upgrade for faster AI response times.")
        
        return issues

# Global tier manager instance
tier_manager = TierManager()