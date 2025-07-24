-- MySQL initialization for Ghost CMS instances
-- Creates separate databases and users for each Ghost blog

-- Create database for Bravo Ohio blog
CREATE DATABASE IF NOT EXISTS ghost_bravoohio CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'ghost_bravo'@'%' IDENTIFIED BY 'ghost_bravo_password';
GRANT ALL PRIVILEGES ON ghost_bravoohio.* TO 'ghost_bravo'@'%';

-- Create database for Giorgiy blog  
CREATE DATABASE IF NOT EXISTS ghost_giorgiy CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'ghost_giorgiy'@'%' IDENTIFIED BY 'ghost_giorgiy_password';
GRANT ALL PRIVILEGES ON ghost_giorgiy.* TO 'ghost_giorgiy'@'%';

-- Create database for Strapi CMS (if using PostgreSQL fallback)
-- This will be handled by the main PostgreSQL instance

-- Flush privileges
FLUSH PRIVILEGES;

-- Show created databases
SHOW DATABASES;

-- Show users
SELECT User, Host FROM mysql.user WHERE User LIKE 'ghost_%';