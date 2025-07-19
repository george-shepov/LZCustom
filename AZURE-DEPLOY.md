# 🚀 LZ Custom - Azure Ubuntu Deployment

Deploy the complete LZ Custom website with admin dashboard and AI capabilities on Azure Ubuntu VM in minutes!

## ⚡ Quick Start (One Command)

```bash
curl -fsSL https://raw.githubusercontent.com/george-shepov/LZCustom/main/scripts/quick-azure-deploy.sh | bash
```

This single command will:
- ✅ Install all dependencies (Node.js, Python, Ollama)
- ✅ Download and configure AI models (10GB)
- ✅ Deploy the website with admin dashboard
- ✅ Configure nginx, security, and monitoring
- ✅ Set up systemd services for auto-start

## 📋 Prerequisites

### Azure VM Requirements
- **OS**: Ubuntu 20.04 LTS or 22.04 LTS
- **Size**: Standard_D2s_v3 (2 vCPU, 8GB RAM) minimum
- **Storage**: 50GB+ Premium SSD
- **Ports**: 22 (SSH), 80 (HTTP), 443 (HTTPS)

### Quick VM Creation
```bash
# Using Azure CLI
az vm create \
  --resource-group myResourceGroup \
  --name lzcustom-vm \
  --image Ubuntu2204 \
  --size Standard_D2s_v3 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --public-ip-sku Standard \
  --storage-sku Premium_LRS \
  --os-disk-size-gb 50

# Open ports
az vm open-port --resource-group myResourceGroup --name lzcustom-vm --port 80
az vm open-port --resource-group myResourceGroup --name lzcustom-vm --port 443
```

## 🌐 Access Your Website

After deployment completes:

- **Main Website**: `http://YOUR_VM_IP`
- **Admin Dashboard**: `http://YOUR_VM_IP/admin.html`
- **API Docs**: `http://YOUR_VM_IP:8000/docs`

## 🔧 Management Commands

The deployment creates these helpful scripts:

```bash
# Start all services
~/start-lzcustom.sh

# Stop services
~/stop-lzcustom.sh

# Monitor system
~/monitor-lzcustom.sh

# Update application
~/update-lzcustom.sh
```

## 📊 Admin Dashboard Features

Access the admin dashboard at `/admin.html` to:

### Lead Management
- View all form submissions (even partial ones)
- Search and filter prospects
- Add notes and update status
- Track high-priority leads

### AI Configuration
- Enable/disable AI models
- Configure response tiers
- Monitor usage statistics
- Optimize costs

### Analytics
- Chat conversation tracking
- Lead source analysis
- Model performance metrics
- Real-time statistics

## 🤖 AI Models Included

The deployment includes three AI models:

1. **Fast Response** (llama3.2:3b) - 2GB
   - Simple questions, 1-2 second responses
   - Basic customer service queries

2. **Balanced** (gemma3:4b) - 3.3GB
   - Moderate complexity questions
   - General fabrication inquiries

3. **Technical Expert** (qwen2.5:7b) - 4.7GB
   - Technical fabrication questions
   - Detailed project discussions

## 🔒 Security Features

- UFW firewall configured
- Fail2ban for SSH protection
- Nginx security headers
- Service isolation
- Regular security updates

## 📈 Performance Optimization

### For Production
- Upgrade to Standard_D4s_v3 (4 vCPU, 16GB RAM)
- Enable Azure Accelerated Networking
- Configure SSL with Let's Encrypt
- Set up Azure Backup

### Cost Optimization
- Use Reserved Instances (up to 72% savings)
- Auto-shutdown during off-hours
- Monitor with Azure Cost Management

## 🔍 Troubleshooting

### Check Service Status
```bash
sudo systemctl status lzcustom-backend
sudo systemctl status lzcustom-frontend
sudo systemctl status ollama
sudo systemctl status nginx
```

### View Logs
```bash
sudo journalctl -u lzcustom-backend -f
sudo journalctl -u lzcustom-frontend -f
```

### Common Issues
1. **AI models not loading**: Check disk space and memory
2. **Port access issues**: Verify Azure NSG rules
3. **High memory usage**: Consider VM upgrade

## 🆘 Support

- **GitHub Issues**: https://github.com/george-shepov/LZCustom/issues
- **Documentation**: Check deployment logs for specific errors
- **Monitoring**: Use `~/monitor-lzcustom.sh` for system status

## 🎯 What You Get

After deployment, you'll have a complete business website with:

- **Professional Website** - Responsive design with gallery
- **Lead Capture** - Forms that never lose prospects
- **AI Chat Support** - Multiple models for different complexity
- **Admin Dashboard** - Complete lead and AI management
- **Analytics** - Track performance and usage
- **Mobile Ready** - Works perfectly on all devices

## 💰 Estimated Azure Costs

- **Standard_D2s_v3**: ~$70-100/month
- **Standard_D4s_v3**: ~$140-200/month
- **Storage (50GB Premium SSD)**: ~$10/month
- **Bandwidth**: Varies by usage

*Use Reserved Instances for significant savings on long-term deployments.*

---

**🎉 Your professional fabrication website with AI and admin dashboard is ready in minutes!**

Deploy now with: `curl -fsSL https://raw.githubusercontent.com/george-shepov/LZCustom/main/scripts/quick-azure-deploy.sh | bash`
