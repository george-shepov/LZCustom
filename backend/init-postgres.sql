-- PostgreSQL Database Initialization for Multi-Domain Platform
-- Creates schemas and tables for each domain/brand

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- Create schemas for each domain
CREATE SCHEMA IF NOT EXISTS lz_custom;        -- giorgiy.org
CREATE SCHEMA IF NOT EXISTS gs_consulting;    -- giorgiy-shepov.com  
CREATE SCHEMA IF NOT EXISTS bravo_ohio;       -- bravoohio.org
CREATE SCHEMA IF NOT EXISTS lodex_inc;        -- lodexinc.com
CREATE SCHEMA IF NOT EXISTS shared;           -- Common/shared data

-- Common Tables (Shared Schema)
CREATE TABLE IF NOT EXISTS shared.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    is_admin BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS shared.sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_token VARCHAR(255) UNIQUE NOT NULL,
    user_id UUID REFERENCES shared.users(id) ON DELETE CASCADE,
    domain VARCHAR(100) NOT NULL,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create prospects table for each domain
-- LZ Custom (giorgiy.org)
CREATE TABLE IF NOT EXISTS lz_custom.prospects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    project_type VARCHAR(50),
    budget_range VARCHAR(50),
    timeline VARCHAR(50),
    message TEXT,
    room_dimensions VARCHAR(100),
    measurements TEXT,
    wood_species VARCHAR(50),
    cabinet_style VARCHAR(50),
    material_type VARCHAR(50),
    square_footage INTEGER,
    priority VARCHAR(20) DEFAULT 'normal',
    status VARCHAR(20) DEFAULT 'new',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Giorgiy Shepov Consulting (giorgiy-shepov.com)
CREATE TABLE IF NOT EXISTS gs_consulting.prospects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    company VARCHAR(100),
    industry VARCHAR(50),
    project_type VARCHAR(50),
    budget_range VARCHAR(50),
    timeline VARCHAR(50),
    message TEXT,
    business_size VARCHAR(20),
    current_challenges TEXT,
    goals TEXT,
    priority VARCHAR(20) DEFAULT 'normal',
    status VARCHAR(20) DEFAULT 'new',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Bravo Ohio (bravoohio.org)
CREATE TABLE IF NOT EXISTS bravo_ohio.prospects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    company VARCHAR(100),
    industry VARCHAR(50),
    service_type VARCHAR(50),
    budget_range VARCHAR(50),
    timeline VARCHAR(50),
    message TEXT,
    market_focus VARCHAR(50),
    growth_stage VARCHAR(30),
    key_challenges TEXT,
    priority VARCHAR(20) DEFAULT 'normal',
    status VARCHAR(20) DEFAULT 'new',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Lodex Inc (lodexinc.com)
CREATE TABLE IF NOT EXISTS lodex_inc.prospects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    company VARCHAR(100),
    position VARCHAR(100),
    industry VARCHAR(50),
    service_type VARCHAR(50),
    budget_range VARCHAR(50),
    timeline VARCHAR(50),
    message TEXT,
    company_size VARCHAR(30),
    revenue_range VARCHAR(30),
    strategic_goals TEXT,
    priority VARCHAR(20) DEFAULT 'normal',
    status VARCHAR(20) DEFAULT 'new',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Chat conversations for each domain
CREATE TABLE IF NOT EXISTS lz_custom.chat_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id VARCHAR(100) NOT NULL,
    user_message TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    model_used VARCHAR(50),
    tier VARCHAR(20),
    response_time DECIMAL(6,2),
    success BOOLEAN DEFAULT true,
    error_message TEXT,
    user_ip INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS gs_consulting.chat_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id VARCHAR(100) NOT NULL,
    user_message TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    model_used VARCHAR(50),
    tier VARCHAR(20),
    response_time DECIMAL(6,2),
    success BOOLEAN DEFAULT true,
    error_message TEXT,
    user_ip INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bravo_ohio.chat_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id VARCHAR(100) NOT NULL,
    user_message TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    model_used VARCHAR(50),
    tier VARCHAR(20),
    response_time DECIMAL(6,2),
    success BOOLEAN DEFAULT true,
    error_message TEXT,
    user_ip INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lodex_inc.chat_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id VARCHAR(100) NOT NULL,
    user_message TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    model_used VARCHAR(50),
    tier VARCHAR(20),
    response_time DECIMAL(6,2),
    success BOOLEAN DEFAULT true,
    error_message TEXT,
    user_ip INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Analytics and tracking tables
