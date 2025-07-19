"""
VPS Dime Integration and Referral Management
Handles 3-day trials, upgrade tracking, and affiliate commissions
"""

import os
import asyncio
import aiohttp
import json
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from dataclasses import dataclass
from enum import Enum
import hashlib
import hmac

class TrialStatus(Enum):
    PENDING = "pending"
    ACTIVE = "active"
    EXPIRED = "expired"
    CONVERTED = "converted"
    CANCELLED = "cancelled"

@dataclass
class TrialRequest:
    user_email: str
    current_tier: str
    target_tier: str
    referral_code: str
    source: str
    trigger: str
    user_ip: str
    created_at: datetime

@dataclass
class VPSDimeConfig:
    api_key: str
    api_secret: str
    referral_code: str
    webhook_secret: str
    base_url: str = "https://api.vpsdime.com/v1"

class VPSDimeClient:
    def __init__(self, config: VPSDimeConfig):
        self.config = config
        self.session = None
    
    async def __aenter__(self):
        self.session = aiohttp.ClientSession()
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()
    
    def _sign_request(self, method: str, path: str, data: str = "") -> Dict[str, str]:
        """Create HMAC signature for API request"""
        timestamp = str(int(datetime.now().timestamp()))
        message = f"{method}{path}{timestamp}{data}"
        signature = hmac.new(
            self.config.api_secret.encode(),
            message.encode(),
            hashlib.sha256
        ).hexdigest()
        
        return {
            "X-API-Key": self.config.api_key,
            "X-Timestamp": timestamp,
            "X-Signature": signature,
            "Content-Type": "application/json"
        }
    
    async def create_trial_account(self, trial_request: TrialRequest) -> Dict[str, Any]:
        """Create a 3-day trial account on VPS Dime"""
        path = "/trials"
        data = {
            "email": trial_request.user_email,
            "plan": trial_request.target_tier,
            "duration_days": 3,
            "referral_code": trial_request.referral_code,
            "source": "lzcustom",
            "metadata": {
                "current_tier": trial_request.current_tier,
                "trigger": trial_request.trigger,
                "user_ip": trial_request.user_ip,
                "original_source": trial_request.source
            }
        }
        
        json_data = json.dumps(data)
        headers = self._sign_request("POST", path, json_data)
        
        async with self.session.post(
            f"{self.config.base_url}{path}",
            headers=headers,
            data=json_data
        ) as response:
            if response.status == 201:
                return await response.json()
            else:
                error_text = await response.text()
                raise Exception(f"VPS Dime API error: {response.status} - {error_text}")
    
    async def get_trial_status(self, trial_id: str) -> Dict[str, Any]:
        """Get current status of a trial account"""
        path = f"/trials/{trial_id}"
        headers = self._sign_request("GET", path)
        
        async with self.session.get(
            f"{self.config.base_url}{path}",
            headers=headers
        ) as response:
            if response.status == 200:
                return await response.json()
            else:
                raise Exception(f"Failed to get trial status: {response.status}")
    
    async def get_referral_stats(self) -> Dict[str, Any]:
        """Get referral statistics and earnings"""
        path = f"/referrals/{self.config.referral_code}/stats"
        headers = self._sign_request("GET", path)
        
        async with self.session.get(
            f"{self.config.base_url}{path}",
            headers=headers
        ) as response:
            if response.status == 200:
                return await response.json()
            else:
                return {"error": "Failed to get referral stats"}

