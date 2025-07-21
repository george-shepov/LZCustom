#!/bin/bash

echo "🚀 LZ Custom VPS Deployment Script"
echo "=================================="

# Create environment file
cat > .env << EOF
SECRET_KEY=$(openssl rand -hex 32)
DEEPSEEK_API_KEY=your_deepseek_key_here
OPENAI_API_KEY=your_openai_key_here
FLASK_ENV=production
AI_ENABLED=true
AI_MODEL=deepseek
EOF

echo "✅ Environment file created"

# Build and start services
echo "🔨 Building Docker containers..."
docker-compose -f docker-compose.prod.yml build

echo "🚀 Starting services..."
docker-compose -f docker-compose.prod.yml up -d

echo "📥 Pulling DeepSeek R1 model..."
docker exec lzcustom-ollama-1 ollama pull deepseek-r1:1.5b

echo "🌐 Setting up firewall..."
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 11434

echo "✅ Deployment complete!"
echo ""
echo "🌐 Your website is now live at:"
echo "   http://$(curl -s ifconfig.me)"
echo ""
echo "🤖 AI Models available:"
echo "   - DeepSeek R1 (Local Ollama)"
echo "   - OpenAI GPT (API)"
echo ""
echo "📊 Check status:"
echo "   docker-compose -f docker-compose.prod.yml ps"
echo ""
echo "📝 View logs:"
echo "   docker-compose -f docker-compose.prod.yml logs -f"
