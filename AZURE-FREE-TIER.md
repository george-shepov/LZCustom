# 🆓 LZ Custom - Azure Free Tier Deployment (NO AI)

Deploy the complete LZ Custom website with admin dashboard on Azure Free Tier VMs - **NO AI models required!**

## ⚡ One-Command Free Tier Deployment

```bash
curl -fsSL https://raw.githubusercontent.com/george-shepov/LZCustom/main/scripts/quick-azure-free-deploy.sh | bash
```

Perfect for Azure Free Tier B1s VMs (1 vCPU, 1GB RAM) - **completely free for 12 months!**

## 🆓 Why Choose the Free Tier Version?

### ✅ **Perfect for Azure Free Tier**
- **NO AI models** (saves 10GB+ storage and RAM)
- **Memory optimized** for 1GB RAM VMs
- **Lightweight** (~500MB download vs 12GB with AI)
- **Fast deployment** (10-15 minutes vs 30+ minutes)

### ✅ **All Core Features Included**
- **Complete admin dashboard** for lead management
- **Form submission tracking** (zero prospect loss)
- **Simple chat responses** (no AI processing needed)
- **Professional responsive website**
- **Real-time analytics** and monitoring

### ✅ **Cost Savings**
- **$0/month** on Azure Free Tier for 12 months
- **No AI processing costs** or resource overhead
- **Bandwidth optimized** with gzip compression

## 📋 Azure Free Tier Requirements

### **Perfect VM Configuration**
- **VM Size**: B1s (1 vCPU, 1GB RAM) - **FREE for 12 months**
- **OS**: Ubuntu 22.04 LTS
- **Storage**: 30GB Standard SSD (included in free tier)
- **Network**: Standard public IP (included)

### **Quick VM Creation**
```bash
# Using Azure CLI (creates perfect free tier setup)
az vm create \
  --resource-group myResourceGroup \
  --name lzcustom-free \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --public-ip-sku Basic \
  --storage-sku Standard_LRS \
  --os-disk-size-gb 30

# Open HTTP port
az vm open-port --resource-group myResourceGroup --name lzcustom-free --port 80
```

## 🚀 Deployment Steps

### 1. **Create Azure Free Tier VM**
- Sign up for Azure Free Account (if new)
- Create B1s Ubuntu VM (free for 12 months)
- Open port 80 for web access

### 2. **Connect and Deploy**
```bash
# SSH to your VM
ssh azureuser@YOUR_VM_IP

# Run one-command deployment
curl -fsSL https://raw.githubusercontent.com/george-shepov/LZCustom/main/scripts/quick-azure-free-deploy.sh | bash
```

### 3. **Access Your Website**
- **Main Website**: `http://YOUR_VM_IP`
- **Admin Dashboard**: `http://YOUR_VM_IP/admin.html`
- **API Docs**: `http://YOUR_VM_IP:8000/docs`

## 💬 Chat Feature (NO AI Required)

Instead of AI models, the free tier includes **smart predefined responses**:

### **What Users Get:**
- Helpful information about your services
- Business hours and contact information
- Guidance to call 216-268-2990 for detailed help
- Professional responses about fabrication services

### **What You Get:**
- **All conversations logged** for lead tracking
- **Zero processing overhead** (no AI models)
- **Instant responses** (no waiting for AI)
- **Complete conversation history** in admin dashboard

### **Example Responses:**
- **Greeting**: "Hello! Thanks for visiting LZ Custom. How can I help you with your fabrication project?"
- **Services**: "We offer custom cabinets, granite/quartz countertops, stone fabrication, tile work, and commercial painting."
- **Contact**: "You can reach us at 216-268-2990 or fill out our quote form. We serve Northeast Ohio within a 30-mile radius."

## 📊 Admin Dashboard Features

### **Lead Management**
- View all form submissions (even partial ones)
- Search and filter prospects
- Add notes and update status
- Track high-priority leads
- Export lead data