class TrialManager:
    def __init__(self, vps_config: VPSDimeConfig, database_manager):
        self.vps_config = vps_config
        self.db = database_manager
        self.client = None
    
    async def initiate_trial(self, trial_data: Dict[str, Any]) -> Dict[str, Any]:
        """Start a 3-day trial process"""
        try:
            # Create trial request
            trial_request = TrialRequest(
                user_email=trial_data.get('email', ''),
                current_tier=trial_data.get('current_tier', 'tier1'),
                target_tier=trial_data.get('target_tier', 'tier2'),
                referral_code=self.vps_config.referral_code,
                source=trial_data.get('source', 'website'),
                trigger=trial_data.get('trigger', 'manual'),
                user_ip=trial_data.get('user_ip', ''),
                created_at=datetime.now()
            )
            
            # Log trial request to database
            await self._log_trial_request(trial_request)
            
            # Create trial account with VPS Dime
            async with VPSDimeClient(self.vps_config) as client:
                vps_response = await client.create_trial_account(trial_request)
            
            # Generate trial setup instructions
            setup_instructions = self._generate_setup_instructions(
                trial_request.target_tier,
                vps_response.get('server_details', {})
            )
            
            # Update trial status in database
            await self._update_trial_status(
                vps_response.get('trial_id'),
                TrialStatus.ACTIVE,
                vps_response
            )
            
            return {
                "success": True,
                "trial_id": vps_response.get('trial_id'),
                "server_ip": vps_response.get('server_ip'),
                "ssh_details": vps_response.get('ssh_details'),
                "setup_instructions": setup_instructions,
                "expires_at": (datetime.now() + timedelta(days=3)).isoformat(),
                "dashboard_url": f"https://vpsdime.com/dashboard/trial/{vps_response.get('trial_id')}"
            }
            
        except Exception as e:
            await self._log_trial_error(trial_request, str(e))
            return {
                "success": False,
                "error": str(e),
                "fallback_url": f"https://vpsdime.com/signup?plan={trial_request.target_tier}&ref={self.vps_config.referral_code}"
            }
    
    def _generate_setup_instructions(self, tier: str, server_details: Dict) -> List[Dict]:
        """Generate tier-specific setup instructions"""
        base_instructions = [
            {
                "step": 1,
                "title": "Connect to your trial server",
                "command": f"ssh root@{server_details.get('ip', 'YOUR_SERVER_IP')}",
                "description": "Use the provided SSH key or password"
            },
            {
                "step": 2,
                "title": "Download LZ Custom deployment",
                "command": "git clone https://github.com/george-shepov/LZCustom.git && cd LZCustom",
                "description": "Get the latest version of the application"
            }
        ]
        
        tier_instructions = {
            "tier1": [
                {
                    "step": 3,
                    "title": "Deploy Tier 1 (Basic)",
                    "command": "./deployment/tier-deploy.sh --tier tier1",
                    "description": "Basic website with external AI"
                }
            ],
            "tier2": [
                {
                    "step": 3,
                    "title": "Deploy Tier 2 (Standard)",
                    "command": "./deployment/tier-deploy.sh --tier tier2",
                    "description": "Local AI with Redis caching"
                }
            ],
            "tier3": [
                {
                    "step": 3,
                    "title": "Deploy Tier 3 (Enhanced)", 
                    "command": "./deployment/tier-deploy.sh --tier tier3",
                    "description": "Smart AI with PostgreSQL and analytics"
                }
            ],
            "tier4": [
                {
                    "step": 3,
                    "title": "Deploy Tier 4 (Professional)",
                    "command": "./deployment/tier-deploy.sh --tier tier4",
                    "description": "Dual AI models with monitoring"
                }
            ],
            "tier5": [
                {
                    "step": 3,
                    "title": "Deploy Tier 5 (Enterprise)",
                    "command": "./deployment/tier-deploy.sh --tier tier5",
                    "description": "Full AI stack with enterprise features"
                }
            ]
        }
        
        instructions = base_instructions + tier_instructions.get(tier, tier_instructions["tier2"])
        
        instructions.append({
            "step": 4,
            "title": "Access your application",
            "command": f"http://{server_details.get('ip', 'YOUR_SERVER_IP')}",
            "description": "Your LZ Custom website is now running!"
        })
        
        return instructions
    
    async def _log_trial_request(self, trial_request: TrialRequest):
        """Log trial request to database"""
        if hasattr(self.db, 'postgres_pool') and self.db.postgres_pool:
            async with self.db.postgres_pool.acquire() as conn:
                await conn.execute('''
                    INSERT INTO trial_requests 
                    (user_email, current_tier, target_tier, referral_code, source, trigger, user_ip, created_at)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                ''', trial_request.user_email, trial_request.current_tier, 
                    trial_request.target_tier, trial_request.referral_code,
                    trial_request.source, trial_request.trigger, 
                    trial_request.user_ip, trial_request.created_at)
    
    async def _update_trial_status(self, trial_id: str, status: TrialStatus, details: Dict):
        """Update trial status in database"""
        if hasattr(self.db, 'postgres_pool') and self.db.postgres_pool:
            async with self.db.postgres_pool.acquire() as conn:
                await conn.execute('''
                    UPDATE trial_requests 
                    SET status = $1, vps_trial_id = $2, server_details = $3, updated_at = $4
                    WHERE vps_trial_id = $2 OR (vps_trial_id IS NULL AND created_at >= $4 - INTERVAL '1 hour')
                ''', status.value, trial_id, json.dumps(details), datetime.now())
    
    async def _log_trial_error(self, trial_request: TrialRequest, error: str):
        """Log trial error to database"""
        if hasattr(self.db, 'postgres_pool') and self.db.postgres_pool:
            async with self.db.postgres_pool.acquire() as conn:
                await conn.execute('''
                    INSERT INTO trial_errors 
                    (user_email, current_tier, target_tier, error_message, created_at)
                    VALUES ($1, $2, $3, $4, $5)
                ''', trial_request.user_email, trial_request.current_tier,
                    trial_request.target_tier, error, datetime.now())

