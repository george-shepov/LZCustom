# LZ Custom - Azure App Service Deployment Guide

## 🚀 **Azure App Service Free Tier Deployment**

This guide will help you deploy the LZ Custom website to Azure App Service Free Tier - completely free and professional!

### **✅ What You Get**
- **Professional website** with admin dashboard
- **Lead management** system with SQLite database
- **Simple chat responses** (no AI complexity)
- **Form submissions** with zero prospect loss
- **Mobile-responsive** design
- **SSL certificate** included
- **Custom domain** support
- **Automatic scaling**
- **99.9% uptime** guarantee

---

## 📋 **Prerequisites**

1. **Azure Account** (free tier available)
2. **GitHub Account** (for code repository)
3. **5 minutes** of your time

---

## 🎯 **Step 1: Create Azure App Service**

### **Option A: Azure Portal (Recommended)**

1. **Go to Azure Portal**: https://portal.azure.com
2. **Click "Create a resource"**
3. **Search for "Web App"** and select it
4. **Fill in the details**:
   - **Resource Group**: Create new (e.g., "lz-custom-rg")
   - **Name**: Choose unique name (e.g., "lz-custom-website")
   - **Runtime Stack**: Python 3.9
   - **Operating System**: Linux
   - **Region**: Choose closest to you
   - **Pricing Plan**: F1 (Free) ✅
5. **Click "Review + Create"** then **"Create"**

### **Option B: Azure CLI**
```bash
# Login to Azure
az login

# Create resource group
az group create --name lz-custom-rg --location eastus

# Create App Service plan (Free tier)
az appservice plan create --name lz-custom-plan --resource-group lz-custom-rg --sku F1 --is-linux

# Create web app
az webapp create --resource-group lz-custom-rg --plan lz-custom-plan --name lz-custom-website --runtime "PYTHON|3.9"
```

---

## 🔧 **Step 2: Deploy the Code**

### **Option A: GitHub Actions (Recommended)**

1. **Fork this repository** to your GitHub account
2. **Go to your Azure App Service** in the portal
3. **Click "Deployment Center"**
4. **Select "GitHub"** as source
5. **Authorize GitHub** and select your forked repository
6. **Select branch**: main
7. **Select folder**: /azure-app-service
8. **Click "Save"**

**That's it!** Azure will automatically deploy your website.

### **Option B: Manual Deployment**

1. **Download the azure-app-service folder**
2. **Zip the contents** (not the folder itself)
3. **Go to your App Service** in Azure Portal
4. **Click "Advanced Tools" → "Go"**
5. **Click "Tools" → "Zip Push Deploy"**
6. **Drag and drop your zip file**

---

## 🌐 **Step 3: Access Your Website**

1. **Go to your App Service** in Azure Portal
2. **Click "Browse"** or copy the URL
3. **Your website is live!**
   - **Main site**: https://your-app-name.azurewebsites.net
   - **Admin dashboard**: https://your-app-name.azurewebsites.net/admin.html

---

## 🔐 **Step 4: Secure Your Admin Dashboard**

### **Add Basic Authentication** (Recommended)

1. **Go to App Service** → **Configuration**
2. **Add Application Settings**:
   - **Name**: `ADMIN_USERNAME`
   - **Value**: `admin` (or your choice)
3. **Add another setting**:
   - **Name**: `ADMIN_PASSWORD`
   - **Value**: `your-secure-password`
4. **Click "Save"**

### **Custom Domain** (Optional)
1. **Go to App Service** → **Custom domains**
2. **Click "Add custom domain"**
3. **Enter your domain** (e.g., lzcustom.com)
4. **Follow verification steps**
5. **Free SSL certificate** will be automatically provisioned

---

## 📊 **Features Overview**

### **Main Website**
- ✅ **Professional design** with your branding
- ✅ **Service showcase** (cabinets, countertops, etc.)
- ✅ **Contact form** with lead capture
- ✅ **Simple chat widget** with predefined responses
- ✅ **Mobile responsive** design
- ✅ **SEO optimized**

### **Admin Dashboard**
- ✅ **Lead management** with search and filters
- ✅ **Status tracking** (new, contacted, quoted, won, lost)
- ✅ **Priority system** (high, normal, low)
- ✅ **Notes system** for each lead
- ✅ **Analytics dashboard** with statistics
- ✅ **Export functionality** (CSV)

### **Chat System**
- ✅ **Instant responses** about services
- ✅ **Contact information** sharing
- ✅ **No AI complexity** - simple and reliable
- ✅ **All conversations logged** for lead tracking

---

## 💰 **Cost Breakdown**

### **Azure App Service Free Tier**
- ✅ **Monthly cost**: $0.00
- ✅ **1GB storage**
- ✅ **1GB RAM**
- ✅ **60 CPU minutes/day**
- ✅ **Custom domains** supported
- ✅ **SSL certificates** included
- ✅ **No time limit** (unlike VM free tier)

### **Upgrade Options** (if needed)
- **Basic B1**: $13.14/month (1.75GB RAM, no daily limits)
- **Standard S1**: $56.94/month (1.75GB RAM, auto-scaling)

---

## 🔧 **Customization**

### **Update Business Information**
1. **Edit templates/index.html**:
   - Change phone number (216-268-2990)
   - Update service area
   - Modify services offered
2. **Edit static/js/main.js**:
   - Update chat responses
   - Modify form validation

### **Add Your Branding**
1. **Replace images** in static/images/
2. **Update colors** in static/css/style.css
3. **Change logo** and company name

### **Database Customization**
- **SQLite database** is automatically created
- **Tables**: prospects, chat_conversations
- **Backup**: Download from Kudu console

---

## 🚨 **Troubleshooting**

### **Common Issues**

**1. App won't start**
- Check **Application Logs** in Azure Portal
- Verify **requirements.txt** has correct versions
- Ensure **startup.py** is in root directory

**2. Database errors**
- SQLite file will be created automatically
- Check **file permissions** in Kudu console

**3. Static files not loading**
- Verify **static/** folder structure
- Check **Flask static file configuration**

### **Monitoring**
- **Application Insights** (free tier available)
- **Log Stream** in Azure Portal
- **Metrics** dashboard for performance

---

## 📞 **Support**

### **Azure Support**
- **Free tier**: Community support
- **Paid tiers**: Technical support included

### **Application Support**
- **GitHub Issues**: Report bugs or feature requests
- **Documentation**: This guide and code comments

---

## 🎉 **Success!**

Your professional LZ Custom website is now live on Azure App Service Free Tier!

### **Next Steps**
1. **Test all functionality** (forms, chat, admin dashboard)
2. **Add your custom domain** (optional)
3. **Set up monitoring** and alerts
4. **Start generating leads!**

### **Professional Features**
- ✅ **Zero prospect loss** - all form submissions saved
- ✅ **Lead prioritization** - high-value leads highlighted
- ✅ **Mobile-friendly** - works on all devices
- ✅ **Fast loading** - optimized for performance
- ✅ **Reliable hosting** - Azure's enterprise infrastructure

**Your professional fabrication website is ready to generate business!** 🚀☁️