### **Analytics Dashboard**
- Form submission tracking
- Chat conversation logs
- Lead source analysis
- Weekly activity reports
- Resource usage monitoring

### **System Monitoring**
- Memory and disk usage
- Service status monitoring
- Performance metrics
- Free tier resource alerts

## 🔧 Management Commands

The deployment creates these helpful scripts:

```bash
# Start all services with status check
~/start-lzcustom-free.sh

# Stop services gracefully  
~/stop-lzcustom-free.sh

# Monitor system resources (important for free tier)
~/monitor-lzcustom-free.sh

# Update application from GitHub
~/update-lzcustom-free.sh
```

## 📈 Resource Usage (Free Tier Optimized)

### **Memory Usage**
- **Backend**: ~200MB (with 256MB limit)
- **Frontend**: ~100MB (with 128MB limit)
- **Nginx**: ~20MB
- **System**: ~300MB
- **Total**: ~620MB (leaves 400MB+ free on 1GB VM)

### **Storage Usage**
- **Application**: ~500MB
- **Dependencies**: ~1GB
- **Logs**: ~100MB
- **Total**: ~1.6GB (plenty of room on 30GB disk)

### **Network Usage**
- **Gzip compression** reduces bandwidth by 60-80%
- **Optimized assets** for faster loading
- **Minimal API calls** for efficiency

## 💰 Cost Breakdown

### **Azure Free Tier (First 12 Months)**
- **B1s VM**: $0/month (normally $15/month)
- **30GB Standard SSD**: $0/month (normally $2/month)
- **Basic Public IP**: $0/month (normally $3/month)
- **Bandwidth**: 15GB free/month
- **Total**: **$0/month for 12 months!**

### **After Free Tier**
- **B1s VM**: ~$15/month
- **Storage**: ~$2/month
- **Total**: ~$17/month (still very affordable)

## 🔒 Security Features

- **UFW firewall** configured
- **Nginx security headers**
- **Service isolation**
- **Memory limits** prevent resource exhaustion
- **Log rotation** to prevent disk filling

## 🔍 Troubleshooting

### **Check Service Status**
```bash
sudo systemctl status lzcustom-backend lzcustom-frontend nginx
```

### **Monitor Resources**
```bash
~/monitor-lzcustom-free.sh
```

### **Common Free Tier Issues**
1. **High memory usage**: Restart services with `~/stop-lzcustom-free.sh && ~/start-lzcustom-free.sh`
2. **Disk space full**: Clean logs with `sudo journalctl --vacuum-time=7d`
3. **Slow performance**: Normal for free tier, consider upgrading VM size

## 🎯 Perfect For

### **Small Businesses**
- **New businesses** testing online presence
- **Local contractors** needing lead capture
- **Service providers** wanting professional website
- **Startups** with limited budget

### **Development & Testing**
- **Prototype deployment** before production
- **Feature testing** without AI overhead
- **Client demonstrations** of admin features
- **Learning Azure** deployment processes

## 🚀 Upgrade Path

### **When to Upgrade**
- Need AI chat features
- Higher traffic volume
- More complex processing
- Better performance requirements

### **Easy Upgrade**
```bash
# Stop free tier version
~/stop-lzcustom-free.sh

# Run full deployment with AI
curl -fsSL https://raw.githubusercontent.com/george-shepov/LZCustom/main/scripts/quick-azure-deploy.sh | bash
```

## 🆘 Support

- **GitHub Issues**: https://github.com/george-shepov/LZCustom/issues
- **Documentation**: Check deployment logs for errors
- **Monitoring**: Use `~/monitor-lzcustom-free.sh` regularly

---

## 🎉 **Get Started Now!**

Deploy your professional fabrication website on Azure Free Tier:

```bash
curl -fsSL https://raw.githubusercontent.com/george-shepov/LZCustom/main/scripts/quick-azure-free-deploy.sh | bash
```

**Perfect for Azure Free Tier - Professional website with admin dashboard for $0/month!** 🆓☁️