class WebhookHandler:
    """Handle VPS Dime webhooks for trial status updates"""
    
    def __init__(self, webhook_secret: str, database_manager):
        self.webhook_secret = webhook_secret
        self.db = database_manager
    
    def verify_webhook(self, signature: str, payload: bytes) -> bool:
        """Verify webhook signature from VPS Dime"""
        expected_signature = hmac.new(
            self.webhook_secret.encode(),
            payload,
            hashlib.sha256
        ).hexdigest()
        
        return hmac.compare_digest(signature, expected_signature)
    
    async def handle_webhook(self, event_type: str, data: Dict[str, Any]):
        """Process VPS Dime webhook events"""
        handlers = {
            "trial.created": self._handle_trial_created,
            "trial.activated": self._handle_trial_activated,
            "trial.expired": self._handle_trial_expired,
            "trial.converted": self._handle_trial_converted,
            "trial.cancelled": self._handle_trial_cancelled,
            "referral.commission": self._handle_referral_commission
        }
        
        handler = handlers.get(event_type)
        if handler:
            await handler(data)
        else:
            print(f"Unknown webhook event: {event_type}")
    
    async def _handle_trial_created(self, data: Dict):
        """Handle trial created webhook"""
        trial_id = data.get('trial_id')
        await self._update_trial_status(trial_id, TrialStatus.ACTIVE, data)
    
    async def _handle_trial_activated(self, data: Dict):
        """Handle trial activation webhook"""
        trial_id = data.get('trial_id')
        await self._update_trial_status(trial_id, TrialStatus.ACTIVE, data)
    
    async def _handle_trial_expired(self, data: Dict):
        """Handle trial expiration webhook"""
        trial_id = data.get('trial_id')
        await self._update_trial_status(trial_id, TrialStatus.EXPIRED, data)
        
        # Send follow-up email or notification
        await self._send_conversion_follow_up(trial_id)
    
    async def _handle_trial_converted(self, data: Dict):
        """Handle successful trial conversion"""
        trial_id = data.get('trial_id')
        await self._update_trial_status(trial_id, TrialStatus.CONVERTED, data)
        
        # Log conversion for analytics
        await self._log_conversion(trial_id, data)
    
    async def _handle_trial_cancelled(self, data: Dict):
        """Handle trial cancellation"""
        trial_id = data.get('trial_id')
        await self._update_trial_status(trial_id, TrialStatus.CANCELLED, data)
    
    async def _handle_referral_commission(self, data: Dict):
        """Handle referral commission webhook"""
        commission_amount = data.get('amount')
        trial_id = data.get('trial_id')
        
        # Log commission for tracking
        if hasattr(self.db, 'postgres_pool') and self.db.postgres_pool:
            async with self.db.postgres_pool.acquire() as conn:
                await conn.execute('''
                    INSERT INTO referral_commissions 
                    (trial_id, amount, currency, commission_date, details)
                    VALUES ($1, $2, $3, $4, $5)
                ''', trial_id, commission_amount, data.get('currency', 'USD'),
                    datetime.now(), json.dumps(data))
    
    async def _update_trial_status(self, trial_id: str, status: TrialStatus, data: Dict):
        """Update trial status from webhook"""
        if hasattr(self.db, 'postgres_pool') and self.db.postgres_pool:
            async with self.db.postgres_pool.acquire() as conn:
                await conn.execute('''
                    UPDATE trial_requests 
                    SET status = $1, webhook_data = $2, updated_at = $3
                    WHERE vps_trial_id = $4
                ''', status.value, json.dumps(data), datetime.now(), trial_id)

def get_vps_dime_config() -> VPSDimeConfig:
    """Get VPS Dime configuration from environment"""
    return VPSDimeConfig(
        api_key=os.getenv('VPS_DIME_API_KEY', ''),
        api_secret=os.getenv('VPS_DIME_API_SECRET', ''),
        referral_code=os.getenv('VPS_DIME_REFERRAL_CODE', 'lzcustom'),
        webhook_secret=os.getenv('VPS_DIME_WEBHOOK_SECRET', ''),
        base_url=os.getenv('VPS_DIME_API_URL', 'https://api.vpsdime.com/v1')
    )