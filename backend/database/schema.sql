-- NutriApp Database Schema
-- Created for MySQL 8.0+

USE nutriapp;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    preferences JSON,
    INDEX idx_email (email),
    INDEX idx_username (username)
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(255) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    rating ENUM('A', 'B', 'C', 'D', 'E') NOT NULL,
    description TEXT,
    ingredients JSON,
    nutrition_facts JSON,
    price INT DEFAULT 0, -- Price in cents
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    INDEX idx_category (category),
    INDEX idx_rating (rating),
    INDEX idx_brand (brand),
    INDEX idx_name (name),
    FULLTEXT idx_search (name, brand, description),
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Sessions table
CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    session_id VARCHAR(255) NOT NULL UNIQUE,
    user_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_session_id (session_id),
    INDEX idx_user_id (user_id),
    INDEX idx_expires_at (expires_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Categories table (for future extensibility)
CREATE TABLE IF NOT EXISTS categories (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name)
);

-- Password reset tokens table
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    email VARCHAR(100) NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_token (token),
    INDEX idx_email (email),
    INDEX idx_expires_at (expires_at),
    FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE
);

-- Insert default categories
INSERT INTO categories (name, display_name, description) VALUES
('protein_powder', 'Protein Powder', 'Protein supplements and powders'),
('chips', 'Chips', 'Potato chips and similar snacks'),
('chocolates', 'Chocolates', 'Chocolate bars and chocolate products'),
('popcorn', 'Popcorn', 'Popcorn and corn-based snacks'),
('biscuits', 'Biscuits', 'Biscuits, cookies, and crackers'),
('cereals', 'Cereals', 'Breakfast cereals and grains'),
('nuts', 'Nuts', 'Nuts and nut-based products'),
('energy_bars', 'Energy Bars', 'Energy and protein bars'),
('drinks', 'Drinks', 'Beverages and liquid nutrition')
ON DUPLICATE KEY UPDATE 
    display_name = VALUES(display_name),
    description = VALUES(description);

-- Insert default admin user (password should be changed in production)
INSERT INTO users (id, username, email, password, role, preferences) VALUES
('admin1', 'admin', 'admin@nutriapp.com', 'admin123', 'admin', '{"favoriteCategories": []}'),
('user1', 'john_doe', 'john@example.com', 'password123', 'user', '{"favoriteCategories": []}')
ON DUPLICATE KEY UPDATE 
    username = VALUES(username),
    email = VALUES(email);

-- Create database connection test table
CREATE TABLE IF NOT EXISTS db_test (
    id INT PRIMARY KEY AUTO_INCREMENT,
    test_message VARCHAR(255) DEFAULT 'Database connection successful',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO db_test (test_message) VALUES ('Schema initialized successfully');
