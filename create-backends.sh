#!/bin/bash

# Backend Applications Creation Script
# Creates Flask backends with SQLite and email integration

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}⚙️  Creating Backend Applications${NC}"
echo "================================="

# Create universal backend template
create_backend_template() {
    local domain="$1"
    local port="$2"
    local site_name="$3"
    local from_email="$4"
    
    echo -e "${BLUE}Creating backend for $domain (port $port)...${NC}"
    
    cat > "sites/$domain/backend/app.py" << EOF
#!/usr/bin/env python3

from flask import Flask, request, jsonify, render_template_string
from flask_cors import CORS
import sqlite3
import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime
import json
import logging

app = Flask(__name__)
CORS(app)

# Configuration
class Config:
    DOMAIN = '$domain'
    SITE_NAME = '$site_name'
    FROM_EMAIL = '$from_email'
    TO_EMAIL = 'georgeshepov@gmail.com'
    DATABASE_PATH = 'database/contacts.db'
    
    # SMTP Configuration (using your mail server)
    SMTP_SERVER = 'localhost'  # Your mail server
    SMTP_PORT = 587
    SMTP_USERNAME = '$from_email'
    SMTP_PASSWORD = 'your_email_password'  # Set this in environment

app.config.from_object(Config)

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database initialization
def init_database():
    try:
        os.makedirs(os.path.dirname(Config.DATABASE_PATH), exist_ok=True)
        conn = sqlite3.connect(Config.DATABASE_PATH)
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS contacts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT,
                phone TEXT,
                subject TEXT,
                project_type TEXT,
                contact_methods TEXT,
                message TEXT NOT NULL,
                ip_address TEXT,
                user_agent TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                status TEXT DEFAULT 'new'
            )
        ''')
        
        conn.commit()
        conn.close()
        logger.info("Database initialized successfully")
    except Exception as e:
        logger.error(f"Database initialization error: {e}")

# Email functions
def send_email(to_email, subject, body, is_html=False):
    try:
        msg = MIMEMultipart('alternative')
        msg['From'] = Config.FROM_EMAIL
        msg['To'] = to_email
        msg['Subject'] = subject
        
        if is_html:
            msg.attach(MIMEText(body, 'html'))
        else:
            msg.attach(MIMEText(body, 'plain'))
        
        # Connect to your mail server
        server = smtplib.SMTP(Config.SMTP_SERVER, Config.SMTP_PORT)
        server.starttls()
        server.login(Config.SMTP_USERNAME, Config.SMTP_PASSWORD)
        server.send_message(msg)
        server.quit()
        
        logger.info(f"Email sent successfully to {to_email}")
        return True
    except Exception as e:
        logger.error(f"Email sending error: {e}")
        return False

def send_notification_email(contact_data):
    subject = f"New Contact from {Config.SITE_NAME} - {contact_data.get('name', 'Unknown')}"
    
    body = f"""
New contact form submission from {Config.SITE_NAME}:

Name: {contact_data.get('name', 'Not provided')}
Email: {contact_data.get('email', 'Not provided')}
Phone: {contact_data.get('phone', 'Not provided')}
Subject: {contact_data.get('subject', contact_data.get('project_type', 'Not specified'))}
Preferred Contact: {contact_data.get('contact_methods', 'Not specified')}

Message:
{contact_data.get('message', 'No message provided')}

Submitted: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
From: {contact_data.get('ip_address', 'Unknown IP')}
"""
    
    return send_email(Config.TO_EMAIL, subject, body)

def send_confirmation_email(contact_data):
    if not contact_data.get('email'):
        return True  # No email provided, skip confirmation
    
    subject = f"Thank you for contacting {Config.SITE_NAME}"
    
    body = f"""
Hello {contact_data.get('name', 'there')},

Thank you for reaching out to {Config.SITE_NAME}! We've received your message and will get back to you soon.

Your message:
"{contact_data.get('message', '')}"

We'll contact you using your preferred method: {contact_data.get('contact_methods', 'email')}

Best regards,
The {Config.SITE_NAME} Team
"""
    
    return send_email(contact_data['email'], subject, body)

# Routes
@app.route('/')
def index():
    return "Backend API for {Config.SITE_NAME} is running!"

@app.route('/api/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': Config.SITE_NAME,
        'domain': Config.DOMAIN
    })

@app.route('/api/contact', methods=['POST'])
def contact():
    try:
        data = request.get_json()
        
        # Validate required fields
        if not data.get('name') or not data.get('message'):
            return jsonify({'error': 'Name and message are required'}), 400
        
        # Get client info
        ip_address = request.environ.get('HTTP_X_FORWARDED_FOR', request.remote_addr)
        user_agent = request.headers.get('User-Agent', '')
        
        # Prepare contact data
        contact_data = {
            'name': data.get('name', ''),
            'email': data.get('email', ''),
            'phone': data.get('phone', ''),
            'subject': data.get('subject', data.get('project_type', '')),
            'project_type': data.get('project_type', ''),
            'contact_methods': data.get('contact_methods', ''),
            'message': data.get('message', ''),
            'ip_address': ip_address,
            'user_agent': user_agent
        }
        
        # Save to database
        conn = sqlite3.connect(Config.DATABASE_PATH)
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO contacts (name, email, phone, subject, project_type, contact_methods, message, ip_address, user_agent)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            contact_data['name'],
            contact_data['email'],
            contact_data['phone'],
            contact_data['subject'],
            contact_data['project_type'],
            contact_data['contact_methods'],
            contact_data['message'],
            contact_data['ip_address'],
            contact_data['user_agent']
        ))
        
        contact_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        # Send emails
        notification_sent = send_notification_email(contact_data)
        confirmation_sent = send_confirmation_email(contact_data)
        
        logger.info(f"New contact saved: ID {contact_id}, Name: {contact_data['name']}")
        
        return jsonify({
            'message': 'Contact form submitted successfully!',
            'id': contact_id,
            'notification_sent': notification_sent,
            'confirmation_sent': confirmation_sent
        })
        
    except Exception as e:
        logger.error(f"Contact form error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/contacts', methods=['GET'])
def get_contacts():
    try:
        conn = sqlite3.connect(Config.DATABASE_PATH)
        cursor = conn.cursor()
        cursor.execute('''
            SELECT id, name, email, phone, subject, project_type, contact_methods, message, created_at, status
            FROM contacts 
            ORDER BY created_at DESC
        ''')
        
        contacts = []
        for row in cursor.fetchall():
            contacts.append({
                'id': row[0],
                'name': row[1],
                'email': row[2],
                'phone': row[3],
                'subject': row[4],
                'project_type': row[5],
                'contact_methods': row[6],
                'message': row[7],
                'created_at': row[8],
                'status': row[9]
            })
        
        conn.close()
        return jsonify(contacts)
        
    except Exception as e:
        logger.error(f"Get contacts error: {e}")
        return jsonify([])

if __name__ == '__main__':
    init_database()
    app.run(host='0.0.0.0', port=$port, debug=False)
EOF
    
    # Create requirements.txt
    cat > "sites/$domain/backend/requirements.txt" << 'EOF'
Flask==3.1.1
Flask-CORS==6.0.1
gunicorn==21.2.0
EOF
    
    echo -e "${GREEN}✅ Backend created for $domain${NC}"
}

# Create all backends
main() {
    # Create backends for each domain
    create_backend_template "giorgiy.org" "4001" "LZ Custom" "info@giorgiy.org"
    create_backend_template "giorgiy-shepov.com" "4002" "Giorgiy Shepov" "contact@giorgiy-shepov.com"
    create_backend_template "lodexinc.com" "4003" "Lodex Inc" "info@lodexinc.com"
    create_backend_template "bravoohiocci.org" "4004" "Bravo Ohio CCI" "info@bravoohiocci.org"
    
    echo -e "${GREEN}[COMPLETE] All backends created${NC}"
    echo -e "${BLUE}[INFO] Next: Start all services with ./start-all-services.sh${NC}"
}

main "$@"
