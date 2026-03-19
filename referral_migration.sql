-- SQL Script to add referral columns to users table
-- Run this in phpMyAdmin or via MySQL command line

-- Add referral_code column (unique code for each user)
ALTER TABLE users ADD COLUMN referral_code VARCHAR(20) NULL;

-- Add referred_by column (stores the referral_code of the user who referred this user)
ALTER TABLE users ADD COLUMN referred_by INT NULL;

-- Add referred_at column (timestamp when user was referred)
ALTER TABLE users ADD COLUMN referred_at TIMESTAMP NULL;

-- Add index for faster lookups (but limit key length to avoid MySQL error)
ALTER TABLE users ADD INDEX idx_referral_code (referral_code(9));

-- Add foreign key for referred_by (optional, depends on your setup)
-- ALTER TABLE users ADD FOREIGN KEY (referred_by) REFERENCES users(id) ON DELETE SET NULL;

-- Update existing users to have unique referral codes (optional - for existing users)
-- This generates codes for users who already exist
-- UPDATE users SET referral_code = CONCAT('MSK', LPAD(id, 6, '0')) WHERE referral_code IS NULL;
