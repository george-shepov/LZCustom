# LZ Custom - Azure Ubuntu Deployment Guide

## 🚀 Complete Deployment Guide for Azure Ubuntu VM

This guide will help you deploy the LZ Custom website on an Ubuntu VM in Microsoft Azure with full admin dashboard and AI capabilities.

## 📋 Prerequisites

### Azure Requirements
- Azure subscription with VM creation permissions
- Ubuntu 20.04 LTS or 22.04 LTS VM
- **Minimum VM Size**: Standard_D2s_v3 (2 vCPUs, 8GB RAM)
- **Recommended VM Size**: Standard_D4s_v3 (4 vCPUs, 16GB RAM) for better AI performance
- **Storage**: 50GB+ Premium SSD (AI models require ~15GB)

### Network Configuration
- SSH (port 22) - for management
- HTTP (port 80) - for website access
- HTTPS (port 443) - for secure access (optional)
- Custom ports: 8000 (API), 5173 (dev), 11434 (Ollama)

## 🏗️ Step 1: Create Azure VM

### Option A: Azure Portal
1. Go to Azure Portal → Virtual Machines → Create
2. **Basics**:
   - Resource Group: Create new or use existing
   - VM Name: `lzcustom-website`
   - Region: Choose closest to your users
   - Image: `Ubuntu Server 22.04 LTS - x64 Gen2`
   - Size: `Standard_D2s_v3` (minimum) or `Standard_D4s_v3` (recommended)
3. **Administrator Account**:
   - Authentication: SSH public key (recommended) or Password
   - Username: `azureuser` (or your preference)
4. **Inbound Port Rules**:
   - Allow: SSH (22), HTTP (80), HTTPS (443)
5. **Disks**:
   - OS Disk Type: Premium SSD
   - Size: 50GB minimum
6. **Networking**:
   - Create new VNet or use existing
   - Public IP: Yes
   - NIC network security group: Basic
7. Review + Create

### Option B: Azure CLI
```bash
# Create resource group
az group create --name lzcustom-rg --location eastus

# Create VM
az vm create \
  --resource-group lzcustom-rg \
  --name lzcustom-website \
  --image Ubuntu2204 \
  --size Standard_D2s_v3 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --public-ip-sku Standard \
  --storage-sku Premium_LRS \
  --os-disk-size-gb 50

# Open required ports
az vm open-port --resource-group lzcustom-rg --name lzcustom-website --port 80
az vm open-port --resource-group lzcustom-rg --name lzcustom-website --port 443
az vm open-port --resource-group lzcustom-rg --name lzcustom-website --port 8000
az vm open-port --resource-group lzcustom-rg --name lzcustom-website --port 5173
```

## 🔧 Step 2: Connect and Deploy

### Connect to VM
```bash
# Get public IP
az vm show --resource-group lzcustom-rg --name lzcustom-website --show-details --query publicIps --output tsv

# SSH to VM
ssh azureuser@YOUR_VM_PUBLIC_IP
```

### Run Automated Deployment
```bash
# Download and run the provisioning script
curl -fsSL https://raw.githubusercontent.com/george-shepov/LZCustom/main/scripts/provision-ubuntu.sh -o provision-ubuntu.sh
chmod +x provision-ubuntu.sh
./provision-ubuntu.sh
```

## 🌐 Step 3: Configure Domain (Optional)

### Option A: Azure DNS
1. Create DNS Zone in Azure
2. Add A record pointing to VM public IP
3. Update domain registrar nameservers

### Option B: External DNS
1. Add A record in your DNS provider
2. Point to Azure VM public IP

## 🔒 Step 4: SSL Certificate (Optional)

### Using Let's Encrypt (Recommended)
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate (replace with your domain)
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 Step 5: Access Your Website

### Public URLs
- **Main Website**: `http://YOUR_VM_PUBLIC_IP`
- **Admin Dashboard**: `http://YOUR_VM_PUBLIC_IP/admin.html`
- **API Documentation**: `http://YOUR_VM_PUBLIC_IP:8000/docs`

### With Custom Domain
- **Main Website**: `https://yourdomain.com`
- **Admin Dashboard**: `https://yourdomain.com/admin.html`
- **API**: `https://yourdomain.com/api/`

## 🔧 Management Commands

### Service Management
```bash
# Check status
sudo systemctl status lzcustom-backend
sudo systemctl status lzcustom-frontend
sudo systemctl status ollama
sudo systemctl status nginx

# Restart services
sudo systemctl restart lzcustom-backend
sudo systemctl restart lzcustom-frontend

# View logs
sudo journalctl -u lzcustom-backend -f
sudo journalctl -u lzcustom-frontend -f
```

### Quick Start/Stop
```bash
# Start all services
~/start-lzcustom.sh

# Stop all services
~/stop-lzcustom.sh
```

## 📈 Performance Optimization

### For Production Use
1. **Upgrade VM Size**: Use Standard_D4s_v3 or larger for better AI performance
2. **Enable Accelerated Networking**: In VM network settings
3. **Use Premium SSD**: For faster disk I/O
4. **Configure Swap**: For memory-intensive AI operations
```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

## 🔍 Troubleshooting

### Common Issues
1. **AI Models Not Loading**: Check disk space and memory
2. **Port Access Issues**: Verify Azure NSG rules
3. **SSL Certificate Issues**: Check domain DNS propagation
4. **High Memory Usage**: Consider upgrading VM or reducing AI models

### Monitoring
```bash
# System resources
htop
df -h
free -h

# Service logs
sudo journalctl -u lzcustom-backend --since "1 hour ago"
sudo journalctl -u ollama --since "1 hour ago"
```

## 💰 Cost Optimization

### Azure Cost Management
- Use **Reserved Instances** for long-term deployments (up to 72% savings)
- Consider **Spot Instances** for development/testing
- **Auto-shutdown** during off-hours if appropriate
- Monitor usage with **Azure Cost Management**

### Resource Optimization
- Start with Standard_D2s_v3, upgrade if needed
- Use **managed disks** with appropriate performance tier
- Consider **Azure Container Instances** for lighter workloads

## 🔐 Security Best Practices

### VM Security
- Keep Ubuntu updated: `sudo apt update && sudo apt upgrade`
- Configure UFW firewall (done by script)
- Use SSH keys instead of passwords
- Regular security updates

### Application Security
- Change default admin credentials
- Use HTTPS in production
- Regular database backups
- Monitor access logs

## 📞 Support

### Getting Help
- **GitHub Issues**: https://github.com/george-shepov/LZCustom/issues
- **Documentation**: Check README.md in repository
- **Logs**: Always check service logs first

### Useful Commands
```bash
# Full system status
~/start-lzcustom.sh

# Update application
cd LZCustom && git pull origin main
sudo systemctl restart lzcustom-backend lzcustom-frontend
```

---

**🎉 Your LZ Custom website is now running on Azure Ubuntu!**

Access your admin dashboard to manage leads and configure AI models for optimal performance.
