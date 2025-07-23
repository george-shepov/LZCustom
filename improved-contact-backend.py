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
from twilio.rest import Client

app = Flask(__name__)
CORS(app)

# Configuration
class Config:
    DOMAIN = 'lzcustom.giorgiy.org'
    SITE_NAME = 'LZ Custom Fabrication'
    FROM_EMAIL = 'info@giorgiy.org'
    TO_EMAIL = 'georgeshepov@gmail.com'
    DATABASE_PATH = '/home/shepov/Documents/Source/LZCustom/database/contacts.db'
    
    # SMTP Configuration
    SMTP_SERVER = 'localhost'
    SMTP_PORT = 587
    SMTP_USERNAME = 'info@giorgiy.org'
    SMTP_PASSWORD = os.environ.get('EMAIL_PASSWORD', 'your_password')
    
    # Twilio Configuration (set these environment variables)
    TWILIO_ACCOUNT_SID = os.environ.get('TWILIO_ACCOUNT_SID', 'your_account_sid')
    TWILIO_AUTH_TOKEN = os.environ.get('TWILIO_AUTH_TOKEN', 'your_auth_token')
    TWILIO_PHONE_NUMBER = os.environ.get('TWILIO_PHONE_NUMBER', '+1234567890')

app.config.from_object(Config)

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Twilio client
try:
    twilio_client = Client(Config.TWILIO_ACCOUNT_SID, Config.TWILIO_AUTH_TOKEN)
    logger.info("Twilio client initialized")
except Exception as e:
    logger.warning(f"Twilio initialization failed: {e}")
    twilio_client = None

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
                project_type TEXT,
                contact_methods TEXT,
                message TEXT NOT NULL,
                ip_address TEXT,
                user_agent TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                status TEXT DEFAULT 'new',
                callback_requested BOOLEAN DEFAULT 0,
                text_requested BOOLEAN DEFAULT 0
            )
        ''')
        
        conn.commit()
        conn.close()
        logger.info("Database initialized successfully")
    except Exception as e:
        logger.error(f"Database initialization error: {e}")

# Twilio functions
def send_sms(to_phone, message):
    if not twilio_client:
        logger.error("Twilio client not initialized")
        return False
    
    try:
        message = twilio_client.messages.create(
            body=message,
            from_=Config.TWILIO_PHONE_NUMBER,
            to=to_phone
        )
        logger.info(f"SMS sent successfully to {to_phone}: {message.sid}")
        return True
    except Exception as e:
        logger.error(f"SMS sending error: {e}")
        return False

def make_call(to_phone, message):
    if not twilio_client:
        logger.error("Twilio client not initialized")
        return False
    
    try:
        # Create TwiML for the call
        twiml_url = f"http://twimlets.com/message?Message%5B0%5D={message}"
        
        call = twilio_client.calls.create(
            twiml=f'<Response><Say>{message}</Say></Response>',
            to=to_phone,
            from_=Config.TWILIO_PHONE_NUMBER
        )
        logger.info(f"Call initiated successfully to {to_phone}: {call.sid}")
        return True
    except Exception as e:
        logger.error(f"Call initiation error: {e}")
        return False

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
    subject = f"New Contact from LZ Custom - {contact_data.get('name', 'Unknown')}"
    
    body = f"""
New contact form submission from LZ Custom:

Name: {contact_data.get('name', 'Not provided')}
Email: {contact_data.get('email', 'Not provided')}
Phone: {contact_data.get('phone', 'Not provided')}
Project: {contact_data.get('project_type', 'Not specified')}
Preferred Contact: {contact_data.get('contact_methods', 'Not specified')}

Callback Requested: {'Yes' if contact_data.get('callback_requested') else 'No'}
Text Requested: {'Yes' if contact_data.get('text_requested') else 'No'}

Message:
{contact_data.get('message', 'No message provided')}

Submitted: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
From: {contact_data.get('ip_address', 'Unknown IP')}
"""
    
    return send_email(Config.TO_EMAIL, subject, body)

# Routes
@app.route('/')
def index():
    return "LZ Custom Contact API is running!"

@app.route('/api/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'LZ Custom Contact API',
        'twilio_enabled': twilio_client is not None
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
        
        # Check for callback/text requests
        callback_requested = data.get('callback_requested', False)
        text_requested = data.get('text_requested', False)
        
        # Prepare contact data
        contact_data = {
            'name': data.get('name', ''),
            'email': data.get('email', ''),
            'phone': data.get('phone', ''),
            'project_type': data.get('project_type', ''),
            'contact_methods': data.get('contact_methods', ''),
            'message': data.get('message', ''),
            'ip_address': ip_address,
            'user_agent': user_agent,
            'callback_requested': callback_requested,
            'text_requested': text_requested
        }
        
        # Save to database
        conn = sqlite3.connect(Config.DATABASE_PATH)
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO contacts (name, email, phone, project_type, contact_methods, message, 
                                ip_address, user_agent, callback_requested, text_requested)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            contact_data['name'],
            contact_data['email'],
            contact_data['phone'],
            contact_data['project_type'],
            contact_data['contact_methods'],
            contact_data['message'],
            contact_data['ip_address'],
            contact_data['user_agent'],
            contact_data['callback_requested'],
            contact_data['text_requested']
        ))
        
        contact_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        # Send notification email
        notification_sent = send_notification_email(contact_data)
        
        # Handle callback request
        callback_sent = False
        if callback_requested and contact_data.get('phone'):
            callback_message = f"Hello {contact_data['name']}, this is LZ Custom. You requested a callback regarding your {contact_data.get('project_type', 'project')}. We'll call you back shortly!"
            callback_sent = make_call(contact_data['phone'], callback_message)
        
        # Handle text request
        text_sent = False
        if text_requested and contact_data.get('phone'):
            text_message = f"Hi {contact_data['name']}! Thanks for contacting LZ Custom. We received your message about {contact_data.get('project_type', 'your project')} and will get back to you soon. Call us at 216-268-2990 for immediate assistance."
            text_sent = send_sms(contact_data['phone'], text_message)
        
        logger.info(f"New contact saved: ID {contact_id}, Name: {contact_data['name']}")
        
        return jsonify({
            'message': 'Contact form submitted successfully!',
            'id': contact_id,
            'notification_sent': notification_sent,
            'callback_sent': callback_sent,
            'text_sent': text_sent
        })
        
    except Exception as e:
        logger.error(f"Contact form error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    init_database()
    app.run(host='0.0.0.0', port=8000, debug=False)