CREATE TABLE IF NOT EXISTS shared.page_views (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    domain VARCHAR(100) NOT NULL,
    path VARCHAR(255) NOT NULL,
    ip_address INET,
    user_agent TEXT,
    referer TEXT,
    session_id VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS shared.events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    domain VARCHAR(100) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_data JSONB,
    user_id UUID REFERENCES shared.users(id),
    session_id VARCHAR(100),
    ip_address INET,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Content Management System tables (for dynamic content)
CREATE TABLE IF NOT EXISTS shared.content_pages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    domain VARCHAR(100) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    meta_description TEXT,
    meta_keywords TEXT,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(domain, slug)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_prospects_email_lz ON lz_custom.prospects(email);
CREATE INDEX IF NOT EXISTS idx_prospects_created_lz ON lz_custom.prospects(created_at);
CREATE INDEX IF NOT EXISTS idx_prospects_status_lz ON lz_custom.prospects(status);

CREATE INDEX IF NOT EXISTS idx_prospects_email_gs ON gs_consulting.prospects(email);
CREATE INDEX IF NOT EXISTS idx_prospects_created_gs ON gs_consulting.prospects(created_at);
CREATE INDEX IF NOT EXISTS idx_prospects_status_gs ON gs_consulting.prospects(status);

CREATE INDEX IF NOT EXISTS idx_prospects_email_bo ON bravo_ohio.prospects(email);
CREATE INDEX IF NOT EXISTS idx_prospects_created_bo ON bravo_ohio.prospects(created_at);
CREATE INDEX IF NOT EXISTS idx_prospects_status_bo ON bravo_ohio.prospects(status);

CREATE INDEX IF NOT EXISTS idx_prospects_email_li ON lodex_inc.prospects(email);
CREATE INDEX IF NOT EXISTS idx_prospects_created_li ON lodex_inc.prospects(created_at);
CREATE INDEX IF NOT EXISTS idx_prospects_status_li ON lodex_inc.prospects(status);

CREATE INDEX IF NOT EXISTS idx_chat_session_lz ON lz_custom.chat_conversations(session_id);
CREATE INDEX IF NOT EXISTS idx_chat_created_lz ON lz_custom.chat_conversations(created_at);

CREATE INDEX IF NOT EXISTS idx_chat_session_gs ON gs_consulting.chat_conversations(session_id);
CREATE INDEX IF NOT EXISTS idx_chat_created_gs ON gs_consulting.chat_conversations(created_at);

CREATE INDEX IF NOT EXISTS idx_chat_session_bo ON bravo_ohio.chat_conversations(session_id);
CREATE INDEX IF NOT EXISTS idx_chat_created_bo ON bravo_ohio.chat_conversations(created_at);

CREATE INDEX IF NOT EXISTS idx_chat_session_li ON lodex_inc.chat_conversations(session_id);
CREATE INDEX IF NOT EXISTS idx_chat_created_li ON lodex_inc.chat_conversations(created_at);

CREATE INDEX IF NOT EXISTS idx_page_views_domain ON shared.page_views(domain);
CREATE INDEX IF NOT EXISTS idx_page_views_created ON shared.page_views(created_at);

CREATE INDEX IF NOT EXISTS idx_events_domain ON shared.events(domain);
CREATE INDEX IF NOT EXISTS idx_events_type ON shared.events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_created ON shared.events(created_at);

CREATE INDEX IF NOT EXISTS idx_content_domain_slug ON shared.content_pages(domain, slug);
CREATE INDEX IF NOT EXISTS idx_content_published ON shared.content_pages(is_published);

-- Create updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to tables with updated_at columns
CREATE TRIGGER update_lz_prospects_updated_at BEFORE UPDATE ON lz_custom.prospects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_gs_prospects_updated_at BEFORE UPDATE ON gs_consulting.prospects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bo_prospects_updated_at BEFORE UPDATE ON bravo_ohio.prospects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_li_prospects_updated_at BEFORE UPDATE ON lodex_inc.prospects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON shared.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_content_updated_at BEFORE UPDATE ON shared.content_pages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();